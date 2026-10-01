import 'package:drift/drift.dart';

import '../core/dates.dart';
import '../database/app_database.dart';

class WeightRepository {
  WeightRepository(this._db);

  final AppDatabase _db;

  $WeightEntriesTable get _weights => _db.weightEntries;

  /// One entry per day. Logging again on the same day replaces it.
  Future<void> log(DateTime day, double kg, {String? note}) {
    assert(kg > 0);
    return _db.into(_weights).insertOnConflictUpdate(
      WeightEntriesCompanion.insert(
        date: dayKey(day),
        kg: kg,
        note: Value(note),
      ),
    );
  }

  Future<void> delete(DateTime day) =>
      (_db.delete(_weights)..where((w) => w.date.equals(dayKey(day)))).go();

  Stream<List<WeightEntry>> watchBetween(DateTime from, DateTime to) {
    final query = _db.select(_weights)
      ..where((w) => w.date.isBetweenValues(dayKey(from), dayKey(to)))
      ..orderBy([(w) => OrderingTerm.asc(w.date)]);
    return query.watch();
  }

  Stream<List<WeightEntry>> watchAll() {
    final query = _db.select(_weights)
      ..orderBy([(w) => OrderingTerm.asc(w.date)]);
    return query.watch();
  }

  Future<WeightEntry?> latest() {
    final query = _db.select(_weights)
      ..orderBy([(w) => OrderingTerm.desc(w.date)])
      ..limit(1);
    return query.getSingleOrNull();
  }

  Future<List<WeightEntry>> all() {
    final query = _db.select(_weights)
      ..orderBy([(w) => OrderingTerm.asc(w.date)]);
    return query.get();
  }
}