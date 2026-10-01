import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_trainer/database/app_database.dart';
import 'package:personal_trainer/database/database_state.dart';
import 'package:personal_trainer/database/tables.dart';
import 'package:personal_trainer/schedule/schedule_state.dart';
import 'package:personal_trainer/sessions/session_repository.dart';
import 'package:personal_trainer/sessions/sessions_state.dart';

const running = 1;
const squats = 2;

const runningEx = Exercise(
  id: running, name: 'Running', unit: 'km',
  goalTotal: 5, goalContinuous: 2, deadline: '2026-12-31',
);
const squatsEx = Exercise(
  id: squats, name: 'Squats', unit: 'reps',
  goalTotal: 1000, goalContinuous: 200, deadline: '2026-12-31',
);

DateTime d(int month, int day) => DateTime(2026, month, day);

ScheduleRule everyN(int exerciseId, int n, String start) => ScheduleRule(
  id: 0,
  exerciseId: exerciseId,
  type: ScheduleType.everyNDays,
  intervalDays: n,
  startDate: start,
);

Session row(int exerciseId, String date, {double? actualTotal}) => Session(
  id: 0,
  exerciseId: exerciseId,
  date: date,
  actualTotal: actualTotal,
);

void main() {
  group('buildDaySessions', () {
    final rules = [
      everyN(running, 2, '2026-10-01'),
      everyN(squats, 2, '2026-10-02'),
    ];

    test('scheduled days appear even without a stored row', () {
      final result = buildDaySessions(
        exercises: [runningEx, squatsEx],
        rules: rules,
        sessions: const [],
        from: d(10, 1),
        to: d(10, 2),
        today: d(10, 5),
      );
      expect(result.map((s) => (s.date, s.exercise.id)),
          [(d(10, 1), running), (d(10, 2), squats)]);
      expect(result.every((s) => s.status == SessionStatus.missed), isTrue);
    });

    test('an extra workout on an unscheduled day is included and flagged',
            () {
          final result = buildDaySessions(
            exercises: [runningEx, squatsEx],
            rules: rules,
            sessions: [row(running, '2026-10-02', actualTotal: 2)],
            from: d(10, 2),
            to: d(10, 2),
            today: d(10, 2),
          );
          expect(result.map((s) => (s.exercise.id, s.scheduled)),
              [(running, false), (squats, true)]);
        });

    test('rows outside the range are ignored', () {
      final result = buildDaySessions(
        exercises: [runningEx],
        rules: const [],
        sessions: [row(running, '2026-10-09', actualTotal: 1)],
        from: d(10, 1),
        to: d(10, 5),
        today: d(10, 5),
      );
      expect(result, isEmpty);
    });
  });

  test('totalsFromSets sums the total and takes the biggest set', () {
    final t = totalsFromSets([40, 30, 25]);
    expect(t.total, 95);
    expect(t.continuous, 40);
  });

  group('actions', () {
    late AppDatabase db;
    late ProviderContainer container;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      container = ProviderContainer(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
      );
    });

    tearDown(() async {
      container.dispose();
      await db.close();
    });

    test('setTargetsForNext skips days that are already logged', () async {
      await container.read(scheduleActionsProvider).addEveryNDays(
          exerciseId: running, intervalDays: 2, start: d(10, 1));
      final actions = container.read(sessionActionsProvider);
      await actions.log(running, d(10, 1), total: 1);

      final days = await actions.setTargetsForNext(
          exerciseId: running, from: d(10, 1), count: 3, total: 1);

      expect(days, [d(10, 3), d(10, 5), d(10, 7)]);
      final logged =
      await SessionRepository(db).find(running, d(10, 1));
      expect(logged!.targetTotal, isNull); // Left untouched.
    });

    test('setTargetsForNext treats a running-only log as logged, and sets '
        'running targets', () async {
      await container.read(scheduleActionsProvider).addEveryNDays(
          exerciseId: running, intervalDays: 2, start: d(10, 1));
      final actions = container.read(sessionActionsProvider);
      await actions.log(running, d(10, 1), running: 2);

      final days = await actions.setTargetsForNext(
          exerciseId: running, from: d(10, 1), count: 1,
          total: 6, running: 4, continuous: 1.5);

      expect(days, [d(10, 3)]);
      final s = (await SessionRepository(db).find(running, d(10, 3)))!;
      expect((s.targetTotal, s.targetRunning, s.targetContinuous),
          (6.0, 4.0, 1.5));
    });

    test('log derives totals from sets and trims the note', () async {
      final actions = container.read(sessionActionsProvider);
      await actions.log(squats, d(10, 2), sets: [40, 30, 25], note: '  ok  ');
      final s = await SessionRepository(db).find(squats, d(10, 2));
      expect(s!.actualTotal, 95);
      expect(s.actualContinuous, 40);
      expect(s.setList, [40, 30, 25]);
      expect(s.note, 'ok');
    });

    test('replacing a rule ends the old one the day before', () async {
      final schedule = container.read(scheduleActionsProvider);
      final oldId = await schedule.addEveryNDays(
          exerciseId: running, intervalDays: 2, start: d(10, 1));
      await schedule.replaceWithEveryNDays(
          oldRuleId: oldId, exerciseId: running, intervalDays: 3,
          from: d(10, 10));

      final rules = await container.read(scheduleRuleRepositoryProvider)
          .getAll();
      expect(rules.map((r) => (r.startDate, r.endDate)), [
        ('2026-10-01', '2026-10-09'),
        ('2026-10-10', null),
      ]);
    });
  });
}