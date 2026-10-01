// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ExercisesTable extends Exercises
    with TableInfo<$ExercisesTable, Exercise> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExercisesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _goalTotalMeta = const VerificationMeta(
    'goalTotal',
  );
  @override
  late final GeneratedColumn<double> goalTotal = GeneratedColumn<double>(
    'goal_total',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _goalContinuousMeta = const VerificationMeta(
    'goalContinuous',
  );
  @override
  late final GeneratedColumn<double> goalContinuous = GeneratedColumn<double>(
    'goal_continuous',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _goalRunningMeta = const VerificationMeta(
    'goalRunning',
  );
  @override
  late final GeneratedColumn<double> goalRunning = GeneratedColumn<double>(
    'goal_running',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deadlineMeta = const VerificationMeta(
    'deadline',
  );
  @override
  late final GeneratedColumn<String> deadline = GeneratedColumn<String>(
    'deadline',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    unit,
    goalTotal,
    goalContinuous,
    goalRunning,
    deadline,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exercises';
  @override
  VerificationContext validateIntegrity(
    Insertable<Exercise> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    } else if (isInserting) {
      context.missing(_unitMeta);
    }
    if (data.containsKey('goal_total')) {
      context.handle(
        _goalTotalMeta,
        goalTotal.isAcceptableOrUnknown(data['goal_total']!, _goalTotalMeta),
      );
    } else if (isInserting) {
      context.missing(_goalTotalMeta);
    }
    if (data.containsKey('goal_continuous')) {
      context.handle(
        _goalContinuousMeta,
        goalContinuous.isAcceptableOrUnknown(
          data['goal_continuous']!,
          _goalContinuousMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_goalContinuousMeta);
    }
    if (data.containsKey('goal_running')) {
      context.handle(
        _goalRunningMeta,
        goalRunning.isAcceptableOrUnknown(
          data['goal_running']!,
          _goalRunningMeta,
        ),
      );
    }
    if (data.containsKey('deadline')) {
      context.handle(
        _deadlineMeta,
        deadline.isAcceptableOrUnknown(data['deadline']!, _deadlineMeta),
      );
    } else if (isInserting) {
      context.missing(_deadlineMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Exercise map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Exercise(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      )!,
      goalTotal: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}goal_total'],
      )!,
      goalContinuous: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}goal_continuous'],
      )!,
      goalRunning: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}goal_running'],
      ),
      deadline: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deadline'],
      )!,
    );
  }

  @override
  $ExercisesTable createAlias(String alias) {
    return $ExercisesTable(attachedDatabase, alias);
  }
}

class Exercise extends DataClass implements Insertable<Exercise> {
  final int id;
  final String name;
  final String unit;
  final double goalTotal;
  final double goalContinuous;
  final double? goalRunning;
  final String deadline;
  const Exercise({
    required this.id,
    required this.name,
    required this.unit,
    required this.goalTotal,
    required this.goalContinuous,
    this.goalRunning,
    required this.deadline,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['unit'] = Variable<String>(unit);
    map['goal_total'] = Variable<double>(goalTotal);
    map['goal_continuous'] = Variable<double>(goalContinuous);
    if (!nullToAbsent || goalRunning != null) {
      map['goal_running'] = Variable<double>(goalRunning);
    }
    map['deadline'] = Variable<String>(deadline);
    return map;
  }

  ExercisesCompanion toCompanion(bool nullToAbsent) {
    return ExercisesCompanion(
      id: Value(id),
      name: Value(name),
      unit: Value(unit),
      goalTotal: Value(goalTotal),
      goalContinuous: Value(goalContinuous),
      goalRunning: goalRunning == null && nullToAbsent
          ? const Value.absent()
          : Value(goalRunning),
      deadline: Value(deadline),
    );
  }

  factory Exercise.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Exercise(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      unit: serializer.fromJson<String>(json['unit']),
      goalTotal: serializer.fromJson<double>(json['goalTotal']),
      goalContinuous: serializer.fromJson<double>(json['goalContinuous']),
      goalRunning: serializer.fromJson<double?>(json['goalRunning']),
      deadline: serializer.fromJson<String>(json['deadline']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'unit': serializer.toJson<String>(unit),
      'goalTotal': serializer.toJson<double>(goalTotal),
      'goalContinuous': serializer.toJson<double>(goalContinuous),
      'goalRunning': serializer.toJson<double?>(goalRunning),
      'deadline': serializer.toJson<String>(deadline),
    };
  }

  Exercise copyWith({
    int? id,
    String? name,
    String? unit,
    double? goalTotal,
    double? goalContinuous,
    Value<double?> goalRunning = const Value.absent(),
    String? deadline,
  }) => Exercise(
    id: id ?? this.id,
    name: name ?? this.name,
    unit: unit ?? this.unit,
    goalTotal: goalTotal ?? this.goalTotal,
    goalContinuous: goalContinuous ?? this.goalContinuous,
    goalRunning: goalRunning.present ? goalRunning.value : this.goalRunning,
    deadline: deadline ?? this.deadline,
  );
  Exercise copyWithCompanion(ExercisesCompanion data) {
    return Exercise(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      unit: data.unit.present ? data.unit.value : this.unit,
      goalTotal: data.goalTotal.present ? data.goalTotal.value : this.goalTotal,
      goalContinuous: data.goalContinuous.present
          ? data.goalContinuous.value
          : this.goalContinuous,
      goalRunning: data.goalRunning.present
          ? data.goalRunning.value
          : this.goalRunning,
      deadline: data.deadline.present ? data.deadline.value : this.deadline,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Exercise(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('unit: $unit, ')
          ..write('goalTotal: $goalTotal, ')
          ..write('goalContinuous: $goalContinuous, ')
          ..write('goalRunning: $goalRunning, ')
          ..write('deadline: $deadline')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    unit,
    goalTotal,
    goalContinuous,
    goalRunning,
    deadline,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Exercise &&
          other.id == this.id &&
          other.name == this.name &&
          other.unit == this.unit &&
          other.goalTotal == this.goalTotal &&
          other.goalContinuous == this.goalContinuous &&
          other.goalRunning == this.goalRunning &&
          other.deadline == this.deadline);
}

class ExercisesCompanion extends UpdateCompanion<Exercise> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> unit;
  final Value<double> goalTotal;
  final Value<double> goalContinuous;
  final Value<double?> goalRunning;
  final Value<String> deadline;
  const ExercisesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.unit = const Value.absent(),
    this.goalTotal = const Value.absent(),
    this.goalContinuous = const Value.absent(),
    this.goalRunning = const Value.absent(),
    this.deadline = const Value.absent(),
  });
  ExercisesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String unit,
    required double goalTotal,
    required double goalContinuous,
    this.goalRunning = const Value.absent(),
    required String deadline,
  }) : name = Value(name),
       unit = Value(unit),
       goalTotal = Value(goalTotal),
       goalContinuous = Value(goalContinuous),
       deadline = Value(deadline);
  static Insertable<Exercise> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? unit,
    Expression<double>? goalTotal,
    Expression<double>? goalContinuous,
    Expression<double>? goalRunning,
    Expression<String>? deadline,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (unit != null) 'unit': unit,
      if (goalTotal != null) 'goal_total': goalTotal,
      if (goalContinuous != null) 'goal_continuous': goalContinuous,
      if (goalRunning != null) 'goal_running': goalRunning,
      if (deadline != null) 'deadline': deadline,
    });
  }

  ExercisesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? unit,
    Value<double>? goalTotal,
    Value<double>? goalContinuous,
    Value<double?>? goalRunning,
    Value<String>? deadline,
  }) {
    return ExercisesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      unit: unit ?? this.unit,
      goalTotal: goalTotal ?? this.goalTotal,
      goalContinuous: goalContinuous ?? this.goalContinuous,
      goalRunning: goalRunning ?? this.goalRunning,
      deadline: deadline ?? this.deadline,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (goalTotal.present) {
      map['goal_total'] = Variable<double>(goalTotal.value);
    }
    if (goalContinuous.present) {
      map['goal_continuous'] = Variable<double>(goalContinuous.value);
    }
    if (goalRunning.present) {
      map['goal_running'] = Variable<double>(goalRunning.value);
    }
    if (deadline.present) {
      map['deadline'] = Variable<String>(deadline.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExercisesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('unit: $unit, ')
          ..write('goalTotal: $goalTotal, ')
          ..write('goalContinuous: $goalContinuous, ')
          ..write('goalRunning: $goalRunning, ')
          ..write('deadline: $deadline')
          ..write(')'))
        .toString();
  }
}

