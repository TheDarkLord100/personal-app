import '../database/app_database.dart';
import '../database/tables.dart';

const _epsilon = 1e-6;

/// Status of a scheduled day for one exercise.
///
/// [session] is null when the day is scheduled but has no row yet
/// (no target set, nothing logged). Returns null for days that aren't
/// due yet: today or later with nothing logged.
SessionStatus? statusFor(Session? session, DateTime date, DateTime today) {
  final override = session?.statusOverride;
  if (override != null) return override;

  if (session == null || !_hasActuals(session)) {
    return date.isBefore(today) ? SessionStatus.missed : null;
  }

  final actualTotal = session.actualTotal ?? 0;
  final actualContinuous = session.actualContinuous ?? 0;
  final actualRunning = session.actualRunning ?? 0;
  if (actualTotal <= _epsilon &&
      actualContinuous <= _epsilon &&
      actualRunning <= _epsilon) {
    return SessionStatus.missed;
  }

  final comparisons = <int>[
    if (session.targetTotal != null)
      _compare(actualTotal, session.targetTotal!),
    if (session.targetRunning != null)
      _compare(actualRunning, session.targetRunning!),
    if (session.targetContinuous != null)
      _compare(actualContinuous, session.targetContinuous!),
  ];

  if (comparisons.isEmpty) return SessionStatus.done;
  if (comparisons.any((c) => c < 0)) return SessionStatus.partial;
  if (comparisons.any((c) => c > 0)) return SessionStatus.overachieved;
  return SessionStatus.done;
}

bool _hasActuals(Session s) =>
    s.actualTotal != null ||
    s.actualContinuous != null ||
    s.actualRunning != null;

int _compare(double actual, double target) {
  if (actual < target - _epsilon) return -1;
  if (actual > target + _epsilon) return 1;
  return 0;
}