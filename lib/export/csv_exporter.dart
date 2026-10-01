import '../core/dates.dart';
import '../core/format.dart';
import '../database/app_database.dart';
import '../database/tables.dart';
import '../sessions/session_repository.dart';
import '../sessions/session_status.dart';

// Pure: builds CSV text from rows. Saving the file happens in the UI.

const _sessionHeader = [
  'Date',
  'Exercise',
  'Target total',
  'Target continuous',
  'Actual total',
  'Actual continuous',
  'Sets',
  'Status',
  'Note',
];

/// One row per stored session (days with a target or a log), oldest first.
/// Status is computed as of [today], with any override applied.
String sessionsCsv(
    List<Session> sessions,
    List<Exercise> exercises,
    DateTime today,
    ) {
  final names = {for (final e in exercises) e.id: e.name};
  final sorted = [...sessions]..sort((a, b) {
    final byDate = a.date.compareTo(b.date);
    return byDate != 0 ? byDate : a.exerciseId.compareTo(b.exerciseId);
  });

  return _csv([
    _sessionHeader,
    for (final s in sorted)
      [
        formatDayKey(s.date),
        names[s.exerciseId] ?? 'Exercise ${s.exerciseId}',
        _num(s.targetTotal),
        _num(s.targetContinuous),
        _num(s.actualTotal),
        _num(s.actualContinuous),
        s.setList.map(formatNumber).join(', '),
        _statusText(statusFor(s, parseDay(s.date), today)),
        s.note ?? '',
      ],
  ]);
}

/// One row per weight reading, oldest first.
String weightCsv(List<WeightEntry> entries) {
  final sorted = [...entries]..sort((a, b) => a.date.compareTo(b.date));
  return _csv([
    ['Date', 'Kg', 'Note'],
    for (final w in sorted) [formatDayKey(w.date), formatNumber(w.kg), w.note ?? ''],
  ]);
}

String _num(double? v) => v == null ? '' : formatNumber(v);

String _statusText(SessionStatus? status) => switch (status) {
  null => 'Upcoming',
  SessionStatus.missed => 'Missed',
  SessionStatus.partial => 'Partial',
  SessionStatus.done => 'Done',
  SessionStatus.overachieved => 'Overachieved',
};

/// RFC 4180: CRLF line endings; fields containing a comma, quote or line
/// break are wrapped in quotes, with quotes doubled.
String _csv(List<List<String>> rows) =>
    '${rows.map((r) => r.map(_field).join(',')).join('\r\n')}\r\n';

String _field(String value) {
  if (!value.contains(RegExp(r'[",\r\n]'))) return value;
  return '"${value.replaceAll('"', '""')}"';
}
