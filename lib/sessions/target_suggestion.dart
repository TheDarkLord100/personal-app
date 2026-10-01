import 'dart:math' as math;

import '../database/app_database.dart';

class TargetSuggestion {
  const TargetSuggestion({this.total, this.continuous, this.running});

  final double? total;
  final double? continuous;

  /// Only for exercises with a running goal.
  final double? running;
}

/// Smallest meaningful change for a unit: 0.1 km, or 1 rep.
double incrementFor(String unit) => unit == 'km' ? 0.1 : 1;

/// Suggests targets for the next session.
///
/// [recentLogged] is newest first (as returned by
/// SessionRepository.recentLogged). [remainingSessions] counts scheduled
/// sessions from the one being suggested up to the deadline, inclusive.
TargetSuggestion? suggestTarget({
  required Exercise exercise,
  required List<Session> recentLogged,
  required int remainingSessions,
}) {
  if (recentLogged.isEmpty) return null;

  final last = recentLogged.first;
  final increment = incrementFor(exercise.unit);

  var total = _nextValue(
    target: last.targetTotal,
    actual: last.actualTotal,
    goal: exercise.goalTotal,
    remaining: remainingSessions,
    increment: increment,
  );
  final continuous = _nextValue(
    target: last.targetContinuous,
    actual: last.actualContinuous,
    goal: exercise.goalContinuous,
    remaining: remainingSessions,
    increment: increment,
  );
  var running = exercise.goalRunning == null
      ? null
      : _nextValue(
          target: last.targetRunning,
          actual: last.actualRunning,
          goal: exercise.goalRunning!,
          remaining: remainingSessions,
          increment: increment,
        );

  if (total == null && continuous == null && running == null) return null;

  // continuous <= running <= total: a continuous effort is part of the
  // running, which is part of the total. Raise the bigger ones to fit.
  if (running != null && continuous != null && continuous > running) {
    running = continuous;
  }
  final floor = running ?? continuous;
  if (total != null && floor != null && floor > total) total = floor;

  return TargetSuggestion(total: total, continuous: continuous, running: running);
}

double? _nextValue({
  required double? target,
  required double? actual,
  required double goal,
  required int remaining,
  required double increment,
}) {
  if (actual == null) return target; // Nothing logged for this metric.
  if (target != null && actual < target - 1e-6) return target; // Repeat.

  if (actual >= goal - 1e-6) return goal; // Reached: hold at goal.
  if (remaining <= 1) return goal; // Last session before the deadline.

  final step = (goal - actual) / remaining;
  var next = _roundTo(actual + step, increment);

  // Always move forward by at least one increment.
  if (next <= actual + 1e-6) next = _roundTo(actual + increment, increment);

  return math.min(next, goal);
}

/// Rounds to the nearest increment without floating-point residue,
/// so 2.3 comes out as 2.3 rather than 2.3000000000000003.
double _roundTo(double value, double increment) {
  final perUnit = (1 / increment).round();
  return (value * perUnit).round() / perUnit;
}