import '../core/dates.dart';
import '../database/app_database.dart';
import '../database/tables.dart';

class ScheduledDay {
  final DateTime date;
  final int exerciseId;

  const ScheduledDay(this.date, this.exerciseId);

  @override
  String toString() => 'ScheduledDay(${formatDate(date)}, exercise $exerciseId)';
}

/// Builds a weekday mask from Dart weekdays (DateTime.monday = 1 ... sunday = 7).
int weekdayMaskOf(Set<int> weekdays) =>
    weekdays.fold(0, (mask, w) => mask | (1 << (w - 1)));

bool isRuleActiveOn(ScheduleRule rule, DateTime day) {
  final start = parseDay(rule.startDate);
  if (day.isBefore(start)) return false;
  if (rule.endDate != null && day.isAfter(parseDay(rule.endDate!))) {
    return false;
  }

  switch (rule.type) {
    case ScheduleType.everyNDays:
      final interval = rule.intervalDays ?? 1;
      return daysBetween(start, day) % interval == 0;
    case ScheduleType.weekdays:
      final mask = rule.weekdayMask ?? 0;
      return mask & (1 << (day.weekday - 1)) != 0;
  }
}

/// Every scheduled (day, exercise) pair from [from] to [to], inclusive.
/// If two rules for the same exercise land on the same day, it counts once.
List<ScheduledDay> occurrencesBetween(
    List<ScheduleRule> rules,
    DateTime from,
    DateTime to,
    ) {
  final result = <ScheduledDay>[];
  for (var day = from; !day.isAfter(to); day = addDays(day, 1)) {
    final seen = <int>{};
    for (final rule in rules) {
      if (seen.contains(rule.exerciseId)) continue;
      if (isRuleActiveOn(rule, day)) {
        seen.add(rule.exerciseId);
        result.add(ScheduledDay(day, rule.exerciseId));
      }
    }
  }
  return result;
}

/// The next [count] scheduled dates for one exercise, starting from [from]
/// (inclusive). Stops after [maxDays] so a broken rule can't loop forever.
List<DateTime> nextOccurrences(
    List<ScheduleRule> rules,
    int exerciseId,
    DateTime from,
    int count, {
      int maxDays = 366,
    }) {
  final ownRules = rules.where((r) => r.exerciseId == exerciseId).toList();
  final result = <DateTime>[];
  var day = from;
  for (var i = 0; i < maxDays && result.length < count; i++) {
    if (ownRules.any((r) => isRuleActiveOn(r, day))) result.add(day);
    day = addDays(day, 1);
  }
  return result;
}

/// Reverse of weekdayMaskOf.
Set<int> weekdaysOf(int mask) => {
  for (var w = DateTime.monday; w <= DateTime.sunday; w++)
    if (mask & (1 << (w - 1)) != 0) w,
};