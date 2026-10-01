import 'package:flutter_test/flutter_test.dart';
import 'package:personal_trainer/database/app_database.dart';
import 'package:personal_trainer/progress/progress_calculator.dart';

const runningEx = Exercise(
  id: 1,
  name: 'Running',
  unit: 'km',
  goalTotal: 5,
  goalContinuous: 2,
  deadline: '2026-12-31',
);

Session run(
  String date, {
  double? total,
  double? continuous,
  double? running,
}) =>
    Session(
      id: 0,
      exerciseId: 1,
      date: date,
      actualTotal: total,
      actualContinuous: continuous,
      actualRunning: running,
    );

WeightEntry weight(String date, double kg) => WeightEntry(date: date, kg: kg);

void main() {
  group('exercise progress', () {
    test('nothing logged gives no best and no on-track verdict', () {
      final p = progressFor(runningEx, const [], DateTime(2026, 10, 16));
      expect(p.total.best, isNull);
      expect(p.total.fraction, 0);
      expect(p.total.onTrack, isNull);
    });

    test('best, fraction and the expected line from the first session', () {
      final sessions = [
        run('2026-10-01', total: 1, continuous: 0.5),
        run('2026-10-10', total: 1.8, continuous: 0.8),
      ];
      final p = progressFor(runningEx, sessions, DateTime(2026, 10, 16));

      expect(p.total.best, 1.8);
      expect(p.total.fraction, closeTo(0.36, 1e-9));
      // 1 Oct → 31 Dec is 91 days; 16 Oct is 15 days in.
      // Expected: 1 + (5 - 1) * 15 / 91 ≈ 1.659.
      expect(p.total.expectedToday, closeTo(1.659, 0.001));
      expect(p.total.onTrack, isTrue);
    });

    test('zero-logged (skipped) days are not used as the starting point', () {
      final sessions = [
        run('2026-10-01', total: 0, continuous: 0),
        run('2026-10-03', total: 2, continuous: 1),
      ];
      final p = progressFor(runningEx, sessions, DateTime(2026, 10, 3));
      expect(p.total.expectedToday, 2);
    });

    test('future sessions are ignored', () {
      final sessions = [run('2026-10-20', total: 3)];
      final p = progressFor(runningEx, sessions, DateTime(2026, 10, 16));
      expect(p.total.best, isNull);
    });
  });

  group('weight', () {
    test('moving average uses calendar days, not entry count', () {
      final points = withMovingAverage([
        weight('2026-10-01', 90),
        weight('2026-10-02', 91),
        weight('2026-10-03', 92),
        weight('2026-10-10', 88), // Window 4–10 Oct: only itself.
      ]);
      expect(points.map((p) => p.average), [90, 90.5, 91, 88]);
    });

    test('pace shows needed and recent weekly change', () {
      final points = withMovingAverage([
        weight('2026-10-01', 92),
        weight('2026-10-08', 91),
      ]);
      final pace = weightPace(
        points,
        deadline: DateTime(2026, 12, 31),
        today: DateTime(2026, 10, 8),
      )!;
      // 8 Oct → 31 Dec is 84 days = 12 weeks; (85 - 91) / 12 = -0.5.
      expect(pace.currentAverage, 91);
      expect(pace.kgPerWeekNeeded, closeTo(-0.5, 1e-9));
      expect(pace.kgPerWeekRecent, closeTo(-1.0, 1e-9));
    });

    test('recent pace is null with less than a week of data', () {
      final points = withMovingAverage([
        weight('2026-10-01', 92),
        weight('2026-10-04', 91.5),
      ]);
      final pace = weightPace(
        points,
        deadline: DateTime(2026, 12, 31),
        today: DateTime(2026, 10, 4),
      )!;
      expect(pace.kgPerWeekRecent, isNull);
    });
  });

  group('running distance', () {
    const withDistance = Exercise(
      id: 1, name: 'Running', unit: 'km',
      goalTotal: 8, goalContinuous: 2, goalRunning: 5,
      deadline: '2026-12-31',
    );

    test('has its own best and fraction of the running goal', () {
      final p = progressFor(
        withDistance,
        [
          run('2026-10-01', total: 3, running: 1.5),
          run('2026-10-05', total: 3.5, running: 2.5),
        ],
        DateTime(2026, 10, 10),
      );
      expect(p.running!.goal, 5);
      expect(p.running!.best, 2.5);
      expect(p.running!.fraction, 0.5);
    });

    test('is null for exercises without a running goal', () {
      expect(progressFor(runningEx, const [], DateTime(2026, 10, 10)).running,
          isNull);
    });
  });
}
