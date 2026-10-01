// Dates are stored as 'yyyy-MM-dd' text (sorts correctly as a string)
// and shown to the user as 'dd/MM/yyyy'.

String dayKey(DateTime d) =>
    '${_pad(d.year, 4)}-${_pad(d.month)}-${_pad(d.day)}';

DateTime parseDay(String key) {
  final parts = key.split('-');
  return DateTime(
    int.parse(parts[0]),
    int.parse(parts[1]),
    int.parse(parts[2]),
  );
}

String formatDate(DateTime d) =>
    '${_pad(d.day)}/${_pad(d.month)}/${_pad(d.year, 4)}';

String formatDayKey(String key) => formatDate(parseDay(key));

DateTime today() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}

DateTime addDays(DateTime d, int days) =>
    DateTime(d.year, d.month, d.day + days);

int daysBetween(DateTime from, DateTime to) =>
    DateTime.utc(to.year, to.month, to.day)
        .difference(DateTime.utc(from.year, from.month, from.day))
        .inDays;

String _pad(int value, [int width = 2]) =>
    value.toString().padLeft(width, '0');

const _weekdayNames = [
  'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday',
];

/// e.g. "Thursday, 01/10/2026"
String formatLongDate(DateTime d) =>
    '${_weekdayNames[d.weekday - 1]}, ${formatDate(d)}';

const _weekdayShortNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

String weekdayShort(int weekday) => _weekdayShortNames[weekday - 1];

/// e.g. "Thu 01/10"
String formatShortDate(DateTime d) =>
    '${weekdayShort(d.weekday)} ${_pad(d.day)}/${_pad(d.month)}';