class $ScheduleRulesTable extends ScheduleRules
    with TableInfo<$ScheduleRulesTable, ScheduleRule> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScheduleRulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _exerciseIdMeta = const VerificationMeta(
    'exerciseId',
  );
  @override
  late final GeneratedColumn<int> exerciseId = GeneratedColumn<int>(
    'exercise_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES exercises (id)',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<ScheduleType, int> type =
      GeneratedColumn<int>(
        'type',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<ScheduleType>($ScheduleRulesTable.$convertertype);
  static const VerificationMeta _intervalDaysMeta = const VerificationMeta(
    'intervalDays',
  );
  @override
  late final GeneratedColumn<int> intervalDays = GeneratedColumn<int>(
    'interval_days',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _weekdayMaskMeta = const VerificationMeta(
    'weekdayMask',
  );
  @override
  late final GeneratedColumn<int> weekdayMask = GeneratedColumn<int>(
    'weekday_mask',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<String> startDate = GeneratedColumn<String>(
    'start_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endDateMeta = const VerificationMeta(
    'endDate',
  );
  @override
  late final GeneratedColumn<String> endDate = GeneratedColumn<String>(
    'end_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    exerciseId,
    type,
    intervalDays,
    weekdayMask,
    startDate,
    endDate,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'schedule_rules';
  @override
  VerificationContext validateIntegrity(
    Insertable<ScheduleRule> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('exercise_id')) {
      context.handle(
        _exerciseIdMeta,
        exerciseId.isAcceptableOrUnknown(data['exercise_id']!, _exerciseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_exerciseIdMeta);
    }
    if (data.containsKey('interval_days')) {
      context.handle(
        _intervalDaysMeta,
        intervalDays.isAcceptableOrUnknown(
          data['interval_days']!,
          _intervalDaysMeta,
        ),
      );
    }
    if (data.containsKey('weekday_mask')) {
      context.handle(
        _weekdayMaskMeta,
        weekdayMask.isAcceptableOrUnknown(
          data['weekday_mask']!,
          _weekdayMaskMeta,
        ),
      );
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('end_date')) {
      context.handle(
        _endDateMeta,
        endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ScheduleRule map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScheduleRule(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      exerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}exercise_id'],
      )!,
      type: $ScheduleRulesTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}type'],
        )!,
      ),
      intervalDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}interval_days'],
      ),
      weekdayMask: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}weekday_mask'],
      ),
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}start_date'],
      )!,
      endDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}end_date'],
      ),
    );
  }

  @override
  $ScheduleRulesTable createAlias(String alias) {
    return $ScheduleRulesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ScheduleType, int, int> $convertertype =
      const EnumIndexConverter<ScheduleType>(ScheduleType.values);
}

class ScheduleRule extends DataClass implements Insertable<ScheduleRule> {
  final int id;
  final int exerciseId;
  final ScheduleType type;
  final int? intervalDays;
  final int? weekdayMask;
  final String startDate;
  final String? endDate;
  const ScheduleRule({
    required this.id,
    required this.exerciseId,
    required this.type,
    this.intervalDays,
    this.weekdayMask,
    required this.startDate,
    this.endDate,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['exercise_id'] = Variable<int>(exerciseId);
    {
      map['type'] = Variable<int>(
        $ScheduleRulesTable.$convertertype.toSql(type),
      );
    }
    if (!nullToAbsent || intervalDays != null) {
      map['interval_days'] = Variable<int>(intervalDays);
    }
    if (!nullToAbsent || weekdayMask != null) {
      map['weekday_mask'] = Variable<int>(weekdayMask);
    }
    map['start_date'] = Variable<String>(startDate);
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<String>(endDate);
    }
    return map;
  }

