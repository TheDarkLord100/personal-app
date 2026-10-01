import 'dart:math' as math;

import '../core/constants.dart';
import '../core/dates.dart';
import '../database/app_database.dart';

class MetricProgress {
  const MetricProgress({required this.goal, this.best, this.expectedToday});

  final double goal;

  /// Best value logged so far, or null if nothing logged yet.
  final double? best;

  /// Where a straight line from your first logged value to the goal on the
  /// deadline says you should be today.
  final double? expectedToday;

  double get fraction => best == null ? 0 : (best! / goal).clamp(0.0, 1.0);

  bool? get onTrack => (best == null || expectedToday == null)
      ? null
      : best! >= expectedToday! - 1e-6;
}

class ExerciseProgress {
  const ExerciseProgress({
    required this.total,
    required this.continuous,
    this.running,
  });

  final MetricProgress total;
  final MetricProgress continuous;

  /// Null for exercises without a running goal.
  final MetricProgress? running;
}

ExerciseProgress progressFor(
    Exercise exercise,
    List<Session> sessions,
    DateTime today,
    ) {
  final own = sessions
      .where((s) =>
  s.exerciseId == exercise.id && !parseDay(s.date).isAfter(today))
      .toList()
    ..sort((a, b) => a.date.compareTo(b.date));
  final deadline = parseDay(exercise.deadline);

  return ExerciseProgress(
    total: _metric(
      own.map((s) => (s.date, s.actualTotal)),
      exercise.goalTotal,
      deadline,
      today,
    ),
    continuous: _metric(
      own.map((s) => (s.date, s.actualContinuous)),
      exercise.goalContinuous,
      deadline,
      today,
    ),
    running: exercise.goalRunning == null
        ? null
        : _metric(
            own.map((s) => (s.date, s.actualRunning)),
            exercise.goalRunning!,
            deadline,
            today,
          ),
  );
}

MetricProgress _metric(
    Iterable<(String, double?)> values,
    double goal,
    DateTime deadline,
    DateTime today,
    ) {
  // Zeros are skipped days, not a baseline.
  final logged = values.where((v) => v.$2 != null && v.$2! > 0).toList();
  if (logged.isEmpty) return MetricProgress(goal: goal);

  final best = logged.map((v) => v.$2!).reduce(math.max);
  final firstDate = parseDay(logged.first.$1);
  final startValue = logged.first.$2!;

  final span = daysBetween(firstDate, deadline);
  final double expected;
  if (span <= 0) {
    expected = goal;
  } else {
    final t = (daysBetween(firstDate, today) / span).clamp(0.0, 1.0);
    expected = startValue + (goal - startValue) * t;
  }

  return MetricProgress(goal: goal, best: best, expectedToday: expected);
}

class WeightPoint {
  const WeightPoint(this.date, this.kg, this.average);

  final DateTime date;
  final double kg;
  final double average;
}

/// Each entry with the average of all entries in the [windowDays] calendar
/// days ending on it. Calendar days, not entry count, so gaps in logging
/// don't stretch the window.
List<WeightPoint> withMovingAverage(
    List<WeightEntry> entries, {
      int windowDays = weightAverageWindowDays,
    }) {
  final sorted = [...entries]..sort((a, b) => a.date.compareTo(b.date));
  final points = <WeightPoint>[];

  for (var i = 0; i < sorted.length; i++) {
    final day = parseDay(sorted[i].date);
    final windowStart = addDays(day, -(windowDays - 1));
    var sum = 0.0;
    var count = 0;
    for (var j = i; j >= 0; j--) {
      if (parseDay(sorted[j].date).isBefore(windowStart)) break;
      sum += sorted[j].kg;
      count++;
    }
    points.add(WeightPoint(day, sorted[i].kg, sum / count));
  }
  return points;
}

class WeightPace {
  const WeightPace({
    required this.currentAverage,
    this.kgPerWeekNeeded,
    this.kgPerWeekRecent,
  });

  final double currentAverage;

  /// Weekly change needed to reach the goal by the deadline.
  /// Negative means losing. Null once the deadline has passed.
  final double? kgPerWeekNeeded;

  /// Weekly change over roughly the last week of averages.
  /// Null until there's at least a week of data.
  final double? kgPerWeekRecent;
}

WeightPace? weightPace(
    List<WeightPoint> points, {
      required DateTime deadline,
      required DateTime today,
      double goalKg = weightGoalKg,
    }) {
  if (points.isEmpty) return null;

  final latest = points.last;
  final daysLeft = daysBetween(today, deadline);
  final needed =
  daysLeft > 0 ? (goalKg - latest.average) / (daysLeft / 7) : null;

  final weekAgo = addDays(latest.date, -7);
  WeightPoint? earlier;
  for (final p in points) {
    if (!p.date.isAfter(weekAgo)) earlier = p;
  }
  final recent = earlier == null
      ? null
      : (latest.average - earlier.average) /
      (daysBetween(earlier.date, latest.date) / 7);

  return WeightPace(
    currentAverage: latest.average,
    kgPerWeekNeeded: needed,
    kgPerWeekRecent: recent,
  );
}