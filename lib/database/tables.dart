import 'package:drift/drift.dart';

// Stored as ints by index. Only ever append new values; never reorder.
enum ScheduleType { everyNDays, weekdays }
enum SessionStatus { missed, partial, done, overachieved }

class Exercises extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get unit => text()(); // 'km' or 'reps'
  RealColumn get goalTotal => real()();
  RealColumn get goalContinuous => real()();
  // Only for exercises with a third metric (Running: distance actually run,
  // between total and continuous). Null = the exercise doesn't use it.
  RealColumn get goalRunning => real().nullable()(); // added in schema 2
  TextColumn get deadline => text()(); // yyyy-MM-dd
}

class ScheduleRules extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get exerciseId => integer().references(Exercises, #id)();
  IntColumn get type => intEnum<ScheduleType>()();
  IntColumn get intervalDays => integer().nullable()(); // everyNDays
  IntColumn get weekdayMask => integer().nullable()(); // weekdays; bit 0 = Monday
  TextColumn get startDate => text()(); // yyyy-MM-dd
  TextColumn get endDate => text().nullable()(); // null = open-ended
}

@TableIndex(
  name: 'session_exercise_day',
  columns: {#exerciseId, #date},
  unique: true,
)
class Sessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get exerciseId => integer().references(Exercises, #id)();
  TextColumn get date => text()(); // yyyy-MM-dd
  RealColumn get targetTotal => real().nullable()();
  RealColumn get targetContinuous => real().nullable()();
  RealColumn get actualTotal => real().nullable()();
  RealColumn get actualContinuous => real().nullable()();
  RealColumn get targetRunning => real().nullable()(); // added in schema 2
  RealColumn get actualRunning => real().nullable()(); // added in schema 2
  TextColumn get sets => text().nullable()(); // JSON, e.g. "[40,30,25]"
  TextColumn get note => text().nullable()();
  IntColumn get statusOverride => intEnum<SessionStatus>().nullable()();
}

class WeightEntries extends Table {
  TextColumn get date => text()(); // yyyy-MM-dd
  RealColumn get kg => real()();
  TextColumn get note => text().nullable()();

  @override
  Set<Column> get primaryKey => {date};
}