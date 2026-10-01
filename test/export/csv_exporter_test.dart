import 'package:flutter_test/flutter_test.dart';
import 'package:personal_trainer/database/app_database.dart';
import 'package:personal_trainer/database/tables.dart';
import 'package:personal_trainer/export/csv_exporter.dart';

const runningEx = Exercise(
  id: 1, name: 'Running', unit: 'km',
  goalTotal: 5, goalContinuous: 2, deadline: '2026-12-31',
);
const squatsEx = Exercise(
  id: 2, name: 'Squats', unit: 'reps',
  goalTotal: 1000, goalContinuous: 200, deadline: '2026-12-31',
);

final today = DateTime(2026, 10, 10);

List<String> lines(String csv) => csv.split('\r\n');

void main() {
  group('sessions', () {
    test('header, then rows oldest first with dd/MM/yyyy dates', () {
      final csv = sessionsCsv(
        const [
          Session(id: 2, exerciseId: 2, date: '2026-10-05', targetTotal: 50),
          Session(
            id: 1, exerciseId: 1, date: '2026-10-03',
            targetTotal: 2, targetContinuous: 1,
            actualTotal: 2.5, actualContinuous: 1,
          ),
        ],
        [runningEx, squatsEx],
        today,
      );

      expect(lines(csv), [
        'Date,Exercise,Target total,Target running,Target continuous,'
            'Actual total,Actual running,Actual continuous,Sets,Status,Note',
        '03/10/2026,Running,2,,1,2.5,,1,,Overachieved,',
        '05/10/2026,Squats,50,,,,,,,Missed,',
        '',
      ]);
    });

    test('sets are listed and quoted; override wins over computed status', () {
      final csv = sessionsCsv(
        const [
          Session(
            id: 1, exerciseId: 2, date: '2026-10-03',
            targetTotal: 200,
            actualTotal: 95, actualContinuous: 40, sets: '[40,30,25]',
            statusOverride: SessionStatus.done,
          ),
        ],
        [runningEx, squatsEx],
        today,
      );

      expect(lines(csv)[1],
          '03/10/2026,Squats,200,,,95,,40,"40, 30, 25",Done,');
    });

    test('a future day with only a target is upcoming', () {
      final csv = sessionsCsv(
        const [Session(id: 1, exerciseId: 1, date: '2026-10-12', targetTotal: 3)],
        [runningEx],
        today,
      );
      expect(lines(csv)[1], '12/10/2026,Running,3,,,,,,,Upcoming,');
    });

    test('running distance has its own columns', () {
      final csv = sessionsCsv(
        const [
          Session(
            id: 1, exerciseId: 1, date: '2026-10-03',
            targetTotal: 6, targetRunning: 4, targetContinuous: 1.5,
            actualTotal: 6.2, actualRunning: 4, actualContinuous: 1.5,
          ),
        ],
        [runningEx],
        today,
      );
      expect(lines(csv)[1], '03/10/2026,Running,6,4,1.5,6.2,4,1.5,,Overachieved,');
    });
  });

  group('weight', () {
    test('rows oldest first', () {
      final csv = weightCsv(const [
        WeightEntry(date: '2026-10-02', kg: 88.4),
        WeightEntry(date: '2026-10-01', kg: 88.75, note: 'after run'),
      ]);
      expect(lines(csv), [
        'Date,Kg,Note',
        '01/10/2026,88.75,after run',
        '02/10/2026,88.4,',
        '',
      ]);
    });

    test('notes with commas, quotes and line breaks are escaped', () {
      final csv = weightCsv(const [
        WeightEntry(date: '2026-10-01', kg: 88, note: 'ate late, "big" dinner'),
        WeightEntry(date: '2026-10-02', kg: 88, note: 'line one\nline two'),
      ]);
      expect(csv, contains('01/10/2026,88,"ate late, ""big"" dinner"\r\n'));
      expect(csv, contains('02/10/2026,88,"line one\nline two"\r\n'));
    });
  });
}
