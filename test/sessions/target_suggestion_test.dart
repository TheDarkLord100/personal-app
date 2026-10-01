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

Session logged({
  int exerciseId = 1,
  double? targetTotal,
  double? targetContinuous,
  double? actualTotal,
  double? actualContinuous,
}) =>
    Session(
      id: 1,
      exerciseId: exerciseId,
      date: '2026-10-05',
      targetTotal: targetTotal,
      targetContinuous: targetContinuous,
      actualTotal: actualTotal,
      actualContinuous: actualContinuous,
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
}