  ScheduleRulesCompanion toCompanion(bool nullToAbsent) {
    return ScheduleRulesCompanion(
      id: Value(id),
      exerciseId: Value(exerciseId),
      type: Value(type),
      intervalDays: intervalDays == null && nullToAbsent
          ? const Value.absent()
          : Value(intervalDays),
      weekdayMask: weekdayMask == null && nullToAbsent
          ? const Value.absent()
          : Value(weekdayMask),
      startDate: Value(startDate),
      endDate: endDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endDate),
    );
  }

  factory ScheduleRule.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScheduleRule(
      id: serializer.fromJson<int>(json['id']),
      exerciseId: serializer.fromJson<int>(json['exerciseId']),
      type: $ScheduleRulesTable.$convertertype.fromJson(
        serializer.fromJson<int>(json['type']),
      ),
      intervalDays: serializer.fromJson<int?>(json['intervalDays']),
      weekdayMask: serializer.fromJson<int?>(json['weekdayMask']),
      startDate: serializer.fromJson<String>(json['startDate']),
      endDate: serializer.fromJson<String?>(json['endDate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'exerciseId': serializer.toJson<int>(exerciseId),
      'type': serializer.toJson<int>(
        $ScheduleRulesTable.$convertertype.toJson(type),
      ),
      'intervalDays': serializer.toJson<int?>(intervalDays),
      'weekdayMask': serializer.toJson<int?>(weekdayMask),
      'startDate': serializer.toJson<String>(startDate),
      'endDate': serializer.toJson<String?>(endDate),
    };
  }

  ScheduleRule copyWith({
    int? id,
    int? exerciseId,
    ScheduleType? type,
    Value<int?> intervalDays = const Value.absent(),
    Value<int?> weekdayMask = const Value.absent(),
    String? startDate,
    Value<String?> endDate = const Value.absent(),
  }) => ScheduleRule(
    id: id ?? this.id,
    exerciseId: exerciseId ?? this.exerciseId,
    type: type ?? this.type,
    intervalDays: intervalDays.present ? intervalDays.value : this.intervalDays,
    weekdayMask: weekdayMask.present ? weekdayMask.value : this.weekdayMask,
    startDate: startDate ?? this.startDate,
    endDate: endDate.present ? endDate.value : this.endDate,
  );
  ScheduleRule copyWithCompanion(ScheduleRulesCompanion data) {
    return ScheduleRule(
      id: data.id.present ? data.id.value : this.id,
      exerciseId: data.exerciseId.present
          ? data.exerciseId.value
          : this.exerciseId,
      type: data.type.present ? data.type.value : this.type,
      intervalDays: data.intervalDays.present
          ? data.intervalDays.value
          : this.intervalDays,
      weekdayMask: data.weekdayMask.present
          ? data.weekdayMask.value
          : this.weekdayMask,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScheduleRule(')
          ..write('id: $id, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('type: $type, ')
          ..write('intervalDays: $intervalDays, ')
          ..write('weekdayMask: $weekdayMask, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    exerciseId,
    type,
    intervalDays,
    weekdayMask,
    startDate,
    endDate,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScheduleRule &&
          other.id == this.id &&
          other.exerciseId == this.exerciseId &&
          other.type == this.type &&
          other.intervalDays == this.intervalDays &&
          other.weekdayMask == this.weekdayMask &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate);
}

class ScheduleRulesCompanion extends UpdateCompanion<ScheduleRule> {
  final Value<int> id;
  final Value<int> exerciseId;
  final Value<ScheduleType> type;
  final Value<int?> intervalDays;
  final Value<int?> weekdayMask;
  final Value<String> startDate;
  final Value<String?> endDate;
  const ScheduleRulesCompanion({
    this.id = const Value.absent(),
    this.exerciseId = const Value.absent(),
    this.type = const Value.absent(),
    this.intervalDays = const Value.absent(),
    this.weekdayMask = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
  });
  ScheduleRulesCompanion.insert({
    this.id = const Value.absent(),
    required int exerciseId,
    required ScheduleType type,
    this.intervalDays = const Value.absent(),
    this.weekdayMask = const Value.absent(),
    required String startDate,
    this.endDate = const Value.absent(),
  }) : exerciseId = Value(exerciseId),
       type = Value(type),
       startDate = Value(startDate);
  static Insertable<ScheduleRule> custom({
    Expression<int>? id,
    Expression<int>? exerciseId,
    Expression<int>? type,
    Expression<int>? intervalDays,
    Expression<int>? weekdayMask,
    Expression<String>? startDate,
    Expression<String>? endDate,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (type != null) 'type': type,
      if (intervalDays != null) 'interval_days': intervalDays,
      if (weekdayMask != null) 'weekday_mask': weekdayMask,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
    });
  }

  ScheduleRulesCompanion copyWith({
    Value<int>? id,
    Value<int>? exerciseId,
    Value<ScheduleType>? type,
    Value<int?>? intervalDays,
    Value<int?>? weekdayMask,
    Value<String>? startDate,
    Value<String?>? endDate,
  }) {
    return ScheduleRulesCompanion(
      id: id ?? this.id,
      exerciseId: exerciseId ?? this.exerciseId,
      type: type ?? this.type,
      intervalDays: intervalDays ?? this.intervalDays,
      weekdayMask: weekdayMask ?? this.weekdayMask,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (exerciseId.present) {
      map['exercise_id'] = Variable<int>(exerciseId.value);
    }
    if (type.present) {
      map['type'] = Variable<int>(
        $ScheduleRulesTable.$convertertype.toSql(type.value),
      );
    }
    if (intervalDays.present) {
      map['interval_days'] = Variable<int>(intervalDays.value);
    }
    if (weekdayMask.present) {
      map['weekday_mask'] = Variable<int>(weekdayMask.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<String>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<String>(endDate.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScheduleRulesCompanion(')
          ..write('id: $id, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('type: $type, ')
          ..write('intervalDays: $intervalDays, ')
          ..write('weekdayMask: $weekdayMask, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate')
          ..write(')'))
        .toString();
  }
}

class $SessionsTable extends Sessions with TableInfo<$SessionsTable, Session> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _exerciseIdMeta = const VerificationMeta(
    'exerciseId',
  );
  @override
  late final GeneratedColumn<int> exerciseId = GeneratedColumn<int>(
    'exercise_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES exercises (id)',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetTotalMeta = const VerificationMeta(
    'targetTotal',
  );
  @override
  late final GeneratedColumn<double> targetTotal = GeneratedColumn<double>(
    'target_total',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _targetContinuousMeta = const VerificationMeta(
    'targetContinuous',
  );
  @override
  late final GeneratedColumn<double> targetContinuous = GeneratedColumn<double>(
    'target_continuous',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _actualTotalMeta = const VerificationMeta(
    'actualTotal',
  );
  @override
  late final GeneratedColumn<double> actualTotal = GeneratedColumn<double>(
    'actual_total',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _actualContinuousMeta = const VerificationMeta(
    'actualContinuous',
  );
  @override
  late final GeneratedColumn<double> actualContinuous = GeneratedColumn<double>(
    'actual_continuous',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _targetRunningMeta = const VerificationMeta(
    'targetRunning',
  );
  @override
  late final GeneratedColumn<double> targetRunning = GeneratedColumn<double>(
    'target_running',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _actualRunningMeta = const VerificationMeta(
    'actualRunning',
  );
  @override
  late final GeneratedColumn<double> actualRunning = GeneratedColumn<double>(
    'actual_running',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _setsMeta = const VerificationMeta('sets');
  @override
  late final GeneratedColumn<String> sets = GeneratedColumn<String>(
    'sets',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<SessionStatus?, int>
  statusOverride = GeneratedColumn<int>(
    'status_override',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  ).withConverter<SessionStatus?>($SessionsTable.$converterstatusOverriden);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    exerciseId,
    date,
    targetTotal,
    targetContinuous,
    actualTotal,
    actualContinuous,
    targetRunning,
    actualRunning,
    sets,
    note,
    statusOverride,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Session> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('exercise_id')) {
      context.handle(
        _exerciseIdMeta,
        exerciseId.isAcceptableOrUnknown(data['exercise_id']!, _exerciseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_exerciseIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('target_total')) {
      context.handle(
        _targetTotalMeta,
        targetTotal.isAcceptableOrUnknown(
          data['target_total']!,
          _targetTotalMeta,
        ),
      );
    }
    if (data.containsKey('target_continuous')) {
      context.handle(
        _targetContinuousMeta,
        targetContinuous.isAcceptableOrUnknown(
          data['target_continuous']!,
          _targetContinuousMeta,
        ),
      );
    }
    if (data.containsKey('actual_total')) {
      context.handle(
        _actualTotalMeta,
        actualTotal.isAcceptableOrUnknown(
          data['actual_total']!,
          _actualTotalMeta,
        ),
      );
    }
    if (data.containsKey('actual_continuous')) {
      context.handle(
        _actualContinuousMeta,
        actualContinuous.isAcceptableOrUnknown(
          data['actual_continuous']!,
          _actualContinuousMeta,
        ),
      );
    }
    if (data.containsKey('target_running')) {
      context.handle(
        _targetRunningMeta,
        targetRunning.isAcceptableOrUnknown(
          data['target_running']!,
          _targetRunningMeta,
        ),
      );
    }
    if (data.containsKey('actual_running')) {
      context.handle(
        _actualRunningMeta,
        actualRunning.isAcceptableOrUnknown(
          data['actual_running']!,
          _actualRunningMeta,
        ),
      );
    }
    if (data.containsKey('sets')) {
      context.handle(
        _setsMeta,
        sets.isAcceptableOrUnknown(data['sets']!, _setsMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Session map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Session(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      exerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}exercise_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      targetTotal: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}target_total'],
      ),
      targetContinuous: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}target_continuous'],
      ),
      actualTotal: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}actual_total'],
      ),
      actualContinuous: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}actual_continuous'],
      ),
      targetRunning: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}target_running'],
      ),
      actualRunning: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}actual_running'],
      ),
      sets: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sets'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      statusOverride: $SessionsTable.$converterstatusOverriden.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}status_override'],
        ),
      ),
    );
  }

  @override
  $SessionsTable createAlias(String alias) {
    return $SessionsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SessionStatus, int, int> $converterstatusOverride =
      const EnumIndexConverter<SessionStatus>(SessionStatus.values);
  static JsonTypeConverter2<SessionStatus?, int?, int?>
  $converterstatusOverriden = JsonTypeConverter2.asNullable(
    $converterstatusOverride,
  );
}

class Session extends DataClass implements Insertable<Session> {
  final int id;
  final int exerciseId;
  final String date;
  final double? targetTotal;
  final double? targetContinuous;
  final double? actualTotal;
  final double? actualContinuous;
  final double? targetRunning;
  final double? actualRunning;
  final String? sets;
  final String? note;
  final SessionStatus? statusOverride;
  const Session({
    required this.id,
    required this.exerciseId,
    required this.date,
    this.targetTotal,
    this.targetContinuous,
    this.actualTotal,
    this.actualContinuous,
    this.targetRunning,
    this.actualRunning,
    this.sets,
    this.note,
    this.statusOverride,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['exercise_id'] = Variable<int>(exerciseId);
    map['date'] = Variable<String>(date);
    if (!nullToAbsent || targetTotal != null) {
      map['target_total'] = Variable<double>(targetTotal);
    }
    if (!nullToAbsent || targetContinuous != null) {
      map['target_continuous'] = Variable<double>(targetContinuous);
    }
    if (!nullToAbsent || actualTotal != null) {
      map['actual_total'] = Variable<double>(actualTotal);
    }
    if (!nullToAbsent || actualContinuous != null) {
      map['actual_continuous'] = Variable<double>(actualContinuous);
    }
    if (!nullToAbsent || targetRunning != null) {
      map['target_running'] = Variable<double>(targetRunning);
    }
    if (!nullToAbsent || actualRunning != null) {
      map['actual_running'] = Variable<double>(actualRunning);
    }
    if (!nullToAbsent || sets != null) {
      map['sets'] = Variable<String>(sets);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || statusOverride != null) {
      map['status_override'] = Variable<int>(
        $SessionsTable.$converterstatusOverriden.toSql(statusOverride),
      );
    }
    return map;
  }

  SessionsCompanion toCompanion(bool nullToAbsent) {
    return SessionsCompanion(
      id: Value(id),
      exerciseId: Value(exerciseId),
      date: Value(date),
      targetTotal: targetTotal == null && nullToAbsent
          ? const Value.absent()
          : Value(targetTotal),
      targetContinuous: targetContinuous == null && nullToAbsent
          ? const Value.absent()
          : Value(targetContinuous),
      actualTotal: actualTotal == null && nullToAbsent
          ? const Value.absent()
          : Value(actualTotal),
      actualContinuous: actualContinuous == null && nullToAbsent
          ? const Value.absent()
          : Value(actualContinuous),
      targetRunning: targetRunning == null && nullToAbsent
          ? const Value.absent()
          : Value(targetRunning),
      actualRunning: actualRunning == null && nullToAbsent
          ? const Value.absent()
          : Value(actualRunning),
      sets: sets == null && nullToAbsent ? const Value.absent() : Value(sets),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      statusOverride: statusOverride == null && nullToAbsent
          ? const Value.absent()
          : Value(statusOverride),
    );
  }

  factory Session.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Session(
      id: serializer.fromJson<int>(json['id']),
      exerciseId: serializer.fromJson<int>(json['exerciseId']),
      date: serializer.fromJson<String>(json['date']),
      targetTotal: serializer.fromJson<double?>(json['targetTotal']),
      targetContinuous: serializer.fromJson<double?>(json['targetContinuous']),
      actualTotal: serializer.fromJson<double?>(json['actualTotal']),
      actualContinuous: serializer.fromJson<double?>(json['actualContinuous']),
      targetRunning: serializer.fromJson<double?>(json['targetRunning']),
      actualRunning: serializer.fromJson<double?>(json['actualRunning']),
      sets: serializer.fromJson<String?>(json['sets']),
      note: serializer.fromJson<String?>(json['note']),
      statusOverride: $SessionsTable.$converterstatusOverriden.fromJson(
        serializer.fromJson<int?>(json['statusOverride']),
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'exerciseId': serializer.toJson<int>(exerciseId),
      'date': serializer.toJson<String>(date),
      'targetTotal': serializer.toJson<double?>(targetTotal),
      'targetContinuous': serializer.toJson<double?>(targetContinuous),
      'actualTotal': serializer.toJson<double?>(actualTotal),
      'actualContinuous': serializer.toJson<double?>(actualContinuous),
      'targetRunning': serializer.toJson<double?>(targetRunning),
      'actualRunning': serializer.toJson<double?>(actualRunning),
      'sets': serializer.toJson<String?>(sets),
      'note': serializer.toJson<String?>(note),
      'statusOverride': serializer.toJson<int?>(
        $SessionsTable.$converterstatusOverriden.toJson(statusOverride),
      ),
    };
  }

  Session copyWith({
    int? id,
    int? exerciseId,
    String? date,
    Value<double?> targetTotal = const Value.absent(),
    Value<double?> targetContinuous = const Value.absent(),
    Value<double?> actualTotal = const Value.absent(),
    Value<double?> actualContinuous = const Value.absent(),
    Value<double?> targetRunning = const Value.absent(),
    Value<double?> actualRunning = const Value.absent(),
    Value<String?> sets = const Value.absent(),
    Value<String?> note = const Value.absent(),
    Value<SessionStatus?> statusOverride = const Value.absent(),
  }) => Session(
    id: id ?? this.id,
    exerciseId: exerciseId ?? this.exerciseId,
    date: date ?? this.date,
    targetTotal: targetTotal.present ? targetTotal.value : this.targetTotal,
    targetContinuous: targetContinuous.present
        ? targetContinuous.value
        : this.targetContinuous,
    actualTotal: actualTotal.present ? actualTotal.value : this.actualTotal,
    actualContinuous: actualContinuous.present
        ? actualContinuous.value
        : this.actualContinuous,
    targetRunning: targetRunning.present
        ? targetRunning.value
        : this.targetRunning,
    actualRunning: actualRunning.present
        ? actualRunning.value
        : this.actualRunning,
    sets: sets.present ? sets.value : this.sets,
    note: note.present ? note.value : this.note,
    statusOverride: statusOverride.present
        ? statusOverride.value
        : this.statusOverride,
  );
  Session copyWithCompanion(SessionsCompanion data) {
    return Session(
      id: data.id.present ? data.id.value : this.id,
      exerciseId: data.exerciseId.present
          ? data.exerciseId.value
          : this.exerciseId,
      date: data.date.present ? data.date.value : this.date,
      targetTotal: data.targetTotal.present
          ? data.targetTotal.value
          : this.targetTotal,
      targetContinuous: data.targetContinuous.present
          ? data.targetContinuous.value
          : this.targetContinuous,
      actualTotal: data.actualTotal.present
          ? data.actualTotal.value
          : this.actualTotal,
      actualContinuous: data.actualContinuous.present
          ? data.actualContinuous.value
          : this.actualContinuous,
      targetRunning: data.targetRunning.present
          ? data.targetRunning.value
          : this.targetRunning,
      actualRunning: data.actualRunning.present
          ? data.actualRunning.value
          : this.actualRunning,
      sets: data.sets.present ? data.sets.value : this.sets,
      note: data.note.present ? data.note.value : this.note,
      statusOverride: data.statusOverride.present
          ? data.statusOverride.value
          : this.statusOverride,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Session(')
          ..write('id: $id, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('date: $date, ')
          ..write('targetTotal: $targetTotal, ')
          ..write('targetContinuous: $targetContinuous, ')
          ..write('actualTotal: $actualTotal, ')
          ..write('actualContinuous: $actualContinuous, ')
          ..write('targetRunning: $targetRunning, ')
          ..write('actualRunning: $actualRunning, ')
          ..write('sets: $sets, ')
          ..write('note: $note, ')
          ..write('statusOverride: $statusOverride')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    exerciseId,
    date,
    targetTotal,
    targetContinuous,
    actualTotal,
    actualContinuous,
    targetRunning,
    actualRunning,
    sets,
    note,
    statusOverride,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Session &&
          other.id == this.id &&
          other.exerciseId == this.exerciseId &&
          other.date == this.date &&
          other.targetTotal == this.targetTotal &&
          other.targetContinuous == this.targetContinuous &&
          other.actualTotal == this.actualTotal &&
          other.actualContinuous == this.actualContinuous &&
          other.targetRunning == this.targetRunning &&
          other.actualRunning == this.actualRunning &&
          other.sets == this.sets &&
          other.note == this.note &&
          other.statusOverride == this.statusOverride);
}

class SessionsCompanion extends UpdateCompanion<Session> {
  final Value<int> id;
  final Value<int> exerciseId;
  final Value<String> date;
  final Value<double?> targetTotal;
  final Value<double?> targetContinuous;
  final Value<double?> actualTotal;
  final Value<double?> actualContinuous;
  final Value<double?> targetRunning;
  final Value<double?> actualRunning;
  final Value<String?> sets;
  final Value<String?> note;
  final Value<SessionStatus?> statusOverride;
  const SessionsCompanion({
    this.id = const Value.absent(),
    this.exerciseId = const Value.absent(),
    this.date = const Value.absent(),
    this.targetTotal = const Value.absent(),
    this.targetContinuous = const Value.absent(),
    this.actualTotal = const Value.absent(),
    this.actualContinuous = const Value.absent(),
    this.targetRunning = const Value.absent(),
    this.actualRunning = const Value.absent(),
    this.sets = const Value.absent(),
    this.note = const Value.absent(),
    this.statusOverride = const Value.absent(),
  });
  SessionsCompanion.insert({
    this.id = const Value.absent(),
    required int exerciseId,
    required String date,
    this.targetTotal = const Value.absent(),
    this.targetContinuous = const Value.absent(),
    this.actualTotal = const Value.absent(),
    this.actualContinuous = const Value.absent(),
    this.targetRunning = const Value.absent(),
    this.actualRunning = const Value.absent(),
    this.sets = const Value.absent(),
    this.note = const Value.absent(),
    this.statusOverride = const Value.absent(),
  }) : exerciseId = Value(exerciseId),
       date = Value(date);
  static Insertable<Session> custom({
    Expression<int>? id,
    Expression<int>? exerciseId,
    Expression<String>? date,
    Expression<double>? targetTotal,
    Expression<double>? targetContinuous,
    Expression<double>? actualTotal,
    Expression<double>? actualContinuous,
    Expression<double>? targetRunning,
    Expression<double>? actualRunning,
    Expression<String>? sets,
    Expression<String>? note,
    Expression<int>? statusOverride,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (date != null) 'date': date,
      if (targetTotal != null) 'target_total': targetTotal,
      if (targetContinuous != null) 'target_continuous': targetContinuous,
      if (actualTotal != null) 'actual_total': actualTotal,
      if (actualContinuous != null) 'actual_continuous': actualContinuous,
      if (targetRunning != null) 'target_running': targetRunning,
      if (actualRunning != null) 'actual_running': actualRunning,
      if (sets != null) 'sets': sets,
      if (note != null) 'note': note,
      if (statusOverride != null) 'status_override': statusOverride,
    });
  }

  SessionsCompanion copyWith({
    Value<int>? id,
    Value<int>? exerciseId,
    Value<String>? date,
    Value<double?>? targetTotal,
    Value<double?>? targetContinuous,
    Value<double?>? actualTotal,
    Value<double?>? actualContinuous,
    Value<double?>? targetRunning,
    Value<double?>? actualRunning,
    Value<String?>? sets,
    Value<String?>? note,
    Value<SessionStatus?>? statusOverride,
  }) {
    return SessionsCompanion(
      id: id ?? this.id,
      exerciseId: exerciseId ?? this.exerciseId,
      date: date ?? this.date,
      targetTotal: targetTotal ?? this.targetTotal,
      targetContinuous: targetContinuous ?? this.targetContinuous,
      actualTotal: actualTotal ?? this.actualTotal,
      actualContinuous: actualContinuous ?? this.actualContinuous,
      targetRunning: targetRunning ?? this.targetRunning,
      actualRunning: actualRunning ?? this.actualRunning,
      sets: sets ?? this.sets,
      note: note ?? this.note,
      statusOverride: statusOverride ?? this.statusOverride,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (exerciseId.present) {
      map['exercise_id'] = Variable<int>(exerciseId.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (targetTotal.present) {
      map['target_total'] = Variable<double>(targetTotal.value);
    }
    if (targetContinuous.present) {
      map['target_continuous'] = Variable<double>(targetContinuous.value);
    }
    if (actualTotal.present) {
      map['actual_total'] = Variable<double>(actualTotal.value);
    }
    if (actualContinuous.present) {
      map['actual_continuous'] = Variable<double>(actualContinuous.value);
    }
    if (targetRunning.present) {
      map['target_running'] = Variable<double>(targetRunning.value);
    }
    if (actualRunning.present) {
      map['actual_running'] = Variable<double>(actualRunning.value);
    }
    if (sets.present) {
      map['sets'] = Variable<String>(sets.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (statusOverride.present) {
      map['status_override'] = Variable<int>(
        $SessionsTable.$converterstatusOverriden.toSql(statusOverride.value),
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionsCompanion(')
          ..write('id: $id, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('date: $date, ')
          ..write('targetTotal: $targetTotal, ')
          ..write('targetContinuous: $targetContinuous, ')
          ..write('actualTotal: $actualTotal, ')
          ..write('actualContinuous: $actualContinuous, ')
          ..write('targetRunning: $targetRunning, ')
          ..write('actualRunning: $actualRunning, ')
          ..write('sets: $sets, ')
          ..write('note: $note, ')
          ..write('statusOverride: $statusOverride')
          ..write(')'))
        .toString();
  }
}

class $WeightEntriesTable extends WeightEntries
    with TableInfo<$WeightEntriesTable, WeightEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WeightEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kgMeta = const VerificationMeta('kg');
  @override
  late final GeneratedColumn<double> kg = GeneratedColumn<double>(
    'kg',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [date, kg, note];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'weight_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<WeightEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('kg')) {
      context.handle(_kgMeta, kg.isAcceptableOrUnknown(data['kg']!, _kgMeta));
    } else if (isInserting) {
      context.missing(_kgMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {date};
  @override
  WeightEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WeightEntry(
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      kg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}kg'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
    );
  }

  @override
  $WeightEntriesTable createAlias(String alias) {
    return $WeightEntriesTable(attachedDatabase, alias);
  }
}

class WeightEntry extends DataClass implements Insertable<WeightEntry> {
  final String date;
  final double kg;
  final String? note;
  const WeightEntry({required this.date, required this.kg, this.note});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['date'] = Variable<String>(date);
    map['kg'] = Variable<double>(kg);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  WeightEntriesCompanion toCompanion(bool nullToAbsent) {
    return WeightEntriesCompanion(
      date: Value(date),
      kg: Value(kg),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory WeightEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WeightEntry(
      date: serializer.fromJson<String>(json['date']),
      kg: serializer.fromJson<double>(json['kg']),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'date': serializer.toJson<String>(date),
      'kg': serializer.toJson<double>(kg),
      'note': serializer.toJson<String?>(note),
    };
  }

  WeightEntry copyWith({
    String? date,
    double? kg,
    Value<String?> note = const Value.absent(),
  }) => WeightEntry(
    date: date ?? this.date,
    kg: kg ?? this.kg,
    note: note.present ? note.value : this.note,
  );
  WeightEntry copyWithCompanion(WeightEntriesCompanion data) {
    return WeightEntry(
      date: data.date.present ? data.date.value : this.date,
      kg: data.kg.present ? data.kg.value : this.kg,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WeightEntry(')
          ..write('date: $date, ')
          ..write('kg: $kg, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(date, kg, note);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WeightEntry &&
          other.date == this.date &&
          other.kg == this.kg &&
          other.note == this.note);
}

class WeightEntriesCompanion extends UpdateCompanion<WeightEntry> {
  final Value<String> date;
  final Value<double> kg;
  final Value<String?> note;
  final Value<int> rowid;
  const WeightEntriesCompanion({
    this.date = const Value.absent(),
    this.kg = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WeightEntriesCompanion.insert({
    required String date,
    required double kg,
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : date = Value(date),
       kg = Value(kg);
  static Insertable<WeightEntry> custom({
    Expression<String>? date,
    Expression<double>? kg,
    Expression<String>? note,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (date != null) 'date': date,
      if (kg != null) 'kg': kg,
      if (note != null) 'note': note,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WeightEntriesCompanion copyWith({
    Value<String>? date,
    Value<double>? kg,
    Value<String?>? note,
    Value<int>? rowid,
  }) {
    return WeightEntriesCompanion(
      date: date ?? this.date,
      kg: kg ?? this.kg,
      note: note ?? this.note,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (kg.present) {
      map['kg'] = Variable<double>(kg.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WeightEntriesCompanion(')
          ..write('date: $date, ')
          ..write('kg: $kg, ')
          ..write('note: $note, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ExercisesTable exercises = $ExercisesTable(this);
  late final $ScheduleRulesTable scheduleRules = $ScheduleRulesTable(this);
  late final $SessionsTable sessions = $SessionsTable(this);
  late final $WeightEntriesTable weightEntries = $WeightEntriesTable(this);
  late final Index sessionExerciseDay = Index(
    'session_exercise_day',
    'CREATE UNIQUE INDEX session_exercise_day ON sessions (exercise_id, date)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    exercises,
    scheduleRules,
    sessions,
    weightEntries,
    sessionExerciseDay,
  ];
}

typedef $$ExercisesTableCreateCompanionBuilder = ExercisesCompanion Function({
  Value<int> id,
  required String name,
  required String unit,
  required double goalTotal,
  required double goalContinuous,
  Value<double?> goalRunning,
  required String deadline,
});
typedef $$ExercisesTableUpdateCompanionBuilder = ExercisesCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String> unit,
  Value<double> goalTotal,
  Value<double> goalContinuous,
  Value<double?> goalRunning,
  Value<String> deadline,
});

final class $$ExercisesTableReferences
    extends BaseReferences<_$AppDatabase, $ExercisesTable, Exercise> {
  $$ExercisesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ScheduleRulesTable, List<ScheduleRule>>
  _scheduleRulesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.scheduleRules,
    aliasName: 'exercises__id__schedule_rules__exercise_id',
  );

  $$ScheduleRulesTableProcessedTableManager get scheduleRulesRefs {
    final manager = $$ScheduleRulesTableTableManager(
      $_db,
      $_db.scheduleRules,
    ).filter((f) => f.exerciseId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_scheduleRulesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SessionsTable, List<Session>> _sessionsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.sessions,
    aliasName: 'exercises__id__sessions__exercise_id',
  );

  $$SessionsTableProcessedTableManager get sessionsRefs {
    final manager = $$SessionsTableTableManager(
      $_db,
      $_db.sessions,
    ).filter((f) => f.exerciseId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_sessionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ExercisesTableFilterComposer
    extends Composer<_$AppDatabase, $ExercisesTable> {
  $$ExercisesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get goalTotal => $composableBuilder(
    column: $table.goalTotal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get goalContinuous => $composableBuilder(
    column: $table.goalContinuous,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get goalRunning => $composableBuilder(
    column: $table.goalRunning,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deadline => $composableBuilder(
    column: $table.deadline,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> scheduleRulesRefs(
    Expression<bool> Function($$ScheduleRulesTableFilterComposer f) f,
  ) {
    final $$ScheduleRulesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.scheduleRules,
      getReferencedColumn: (t) => t.exerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScheduleRulesTableFilterComposer(
            $db: $db,
            $table: $db.scheduleRules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> sessionsRefs(
    Expression<bool> Function($$SessionsTableFilterComposer f) f,
  ) {
    final $$SessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.exerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableFilterComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ExercisesTableOrderingComposer
    extends Composer<_$AppDatabase, $ExercisesTable> {
  $$ExercisesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get goalTotal => $composableBuilder(
    column: $table.goalTotal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get goalContinuous => $composableBuilder(
    column: $table.goalContinuous,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get goalRunning => $composableBuilder(
    column: $table.goalRunning,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deadline => $composableBuilder(
    column: $table.deadline,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ExercisesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExercisesTable> {
  $$ExercisesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<double> get goalTotal =>
      $composableBuilder(column: $table.goalTotal, builder: (column) => column);

  GeneratedColumn<double> get goalContinuous => $composableBuilder(
    column: $table.goalContinuous,
    builder: (column) => column,
  );

  GeneratedColumn<double> get goalRunning => $composableBuilder(
    column: $table.goalRunning,
    builder: (column) => column,
  );

  GeneratedColumn<String> get deadline =>
      $composableBuilder(column: $table.deadline, builder: (column) => column);

  Expression<T> scheduleRulesRefs<T extends Object>(
    Expression<T> Function($$ScheduleRulesTableAnnotationComposer a) f,
  ) {
    final $$ScheduleRulesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.scheduleRules,
      getReferencedColumn: (t) => t.exerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScheduleRulesTableAnnotationComposer(
            $db: $db,
            $table: $db.scheduleRules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> sessionsRefs<T extends Object>(
    Expression<T> Function($$SessionsTableAnnotationComposer a) f,
  ) {
    final $$SessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.exerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ExercisesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExercisesTable,
          Exercise,
          $$ExercisesTableFilterComposer,
          $$ExercisesTableOrderingComposer,
          $$ExercisesTableAnnotationComposer,
          $$ExercisesTableCreateCompanionBuilder,
          $$ExercisesTableUpdateCompanionBuilder,
          (Exercise, $$ExercisesTableReferences),
          Exercise,
          PrefetchHooks Function({bool scheduleRulesRefs, bool sessionsRefs})
        > {
  $$ExercisesTableTableManager(_$AppDatabase db, $ExercisesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExercisesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExercisesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExercisesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> unit = const Value.absent(),
                Value<double> goalTotal = const Value.absent(),
                Value<double> goalContinuous = const Value.absent(),
                Value<double?> goalRunning = const Value.absent(),
                Value<String> deadline = const Value.absent(),
              }) => ExercisesCompanion(
                id: id,
                name: name,
                unit: unit,
                goalTotal: goalTotal,
                goalContinuous: goalContinuous,
                goalRunning: goalRunning,
                deadline: deadline,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String unit,
                required double goalTotal,
                required double goalContinuous,
                Value<double?> goalRunning = const Value.absent(),
                required String deadline,
              }) => ExercisesCompanion.insert(
                id: id,
                name: name,
                unit: unit,
                goalTotal: goalTotal,
                goalContinuous: goalContinuous,
                goalRunning: goalRunning,
                deadline: deadline,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ExercisesTable, Exercise>(table),
                  $$ExercisesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({scheduleRulesRefs = false, sessionsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (scheduleRulesRefs) db.scheduleRules,
                    if (sessionsRefs) db.sessions,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (scheduleRulesRefs)
                        await $_getPrefetchedData<
                          Exercise,
                          $ExercisesTable,
                          ScheduleRule
                        >(
                          currentTable: table,
                          referencedTable: $$ExercisesTableReferences
                              ._scheduleRulesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ExercisesTableReferences(
                                db,
                                table,
                                p0,
                              ).scheduleRulesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.exerciseId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (sessionsRefs)
                        await $_getPrefetchedData<
                          Exercise,
                          $ExercisesTable,
                          Session
                        >(
                          currentTable: table,
                          referencedTable: $$ExercisesTableReferences
                              ._sessionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ExercisesTableReferences(
                                db,
                                table,
                                p0,
                              ).sessionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.exerciseId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ExercisesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExercisesTable,
      Exercise,
      $$ExercisesTableFilterComposer,
      $$ExercisesTableOrderingComposer,
      $$ExercisesTableAnnotationComposer,
      $$ExercisesTableCreateCompanionBuilder,
      $$ExercisesTableUpdateCompanionBuilder,
      (Exercise, $$ExercisesTableReferences),
      Exercise,
      PrefetchHooks Function({bool scheduleRulesRefs, bool sessionsRefs})
    >;
typedef $$ScheduleRulesTableCreateCompanionBuilder =
    ScheduleRulesCompanion Function({
      Value<int> id,
      required int exerciseId,
      required ScheduleType type,
      Value<int?> intervalDays,
      Value<int?> weekdayMask,
      required String startDate,
      Value<String?> endDate,
    });
typedef $$ScheduleRulesTableUpdateCompanionBuilder =
    ScheduleRulesCompanion Function({
      Value<int> id,
      Value<int> exerciseId,
      Value<ScheduleType> type,
      Value<int?> intervalDays,
      Value<int?> weekdayMask,
      Value<String> startDate,
      Value<String?> endDate,
    });

final class $$ScheduleRulesTableReferences
    extends BaseReferences<_$AppDatabase, $ScheduleRulesTable, ScheduleRule> {
  $$ScheduleRulesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ExercisesTable _exerciseIdTable(_$AppDatabase db) =>
      db.exercises.createAlias('schedule_rules__exercise_id__exercises__id');

  $$ExercisesTableProcessedTableManager get exerciseId {
    final $_column = $_itemColumn<int>('exercise_id')!;

    final manager = $$ExercisesTableTableManager(
      $_db,
      $_db.exercises,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_exerciseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ScheduleRulesTableFilterComposer
    extends Composer<_$AppDatabase, $ScheduleRulesTable> {
  $$ScheduleRulesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ScheduleType, ScheduleType, int> get type =>
      $composableBuilder(
        column: $table.type,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get intervalDays => $composableBuilder(
    column: $table.intervalDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get weekdayMask => $composableBuilder(
    column: $table.weekdayMask,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnFilters(column),
  );

  $$ExercisesTableFilterComposer get exerciseId {
    final $$ExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableFilterComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ScheduleRulesTableOrderingComposer
    extends Composer<_$AppDatabase, $ScheduleRulesTable> {
  $$ScheduleRulesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get intervalDays => $composableBuilder(
    column: $table.intervalDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get weekdayMask => $composableBuilder(
    column: $table.weekdayMask,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnOrderings(column),
  );

  $$ExercisesTableOrderingComposer get exerciseId {
    final $$ExercisesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableOrderingComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ScheduleRulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ScheduleRulesTable> {
  $$ScheduleRulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ScheduleType, int> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get intervalDays => $composableBuilder(
    column: $table.intervalDays,
    builder: (column) => column,
  );

  GeneratedColumn<int> get weekdayMask => $composableBuilder(
    column: $table.weekdayMask,
    builder: (column) => column,
  );

  GeneratedColumn<String> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<String> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  $$ExercisesTableAnnotationComposer get exerciseId {
    final $$ExercisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableAnnotationComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ScheduleRulesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ScheduleRulesTable,
          ScheduleRule,
          $$ScheduleRulesTableFilterComposer,
          $$ScheduleRulesTableOrderingComposer,
          $$ScheduleRulesTableAnnotationComposer,
          $$ScheduleRulesTableCreateCompanionBuilder,
          $$ScheduleRulesTableUpdateCompanionBuilder,
          (ScheduleRule, $$ScheduleRulesTableReferences),
          ScheduleRule,
          PrefetchHooks Function({bool exerciseId})
        > {
  $$ScheduleRulesTableTableManager(_$AppDatabase db, $ScheduleRulesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScheduleRulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ScheduleRulesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ScheduleRulesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> exerciseId = const Value.absent(),
                Value<ScheduleType> type = const Value.absent(),
                Value<int?> intervalDays = const Value.absent(),
                Value<int?> weekdayMask = const Value.absent(),
                Value<String> startDate = const Value.absent(),
                Value<String?> endDate = const Value.absent(),
              }) => ScheduleRulesCompanion(
                id: id,
                exerciseId: exerciseId,
                type: type,
                intervalDays: intervalDays,
                weekdayMask: weekdayMask,
                startDate: startDate,
                endDate: endDate,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int exerciseId,
                required ScheduleType type,
                Value<int?> intervalDays = const Value.absent(),
                Value<int?> weekdayMask = const Value.absent(),
                required String startDate,
                Value<String?> endDate = const Value.absent(),
              }) => ScheduleRulesCompanion.insert(
                id: id,
                exerciseId: exerciseId,
                type: type,
                intervalDays: intervalDays,
                weekdayMask: weekdayMask,
                startDate: startDate,
                endDate: endDate,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ScheduleRulesTable, ScheduleRule>(table),
                  $$ScheduleRulesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({exerciseId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (exerciseId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.exerciseId,
                        referencedTable: $$ScheduleRulesTableReferences
                            ._exerciseIdTable(db),
                        referencedColumn: $$ScheduleRulesTableReferences
                            ._exerciseIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ScheduleRulesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ScheduleRulesTable,
      ScheduleRule,
      $$ScheduleRulesTableFilterComposer,
      $$ScheduleRulesTableOrderingComposer,
      $$ScheduleRulesTableAnnotationComposer,
      $$ScheduleRulesTableCreateCompanionBuilder,
      $$ScheduleRulesTableUpdateCompanionBuilder,
      (ScheduleRule, $$ScheduleRulesTableReferences),
      ScheduleRule,
      PrefetchHooks Function({bool exerciseId})
    >;
typedef $$SessionsTableCreateCompanionBuilder = SessionsCompanion Function({
  Value<int> id,
  required int exerciseId,
  required String date,
  Value<double?> targetTotal,
  Value<double?> targetContinuous,
  Value<double?> actualTotal,
  Value<double?> actualContinuous,
  Value<double?> targetRunning,
  Value<double?> actualRunning,
  Value<String?> sets,
  Value<String?> note,
  Value<SessionStatus?> statusOverride,
});
typedef $$SessionsTableUpdateCompanionBuilder = SessionsCompanion Function({
  Value<int> id,
  Value<int> exerciseId,
  Value<String> date,
  Value<double?> targetTotal,
  Value<double?> targetContinuous,
  Value<double?> actualTotal,
  Value<double?> actualContinuous,
  Value<double?> targetRunning,
  Value<double?> actualRunning,
  Value<String?> sets,
  Value<String?> note,
  Value<SessionStatus?> statusOverride,
});

final class $$SessionsTableReferences
    extends BaseReferences<_$AppDatabase, $SessionsTable, Session> {
  $$SessionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ExercisesTable _exerciseIdTable(_$AppDatabase db) =>
      db.exercises.createAlias('sessions__exercise_id__exercises__id');

  $$ExercisesTableProcessedTableManager get exerciseId {
    final $_column = $_itemColumn<int>('exercise_id')!;

    final manager = $$ExercisesTableTableManager(
      $_db,
      $_db.exercises,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_exerciseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SessionsTableFilterComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get targetTotal => $composableBuilder(
    column: $table.targetTotal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get targetContinuous => $composableBuilder(
    column: $table.targetContinuous,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get actualTotal => $composableBuilder(
    column: $table.actualTotal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get actualContinuous => $composableBuilder(
    column: $table.actualContinuous,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get targetRunning => $composableBuilder(
    column: $table.targetRunning,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get actualRunning => $composableBuilder(
    column: $table.actualRunning,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sets => $composableBuilder(
    column: $table.sets,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SessionStatus?, SessionStatus, int>
  get statusOverride => $composableBuilder(
    column: $table.statusOverride,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  $$ExercisesTableFilterComposer get exerciseId {
    final $$ExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableFilterComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get targetTotal => $composableBuilder(
    column: $table.targetTotal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get targetContinuous => $composableBuilder(
    column: $table.targetContinuous,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get actualTotal => $composableBuilder(
    column: $table.actualTotal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get actualContinuous => $composableBuilder(
    column: $table.actualContinuous,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get targetRunning => $composableBuilder(
    column: $table.targetRunning,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get actualRunning => $composableBuilder(
    column: $table.actualRunning,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sets => $composableBuilder(
    column: $table.sets,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get statusOverride => $composableBuilder(
    column: $table.statusOverride,
    builder: (column) => ColumnOrderings(column),
  );

  $$ExercisesTableOrderingComposer get exerciseId {
    final $$ExercisesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableOrderingComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<double> get targetTotal => $composableBuilder(
    column: $table.targetTotal,
    builder: (column) => column,
  );

  GeneratedColumn<double> get targetContinuous => $composableBuilder(
    column: $table.targetContinuous,
    builder: (column) => column,
  );

  GeneratedColumn<double> get actualTotal => $composableBuilder(
    column: $table.actualTotal,
    builder: (column) => column,
  );

  GeneratedColumn<double> get actualContinuous => $composableBuilder(
    column: $table.actualContinuous,
    builder: (column) => column,
  );

  GeneratedColumn<double> get targetRunning => $composableBuilder(
    column: $table.targetRunning,
    builder: (column) => column,
  );

  GeneratedColumn<double> get actualRunning => $composableBuilder(
    column: $table.actualRunning,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sets =>
      $composableBuilder(column: $table.sets, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SessionStatus?, int> get statusOverride =>
      $composableBuilder(
        column: $table.statusOverride,
        builder: (column) => column,
      );

  $$ExercisesTableAnnotationComposer get exerciseId {
    final $$ExercisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableAnnotationComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SessionsTable,
          Session,
          $$SessionsTableFilterComposer,
          $$SessionsTableOrderingComposer,
          $$SessionsTableAnnotationComposer,
          $$SessionsTableCreateCompanionBuilder,
          $$SessionsTableUpdateCompanionBuilder,
          (Session, $$SessionsTableReferences),
          Session,
          PrefetchHooks Function({bool exerciseId})
        > {
  $$SessionsTableTableManager(_$AppDatabase db, $SessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> exerciseId = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<double?> targetTotal = const Value.absent(),
                Value<double?> targetContinuous = const Value.absent(),
                Value<double?> actualTotal = const Value.absent(),
                Value<double?> actualContinuous = const Value.absent(),
                Value<double?> targetRunning = const Value.absent(),
                Value<double?> actualRunning = const Value.absent(),
                Value<String?> sets = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<SessionStatus?> statusOverride = const Value.absent(),
              }) => SessionsCompanion(
                id: id,
                exerciseId: exerciseId,
                date: date,
                targetTotal: targetTotal,
                targetContinuous: targetContinuous,
                actualTotal: actualTotal,
                actualContinuous: actualContinuous,
                targetRunning: targetRunning,
                actualRunning: actualRunning,
                sets: sets,
                note: note,
                statusOverride: statusOverride,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int exerciseId,
                required String date,
                Value<double?> targetTotal = const Value.absent(),
                Value<double?> targetContinuous = const Value.absent(),
                Value<double?> actualTotal = const Value.absent(),
                Value<double?> actualContinuous = const Value.absent(),
                Value<double?> targetRunning = const Value.absent(),
                Value<double?> actualRunning = const Value.absent(),
                Value<String?> sets = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<SessionStatus?> statusOverride = const Value.absent(),
              }) => SessionsCompanion.insert(
                id: id,
                exerciseId: exerciseId,
                date: date,
                targetTotal: targetTotal,
                targetContinuous: targetContinuous,
                actualTotal: actualTotal,
                actualContinuous: actualContinuous,
                targetRunning: targetRunning,
                actualRunning: actualRunning,
                sets: sets,
                note: note,
                statusOverride: statusOverride,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SessionsTable, Session>(table),
                  $$SessionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({exerciseId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (exerciseId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.exerciseId,
                        referencedTable: $$SessionsTableReferences
                            ._exerciseIdTable(db),
                        referencedColumn: $$SessionsTableReferences
                            ._exerciseIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SessionsTable,
      Session,
      $$SessionsTableFilterComposer,
      $$SessionsTableOrderingComposer,
      $$SessionsTableAnnotationComposer,
      $$SessionsTableCreateCompanionBuilder,
      $$SessionsTableUpdateCompanionBuilder,
      (Session, $$SessionsTableReferences),
      Session,
      PrefetchHooks Function({bool exerciseId})
    >;
typedef $$WeightEntriesTableCreateCompanionBuilder =
    WeightEntriesCompanion Function({
      required String date,
      required double kg,
      Value<String?> note,
      Value<int> rowid,
    });
typedef $$WeightEntriesTableUpdateCompanionBuilder =
    WeightEntriesCompanion Function({
      Value<String> date,
      Value<double> kg,
      Value<String?> note,
      Value<int> rowid,
    });

class $$WeightEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $WeightEntriesTable> {
  $$WeightEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get kg => $composableBuilder(
    column: $table.kg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WeightEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $WeightEntriesTable> {
  $$WeightEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get kg => $composableBuilder(
    column: $table.kg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WeightEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $WeightEntriesTable> {
  $$WeightEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<double> get kg =>
      $composableBuilder(column: $table.kg, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);
}

class $$WeightEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WeightEntriesTable,
          WeightEntry,
          $$WeightEntriesTableFilterComposer,
          $$WeightEntriesTableOrderingComposer,
          $$WeightEntriesTableAnnotationComposer,
          $$WeightEntriesTableCreateCompanionBuilder,
          $$WeightEntriesTableUpdateCompanionBuilder,
          (
            WeightEntry,
            BaseReferences<_$AppDatabase, $WeightEntriesTable, WeightEntry>,
          ),
          WeightEntry,
          PrefetchHooks Function()
        > {
  $$WeightEntriesTableTableManager(_$AppDatabase db, $WeightEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WeightEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WeightEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WeightEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> date = const Value.absent(),
                Value<double> kg = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WeightEntriesCompanion(
                date: date,
                kg: kg,
                note: note,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String date,
                required double kg,
                Value<String?> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WeightEntriesCompanion.insert(
                date: date,
                kg: kg,
                note: note,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WeightEntriesTable, WeightEntry>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $WeightEntriesTable,
                    WeightEntry
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WeightEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WeightEntriesTable,
      WeightEntry,
      $$WeightEntriesTableFilterComposer,
      $$WeightEntriesTableOrderingComposer,
      $$WeightEntriesTableAnnotationComposer,
      $$WeightEntriesTableCreateCompanionBuilder,
      $$WeightEntriesTableUpdateCompanionBuilder,
      (
        WeightEntry,
        BaseReferences<_$AppDatabase, $WeightEntriesTable, WeightEntry>,
      ),
      WeightEntry,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ExercisesTableTableManager get exercises =>
      $$ExercisesTableTableManager(_db, _db.exercises);
  $$ScheduleRulesTableTableManager get scheduleRules =>
      $$ScheduleRulesTableTableManager(_db, _db.scheduleRules);
  $$SessionsTableTableManager get sessions =>
      $$SessionsTableTableManager(_db, _db.sessions);
  $$WeightEntriesTableTableManager get weightEntries =>
      $$WeightEntriesTableTableManager(_db, _db.weightEntries);
}
