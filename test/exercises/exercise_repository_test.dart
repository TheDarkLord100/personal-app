import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_trainer/database/app_database.dart';
import 'package:personal_trainer/exercises/exercise_repository.dart';

const pushUps = 3;

void main() {
  late AppDatabase db;
  late ExerciseRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = ExerciseRepository(db);
  });

  tearDown(() => db.close());

  test('updateGoal changes only the fields passed', () async {
    await repo.updateGoal(pushUps, goalContinuous: 60);
    final e = (await repo.getAll()).firstWhere((e) => e.id == pushUps);
    expect(e.goalContinuous, 60);
    expect(e.goalTotal, 200);
    expect(e.deadline, '2026-12-31');
  });

  test('a new exercise is added after the seeded ones', () async {
    await repo.add(
      name: 'Plank',
      unit: 'sec',
      goalTotal: 300,
      goalContinuous: 120,
      deadline: DateTime(2026, 12, 31),
    );
    final names = (await repo.getAll()).map((e) => e.name);
    expect(names, ['Running', 'Squats', 'Push-ups', 'Plank']);
  });
}