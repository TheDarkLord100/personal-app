import 'package:flutter_test/flutter_test.dart';
import 'package:personal_trainer/database/app_database.dart';
import 'package:personal_trainer/database/tables.dart';
import 'package:personal_trainer/sessions/session_status.dart';

final today = DateTime(2026, 10, 10);
final yesterday = DateTime(2026, 10, 9);
final tomorrow = DateTime(2026, 10, 11);

Session session({
  double? targetTotal,
  double? targetContinuous,
  double? targetRunning,
  double? actualTotal,
  double? actualContinuous,
  double? actualRunning,
  SessionStatus? override,
}) =>
    Session(
      id: 1,
      exerciseId: 1,
      date: '2026-10-09',
      targetTotal: targetTotal,
      targetContinuous: targetContinuous,
      targetRunning: targetRunning,
      actualTotal: actualTotal,
      actualContinuous: actualContinuous,
      actualRunning: actualRunning,
      statusOverride: override,
    );

void main() {
  group('nothing logged', () {
    test('a past day with no session is missed', () {
      expect(statusFor(null, yesterday, today), SessionStatus.missed);
    });

    test('today and future days are not due yet', () {
      expect(statusFor(null, today, today), isNull);
      expect(statusFor(null, tomorrow, today), isNull);
    });

    test('a past day with targets but no actuals is missed', () {
      final s = session(targetTotal: 5, targetContinuous: 2);
      expect(statusFor(s, yesterday, today), SessionStatus.missed);
    });

    test('a future day with targets planned is not due yet', () {
      final s = session(targetTotal: 5, targetContinuous: 2);
      expect(statusFor(s, tomorrow, today), isNull);
    });
  });

  group('logged sessions', () {
    test('meeting both targets exactly is done', () {
      final s = session(
          targetTotal: 5, targetContinuous: 2,
          actualTotal: 5, actualContinuous: 2);
      expect(statusFor(s, yesterday, today), SessionStatus.done);
    });

    test('falling short on one target is partial', () {
      final s = session(
          targetTotal: 5, targetContinuous: 2,
          actualTotal: 5, actualContinuous: 1.5);
      expect(statusFor(s, yesterday, today), SessionStatus.partial);
    });

    test('exceeding one and short on the other is still partial', () {
      final s = session(
          targetTotal: 5, targetContinuous: 2,
          actualTotal: 6, actualContinuous: 1.5);
      expect(statusFor(s, yesterday, today), SessionStatus.partial);
    });

    test('meeting both and exceeding one is overachieved', () {
      final s = session(
          targetTotal: 100, targetContinuous: 30,
          actualTotal: 100, actualContinuous: 35);
      expect(statusFor(s, yesterday, today), SessionStatus.overachieved);
    });

    test('logging zeros is missed', () {
      final s = session(targetTotal: 5, actualTotal: 0, actualContinuous: 0);
      expect(statusFor(s, yesterday, today), SessionStatus.missed);
    });

    test('only targets that are set get compared', () {
      final s = session(targetTotal: 50, actualTotal: 50, actualContinuous: 10);
      expect(statusFor(s, yesterday, today), SessionStatus.done);
    });

    test('logging with no targets counts as done', () {
      final s = session(actualTotal: 3, actualContinuous: 1);
      expect(statusFor(s, yesterday, today), SessionStatus.done);
    });

    test('logging today gives a status straight away', () {
      final s = session(targetTotal: 5, actualTotal: 4);
      expect(statusFor(s, today, today), SessionStatus.partial);
    });

    test('floating-point sums still count as meeting the target', () {
      final s = session(targetTotal: 0.3, actualTotal: 0.1 + 0.2);
      expect(statusFor(s, yesterday, today), SessionStatus.done);
    });
  });

  test('an override beats the computed status', () {
    final s = session(
        targetTotal: 5, actualTotal: 3, override: SessionStatus.done);
    expect(statusFor(s, yesterday, today), SessionStatus.done);
  });

  group('running distance', () {
    test('only running logged still counts as logged', () {
      expect(statusFor(session(actualRunning: 2), yesterday, today),
          SessionStatus.done);
    });

    test('falling short on running is partial', () {
      final s = session(
        targetTotal: 6, targetRunning: 4,
        actualTotal: 6, actualRunning: 3.5,
      );
      expect(statusFor(s, yesterday, today), SessionStatus.partial);
    });

    test('meeting all three and beating running is overachieved', () {
      final s = session(
        targetTotal: 6, targetRunning: 4, targetContinuous: 1.5,
        actualTotal: 6, actualRunning: 4.5, actualContinuous: 1.5,
      );
      expect(statusFor(s, yesterday, today), SessionStatus.overachieved);
    });

    test('zeros in all three is missed', () {
      final s = session(actualTotal: 0, actualRunning: 0, actualContinuous: 0);
      expect(statusFor(s, yesterday, today), SessionStatus.missed);
    });
  });
}
