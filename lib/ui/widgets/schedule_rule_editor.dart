import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/dates.dart';
import '../../core/today_state.dart';
import '../../database/app_database.dart';
import '../../database/tables.dart';
import '../../schedule/schedule_engine.dart';
import '../../schedule/schedule_state.dart';

/// e.g. "Every 2 days, from 01/10/2026" or "Mon, Wed, Fri, from 05/10/2026"
String describeRule(ScheduleRule rule) {
  final pattern = switch (rule.type) {
    ScheduleType.everyNDays => rule.intervalDays == 1
        ? 'Every day'
        : 'Every ${rule.intervalDays} days',
    ScheduleType.weekdays =>
        weekdaysOf(rule.weekdayMask ?? 0).map(weekdayShort).join(', '),
  };
  final end =
  rule.endDate == null ? '' : ' until ${formatDayKey(rule.endDate!)}';
  return '$pattern, from ${formatDayKey(rule.startDate)}$end';
}

Future<void> showScheduleRuleEditor(
    BuildContext context, {
      required Exercise exercise,
      ScheduleRule? rule,
    }) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => ScheduleRuleEditor(exercise: exercise, rule: rule),
    );

class ScheduleRuleEditor extends ConsumerStatefulWidget {
  const ScheduleRuleEditor({super.key, required this.exercise, this.rule});

  final Exercise exercise;

  /// Null when adding a new rule.
  final ScheduleRule? rule;

  @override
  ConsumerState<ScheduleRuleEditor> createState() =>
      _ScheduleRuleEditorState();
}

class _ScheduleRuleEditorState extends ConsumerState<ScheduleRuleEditor> {
  late ScheduleType _type;
  late int _interval;
  late Set<int> _weekdays;
  late DateTime _from;
  late DateTime _earliest;
  bool _saving = false;
  String? _error;

  ScheduleRule? get _old => widget.rule;

  @override
  void initState() {
    super.initState();
    final today = ref.read(todayProvider);
    final old = _old;

    _type = old?.type ?? ScheduleType.everyNDays;
    _interval = old?.intervalDays ?? 2;
    _weekdays = old?.weekdayMask == null ? <int>{} : weekdaysOf(old!.weekdayMask!);
    _earliest = today;

    // Edits apply from today, unless the rule hasn't started yet.
    final oldStart = old == null ? null : parseDay(old.startDate);
    _from = (oldStart != null && oldStart.isAfter(today)) ? oldStart : today;
  }

  /// The rule as currently configured, for the preview.
  ScheduleRule _candidate() => ScheduleRule(
    id: -1,
    exerciseId: widget.exercise.id,
    type: _type,
    intervalDays: _type == ScheduleType.everyNDays ? _interval : null,
    weekdayMask:
    _type == ScheduleType.weekdays ? weekdayMaskOf(_weekdays) : null,
    startDate: dayKey(_from),
  );

