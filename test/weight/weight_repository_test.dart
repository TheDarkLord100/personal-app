import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_trainer/database/app_database.dart';
import 'package:personal_trainer/weight/weight_repository.dart';

DateTime d(int month, int day) => DateTime(2026, month, day);

void main() {
  late AppDatabase db;
  late WeightRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = WeightRepository(db);
  });

  tearDown(() => db.close());

  test('logging twice on one day keeps only the latest reading', () async {
    await repo.log(d(10, 5), 91.2);
    await repo.log(d(10, 5), 90.8, note: 'after run');
    final all = await repo.all();
    expect(all, hasLength(1));
    expect(all.single.kg, 90.8);
    expect(all.single.note, 'after run');
  });

  test('latest returns the most recent day, not the most recent write',
          () async {
        await repo.log(d(10, 7), 90.5);
        await repo.log(d(10, 3), 91.0); // Backfilled later.
        expect((await repo.latest())!.date, '2026-10-07');
      });

  test('latest is null with no entries', () async {
    expect(await repo.latest(), isNull);
  });

  test('watchBetween returns entries in range, oldest first', () async {
    await repo.log(d(10, 9), 90.0);
    await repo.log(d(10, 2), 91.0);
    await repo.log(d(10, 20), 89.0);
    final inRange = await repo.watchBetween(d(10, 1), d(10, 10)).first;
    expect(inRange.map((w) => w.date), ['2026-10-02', '2026-10-09']);
  });

  test('delete removes that day only', () async {
    await repo.log(d(10, 2), 91.0);
    await repo.log(d(10, 3), 90.8);
    await repo.delete(d(10, 2));
    expect((await repo.all()).map((w) => w.date), ['2026-10-03']);
  });
}