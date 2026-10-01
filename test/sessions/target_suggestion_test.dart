import 'package:flutter_test/flutter_test.dart';
import 'package:personal_trainer/database/app_database.dart';
import 'package:personal_trainer/sessions/target_suggestion.dart';

const runningEx = Exercise(
  id: 1,
  name: 'Running',
  unit: 'km',
  goalTotal: 5,
  goalContinuous: 2,
  deadline: '2026-12-31',
);

const pushUpsEx = Exercise(
  id: 3,
  name: 'Push-ups',
  unit: 'reps',
  goalTotal: 200,
  goalContinuous: 50,
  deadline: '2026-12-31',
);

/// Running as seeded from schema 2: total is walking + running.
const runningWithDistanceEx = Exercise(
  id: 1,
  name: 'Running',
  unit: 'km',
  goalTotal: 8,
  goalContinuous: 2,
  goalRunning: 5,
  deadline: '2026-12-31',
);

Session logged({
  int exerciseId = 1,
  double? targetTotal,
  double? targetContinuous,
  double? targetRunning,
  double? actualTotal,
  double? actualContinuous,
  double? actualRunning,
}) =>
    Session(
      id: 1,
      exerciseId: exerciseId,
      date: '2026-10-05',
      targetTotal: targetTotal,
      targetContinuous: targetContinuous,
      targetRunning: targetRunning,
      actualTotal: actualTotal,
      actualContinuous: actualContinuous,
      actualRunning: actualRunning,
    );

void main() {
  test('no history gives no suggestion', () {
    expect(
      suggestTarget(
          exercise: runningEx, recentLogged: const [], remainingSessions: 20),
      isNull,
    );
  });

  test('meeting targets steps up along the ramp to the goal', () {
    final s = suggestTarget(
      exercise: runningEx,
      recentLogged: [
        logged(
            targetTotal: 1, targetContinuous: 0.5,
            actualTotal: 1, actualContinuous: 0.5),
      ],
      remainingSessions: 20,
    )!;
    // Total: 1 + (5 - 1) / 20 = 1.2. Continuous: 0.5 + 1.5 / 20 = 0.575 → 0.6.
    expect(s.total, 1.2);
    expect(s.continuous, 0.6);
  });

  test('falling short repeats that target, the other metric still steps up',
          () {
        final s = suggestTarget(
          exercise: runningEx,
          recentLogged: [
            logged(
                targetTotal: 3, targetContinuous: 2,
                actualTotal: 3, actualContinuous: 1.5),
          ],
          remainingSessions: 20,
        )!;
        expect(s.total, 3.1);
        expect(s.continuous, 2);
      });

  test('overachieving steps up from what you actually did', () {
    final s = suggestTarget(
      exercise: runningEx,
      recentLogged: [logged(targetTotal: 1, actualTotal: 1.5)],
      remainingSessions: 35,
    )!;
    // 1.5 + 3.5 / 35 = 1.6.
    expect(s.total, 1.6);
  });

  test('a step too small to round still moves forward one increment', () {
    final s = suggestTarget(
      exercise: pushUpsEx,
      recentLogged: [
        logged(exerciseId: 3, targetContinuous: 49, actualContinuous: 49),
      ],
      remainingSessions: 30,
    )!;
    expect(s.continuous, 50);
  });

  test('a reached goal holds at the goal', () {
    final s = suggestTarget(
      exercise: pushUpsEx,
      recentLogged: [
        logged(exerciseId: 3, targetContinuous: 50, actualContinuous: 52),
      ],
      remainingSessions: 10,
    )!;
    expect(s.continuous, 50);
  });

  test('the last session before the deadline suggests the goal', () {
    final s = suggestTarget(
      exercise: runningEx,
      recentLogged: [logged(targetTotal: 4, actualTotal: 4)],
      remainingSessions: 1,
    )!;
    expect(s.total, 5);
  });

  test('the total is raised so it is never below the continuous target', () {
    final s = suggestTarget(
      exercise: runningEx,
      recentLogged: [
        logged(targetTotal: 1, actualTotal: 0.8, actualContinuous: 0.8),
      ],
      remainingSessions: 2,
    )!;
    // Total repeats 1 (fell short). Continuous: 0.8 + 1.2 / 2 = 1.4.
    expect(s.continuous, 1.4);
    expect(s.total, 1.4);
  });

  group('running distance', () {
    test('steps up along its own ramp to the running goal', () {
      final s = suggestTarget(
        exercise: runningWithDistanceEx,
        recentLogged: [
          logged(
            targetTotal: 4, targetRunning: 2, targetContinuous: 1,
            actualTotal: 4, actualRunning: 2, actualContinuous: 1,
          ),
        ],
        remainingSessions: 10,
      )!;
      // Total: 4 + 4/10 = 4.4. Running: 2 + 3/10 = 2.3. Continuous: 1.1.
      expect((s.total, s.running, s.continuous), (4.4, 2.3, 1.1));
    });

    test('running is raised to cover continuous, and total to cover running',
        () {
      final s = suggestTarget(
        exercise: runningWithDistanceEx,
        // Fell short on total and running (they repeat); continuous steps up.
        recentLogged: [
          logged(
            targetTotal: 1.5, targetRunning: 1.5,
            actualTotal: 1.2, actualRunning: 1.2, actualContinuous: 1.2,
          ),
        ],
        remainingSessions: 2,
      )!;
      // Continuous: 1.2 + 0.8/2 = 1.6, above the repeated 1.5 for both.
      expect((s.total, s.running, s.continuous), (1.6, 1.6, 1.6));
    });

    test('exercises without a running goal never get a running suggestion', () {
      final s = suggestTarget(
        exercise: pushUpsEx,
        recentLogged: [logged(exerciseId: 3, actualTotal: 50, actualRunning: 9)],
        remainingSessions: 10,
      )!;
      expect(s.running, isNull);
    });
  });
}