  /// True if saving would produce exactly the same schedule as before.
  bool get _unchanged {
    final old = _old;
    if (old == null || old.type != _type) return false;
    return switch (_type) {
      ScheduleType.weekdays => old.weekdayMask == weekdayMaskOf(_weekdays),
      ScheduleType.everyNDays => old.intervalDays == _interval &&
          daysBetween(parseDay(old.startDate), _from) % _interval == 0,
    };
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _from,
      firstDate: _earliest,
      lastDate: DateTime(_earliest.year + 2, 12, 31),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
    );
    if (picked != null) {
      setState(() => _from = DateTime(picked.year, picked.month, picked.day));
    }
  }

  Future<void> _save() async {
    if (_type == ScheduleType.weekdays && _weekdays.isEmpty) {
      setState(() => _error = 'Pick at least one day.');
      return;
    }
    if (_unchanged) {
      Navigator.of(context).pop();
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    final actions = ref.read(scheduleActionsProvider);
    final id = widget.exercise.id;
    final old = _old;

    try {
      switch ((_type, old)) {
        case (ScheduleType.everyNDays, null):
          await actions.addEveryNDays(
              exerciseId: id, intervalDays: _interval, start: _from);
        case (ScheduleType.weekdays, null):
          await actions.addWeekdays(
              exerciseId: id, weekdays: _weekdays, start: _from);
        case (ScheduleType.everyNDays, final ScheduleRule old):
          await actions.replaceWithEveryNDays(
              oldRuleId: old.id,
              exerciseId: id,
              intervalDays: _interval,
              from: _from);
        case (ScheduleType.weekdays, final ScheduleRule old):
          await actions.replaceWithWeekdays(
              oldRuleId: old.id,
              exerciseId: id,
              weekdays: _weekdays,
              from: _from);
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      setState(() {
        _saving = false;
        _error = 'Couldn\'t save: $e';
      });
    }
  }

  Future<void> _stop() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Stop this schedule?'),
        content: Text(
          'It won\'t schedule any more ${widget.exercise.name.toLowerCase()} '
              'sessions from ${formatDate(_from)}. Logged sessions are kept.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Stop schedule'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await ref
        .read(scheduleActionsProvider)
        .stop(_old!.id, lastDay: addDays(_from, -1));
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodyMedium
        ?.copyWith(color: theme.colorScheme.onSurfaceVariant);
    final upcoming = (_type == ScheduleType.weekdays && _weekdays.isEmpty)
        ? const <DateTime>[]
        : nextOccurrences([_candidate()], widget.exercise.id, _from, 5);

    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 0, 20, MediaQuery.viewInsetsOf(context).bottom + 20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(widget.exercise.name, style: theme.textTheme.headlineSmall),
            Text(_old == null ? 'New schedule' : 'Edit schedule', style: muted),
            const SizedBox(height: 20),
            SegmentedButton<ScheduleType>(
              segments: const [
                ButtonSegment(
                  value: ScheduleType.everyNDays,
                  label: Text('Every N days'),
                ),
                ButtonSegment(
                  value: ScheduleType.weekdays,
                  label: Text('Weekdays'),
                ),
              ],
              selected: {_type},
              onSelectionChanged: (s) => setState(() => _type = s.first),
            ),
            const SizedBox(height: 16),
            if (_type == ScheduleType.everyNDays)
              Row(
                children: [
                  Text('Repeat', style: theme.textTheme.bodyLarge),
                  const Spacer(),
                  IconButton.outlined(
                    onPressed: _interval > 1
                        ? () => setState(() => _interval--)
                        : null,
                    icon: const Icon(Icons.remove),
                  ),
                  SizedBox(
                    width: 96,
                    child: Text(
                      _interval == 1 ? 'Every day' : 'Every $_interval days',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleSmall,
                    ),
                  ),
                  IconButton.outlined(
                    onPressed: _interval < 14
                        ? () => setState(() => _interval++)
                        : null,
                    icon: const Icon(Icons.add),
                  ),
                ],
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (var w = DateTime.monday; w <= DateTime.sunday; w++)
                    FilterChip(
                      label: Text(weekdayShort(w)),
                      selected: _weekdays.contains(w),
                      onSelected: (on) => setState(() {
                        if (on) {
                          _weekdays.add(w);
                        } else {
                          _weekdays.remove(w);
                        }
                      }),
                    ),
                ],
              ),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event_outlined),
              title: Text(_old == null ? 'Starts on' : 'Changes apply from'),
              subtitle: Text(formatLongDate(_from)),
              trailing: const Icon(Icons.chevron_right),
              onTap: _pickDate,
            ),
            if (_type == ScheduleType.everyNDays)
              Text(
                'Sessions repeat counting from this date. To alternate with '
                    'another exercise, start one of them a day later.',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            const SizedBox(height: 16),
            Text('Next sessions', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            if (upcoming.isEmpty)
              Text('None', style: muted)
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final d in upcoming)
                    Chip(
                      label: Text(formatShortDate(d)),
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
            ],
            const SizedBox(height: 20),
            Row(
              children: [
                if (_old != null)
                  TextButton(
                    onPressed: _saving ? null : _stop,
                    child: const Text('Stop schedule'),
                  ),
                const Spacer(),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  child: const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}