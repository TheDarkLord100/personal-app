import 'package:flutter_test/flutter_test.dart';
import 'package:personal_trainer/database/app_database.dart';
import 'package:personal_trainer/database/tables.dart';
import 'package:personal_trainer/schedule/schedule_engine.dart';

const running = 1;
const strength = 2;

ScheduleRule everyN(int exerciseId, int n, String start, {String? end}) =>
    ScheduleRule(
      id: 0,
      exerciseId: exerciseId,
      type: ScheduleType.everyNDays,
      intervalDays: n,
      startDate: start,
      endDate: end,
    );

ScheduleRule onWeekdays(int exerciseId, Set<int> days, String start) =>
    ScheduleRule(
      id: 0,
      exerciseId: exerciseId,
      type: ScheduleType.weekdays,
      weekdayMask: weekdayMaskOf(days),
      startDate: start,
    );

DateTime d(int month, int day) => DateTime(2026, month, day);

List<DateTime> datesFor(List<ScheduledDay> days, int exerciseId) =>
    days.where((s) => s.exerciseId == exerciseId).map((s) => s.date).toList();

void main() {
  test('every 2 days includes the start date and skips alternate days', () {
    final rules = [everyN(running, 2, '2026-10-01')];
    final result = occurrencesBetween(rules, d(10, 1), d(10, 7));
    expect(datesFor(result, running), [d(10, 1), d(10, 3), d(10, 5), d(10, 7)]);
  });

  test('offset start dates interleave two exercises', () {
    final rules = [
      everyN(running, 2, '2026-10-01'),
      everyN(strength, 2, '2026-10-02'),
    ];
    final result = occurrencesBetween(rules, d(10, 1), d(10, 4));
    expect(datesFor(result, running), [d(10, 1), d(10, 3)]);
    expect(datesFor(result, strength), [d(10, 2), d(10, 4)]);
  });

  test('nothing is scheduled before the start date', () {
    final rules = [everyN(running, 2, '2026-10-05')];
    final result = occurrencesBetween(rules, d(10, 1), d(10, 4));
    expect(result, isEmpty);
  });

  test('crosses month boundaries correctly', () {
    final rules = [everyN(running, 2, '2026-10-29')];
    final result = occurrencesBetween(rules, d(10, 29), d(11, 4));
    expect(datesFor(result, running), [d(10, 29), d(10, 31), d(11, 2), d(11, 4)]);
  });

  test('a rule change keeps the old schedule before and the new one after', () {
    final rules = [
      everyN(running, 2, '2026-10-01', end: '2026-10-05'),
      everyN(running, 3, '2026-10-06'),
    ];
    final result = occurrencesBetween(rules, d(10, 1), d(10, 12));
    expect(datesFor(result, running),
        [d(10, 1), d(10, 3), d(10, 5), d(10, 6), d(10, 9), d(10, 12)]);
  });

  test('weekday rules match only the chosen days', () {
    // 5 Oct 2026 is a Monday.
    final rules = [
      onWeekdays(strength, {DateTime.monday, DateTime.wednesday, DateTime.friday},
          '2026-10-05'),
    ];
    final result = occurrencesBetween(rules, d(10, 5), d(10, 11));
    expect(datesFor(result, strength), [d(10, 5), d(10, 7), d(10, 9)]);
  });

  test('overlapping rules for one exercise give one session per day', () {
    final rules = [
      everyN(running, 1, '2026-10-01'),
      everyN(running, 2, '2026-10-01'),
    ];
    final result = occurrencesBetween(rules, d(10, 1), d(10, 2));
    expect(datesFor(result, running), [d(10, 1), d(10, 2)]);
  });

  test('nextOccurrences returns the next N dates, including today', () {
    final rules = [
      everyN(running, 2, '2026-10-01'),
      everyN(strength, 2, '2026-10-02'),
    ];
    expect(nextOccurrences(rules, running, d(10, 3), 3),
        [d(10, 3), d(10, 5), d(10, 7)]);
    expect(nextOccurrences(rules, running, d(10, 4), 2),
        [d(10, 5), d(10, 7)]);
  });

  test('weekdaysOf reverses weekdayMaskOf', () {
    final days = {DateTime.monday, DateTime.thursday, DateTime.sunday};
    expect(weekdaysOf(weekdayMaskOf(days)), days);
  });
}

