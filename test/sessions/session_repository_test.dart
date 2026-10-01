import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_trainer/database/app_database.dart';
import 'package:personal_trainer/database/tables.dart';
import 'package:personal_trainer/sessions/session_repository.dart';

const running = 1; // Seeded first in onCreate.
const squats = 2;

DateTime d(int month, int day) => DateTime(2026, month, day);

void main() {
  late AppDatabase db;
  late SessionRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = SessionRepository(db);
  });

  tearDown(() => db.close());

  test('the three goals are seeded on first open', () async {
    final exercises = await db.select(db.exercises).get();
    expect(exercises.map((e) => e.name), ['Running', 'Squats', 'Push-ups']);
  });

  test('setting a target creates a session', () async {
    await repo.setTargets(running, d(10, 5), total: 3, continuous: 1);
    final s = await repo.find(running, d(10, 5));
    expect(s!.targetTotal, 3);
    expect(s.targetContinuous, 1);
    expect(s.actualTotal, isNull);
  });

  test('logging keeps existing targets', () async {
    await repo.setTargets(running, d(10, 5), total: 3, continuous: 1);
    await repo.logActuals(running, d(10, 5), total: 3.2, continuous: 0.8);
    final s = await repo.find(running, d(10, 5));
    expect(s!.targetTotal, 3);
    expect(s.actualTotal, 3.2);
    expect(s.actualContinuous, 0.8);
  });

  test('changing targets keeps an existing log', () async {
    await repo.logActuals(running, d(10, 5), total: 3, note: 'felt good');
    await repo.setTargets(running, d(10, 5), total: 4);
    final s = await repo.find(running, d(10, 5));
    expect(s!.targetTotal, 4);
    expect(s.actualTotal, 3);
    expect(s.note, 'felt good');
  });

  test('re-logging the same day updates the row instead of adding one',
          () async {
        await repo.logActuals(squats, d(10, 5), total: 80);
        await repo.logActuals(squats, d(10, 5), total: 95);
        final rows = await db.select(db.sessions).get();
        expect(rows, hasLength(1));
        expect(rows.single.actualTotal, 95);
      });

  test('setTargetsOn writes the same targets on every given day', () async {
    final days = [d(10, 1), d(10, 3), d(10, 5)];
    await repo.setTargetsOn(running, days, total: 1, continuous: 1);
    final rows = await repo.all();
    expect(rows.map((s) => s.date),
        ['2026-10-01', '2026-10-03', '2026-10-05']);
    expect(rows.every((s) => s.targetTotal == 1), isTrue);
  });

  test('sets round-trip through JSON', () async {
    await repo.logActuals(squats, d(10, 5), total: 95, sets: [40, 30, 25]);
    final s = await repo.find(squats, d(10, 5));
    expect(s!.setList, [40, 30, 25]);
  });

  test('clearLog removes the log but keeps targets', () async {
    await repo.setTargets(running, d(10, 5), total: 3);
    await repo.logActuals(running, d(10, 5), total: 2, note: 'rain');
    await repo.setStatusOverride(running, d(10, 5), SessionStatus.done);
    await repo.clearLog(running, d(10, 5));
    final s = await repo.find(running, d(10, 5));
    expect(s!.targetTotal, 3);
    expect(s.actualTotal, isNull);
    expect(s.note, isNull);
    expect(s.statusOverride, isNull);
  });

  test('an override can be set and cleared', () async {
    await repo.setStatusOverride(running, d(10, 5), SessionStatus.done);
    expect((await repo.find(running, d(10, 5)))!.statusOverride,
        SessionStatus.done);
    await repo.setStatusOverride(running, d(10, 5), null);
    expect((await repo.find(running, d(10, 5)))!.statusOverride, isNull);
  });

  test('recentLogged skips planned-only days and returns newest first',
          () async {
        await repo.logActuals(running, d(10, 1), total: 2);
        await repo.logActuals(running, d(10, 3), total: 2.5);
        await repo.setTargets(running, d(10, 5), total: 3); // Planned only.
        await repo.logActuals(running, d(10, 7), total: 3); // Not before d(10, 7).
        await repo.logActuals(squats, d(10, 4), total: 80); // Other exercise.

        final recent = await repo.recentLogged(running, before: d(10, 7));
        expect(recent.map((s) => s.date), ['2026-10-03', '2026-10-01']);
      });

  test('watchBetween returns only sessions in range, in date order', () async {
    await repo.logActuals(running, d(10, 9), total: 1);
    await repo.logActuals(running, d(10, 2), total: 1);
    await repo.logActuals(running, d(10, 20), total: 1);

    final inRange = await repo.watchBetween(d(10, 1), d(10, 10)).first;
    expect(inRange.map((s) => s.date), ['2026-10-02', '2026-10-09']);
  });

  group('running distance', () {
    test('targets and actuals are stored alongside the other two', () async {
      await repo.setTargets(running, d(10, 5),
          total: 6, running: 4, continuous: 1.5);
      await repo.logActuals(running, d(10, 5),
          total: 6.5, running: 4.2, continuous: 2);

      final s = (await repo.find(running, d(10, 5)))!;
      expect((s.targetTotal, s.targetRunning, s.targetContinuous),
          (6.0, 4.0, 1.5));
      expect((s.actualTotal, s.actualRunning, s.actualContinuous),
          (6.5, 4.2, 2.0));
    });

    test('clearLog clears running too but keeps the running target', () async {
      await repo.setTargets(running, d(10, 5), total: 6, running: 4);
      await repo.logActuals(running, d(10, 5), total: 6, running: 4);
      await repo.clearLog(running, d(10, 5));

      final s = (await repo.find(running, d(10, 5)))!;
      expect(s.actualRunning, isNull);
      expect(s.targetRunning, 4);
    });

    test('recentLogged counts a day with only running logged', () async {
      await repo.logActuals(running, d(10, 1), running: 2);
      final recent = await repo.recentLogged(running, before: d(10, 7));
      expect(recent.map((s) => s.date), ['2026-10-01']);
    });
  });
}
