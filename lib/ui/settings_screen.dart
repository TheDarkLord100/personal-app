import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/dates.dart';
import '../core/format.dart';
import '../core/today_state.dart';
import '../database/app_database.dart';
import '../exercises/exercises_state.dart';
import '../export/export_state.dart';
import '../schedule/schedule_state.dart';
import 'widgets/backfill_sheet.dart';
import 'widgets/schedule_rule_editor.dart';
import 'widgets/session_tile.dart';
import 'widgets/sheet_body.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exercises = ref.watch(exercisesProvider).value;
    final rules = ref.watch(scheduleRulesProvider).value;
    final today = ref.watch(todayProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: exercises == null || rules == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          const _SectionHeader('Schedule'),
          for (final e in exercises)
            _ScheduleCard(
              exercise: e,
              rules: _activeRules(rules, e.id, today),
            ),
          const SizedBox(height: 16),
          const _SectionHeader('Goals'),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (final e in exercises)
                  ListTile(
                    title: Text(e.name),
                    subtitle: Text(
                      '${describePair(e.goalTotal, e.goalContinuous, e.unit)}'
                          ' by ${formatDayKey(e.deadline)}',
                    ),
                    trailing: const Icon(Icons.edit_outlined),
                    onTap: () => _showGoalSheet(context, e),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const _SectionHeader('Data'),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.history),
                  title: const Text('Add past entry'),
                  subtitle: const Text('Backfill sessions or weight'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () =>
                      showBackfillSheet(context, exercises: exercises),
                ),
                ListTile(
                  leading: const Icon(Icons.table_view_outlined),
                  title: const Text('Export sessions (CSV)'),
                  onTap: () => _saveFile(
                    context,
                    fileName: 'sessions_${dayKey(today)}.csv',
                    mimeType: 'text/csv',
                    content: ref.read(exportActionsProvider).sessionsCsv(),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.monitor_weight_outlined),
                  title: const Text('Export weight (CSV)'),
                  onTap: () => _saveFile(
                    context,
                    fileName: 'weight_${dayKey(today)}.csv',
                    mimeType: 'text/csv',
                    content: ref.read(exportActionsProvider).weightCsv(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Opens the system "Save to…" screen for [content], then reports the
/// result. Cancelling saves nothing and shows nothing.
Future<void> _saveFile(
    BuildContext context, {
      required String fileName,
      required String mimeType,
      required Future<String> content,
    }) async {
  final messenger = ScaffoldMessenger.of(context);
  try {
    final saved = await FilePicker.saveFile(
      fileName: fileName,
      bytes: Uint8List.fromList(utf8.encode(await content)),
      mimeType: mimeType,
    );
    if (saved != null) {
      messenger.showSnackBar(SnackBar(content: Text('Saved $fileName')));
    }
  } catch (e) {
    messenger.showSnackBar(SnackBar(content: Text('Couldn\'t save: $e')));
  }
}

/// Rules that still apply today or later, oldest first.
List<ScheduleRule> _activeRules(
    List<ScheduleRule> all,
    int exerciseId,
    DateTime today,
    ) {
  final todayKey = dayKey(today);
  return all
      .where((r) =>
  r.exerciseId == exerciseId &&
      (r.endDate == null || r.endDate!.compareTo(todayKey) >= 0))
      .toList()
    ..sort((a, b) => a.startDate.compareTo(b.startDate));
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
    child: Text(text, style: Theme.of(context).textTheme.titleMedium),
  );
}

class _ScheduleCard extends StatelessWidget {
  const _ScheduleCard({required this.exercise, required this.rules});

  final Exercise exercise;
  final List<ScheduleRule> rules;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(exercise.name, style: theme.textTheme.titleSmall),
            if (rules.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text('No schedule yet',
                    style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant)),
              )
            else
              for (final r in rules)
                ListTile(
                  contentPadding: const EdgeInsets.only(right: 8),
                  title: Text(describeRule(r)),
                  trailing: const Icon(Icons.edit_outlined),
                  onTap: () => showScheduleRuleEditor(context,
                      exercise: exercise, rule: r),
                ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () =>
                    showScheduleRuleEditor(context, exercise: exercise),
                icon: const Icon(Icons.add),
                label: const Text('Add schedule'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _showGoalSheet(BuildContext context, Exercise exercise) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => _GoalSheet(exercise: exercise),
    );

class _GoalSheet extends ConsumerStatefulWidget {
  const _GoalSheet({required this.exercise});

  final Exercise exercise;

  @override
  ConsumerState<_GoalSheet> createState() => _GoalSheetState();
}

class _GoalSheetState extends ConsumerState<_GoalSheet> {
  late final _total =
  TextEditingController(text: formatNumber(widget.exercise.goalTotal));
  late final _continuous = TextEditingController(
      text: formatNumber(widget.exercise.goalContinuous));
  late DateTime _deadline = parseDay(widget.exercise.deadline);
  String? _error;

  @override
  void dispose() {
    _total.dispose();
    _continuous.dispose();
    super.dispose();
  }

  Future<void> _pickDeadline() async {
    final today = ref.read(todayProvider);
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline.isBefore(today) ? today : _deadline,
      firstDate: today,
      lastDate: DateTime(today.year + 3, 12, 31),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
    );
    if (picked != null) {
      setState(() =>
      _deadline = DateTime(picked.year, picked.month, picked.day));
    }
  }

  Future<void> _save() async {
    final total = double.tryParse(_total.text.trim());
    final continuous = double.tryParse(_continuous.text.trim());
    if (total == null || continuous == null || total <= 0 || continuous <= 0) {
      setState(() => _error = 'Both goals must be numbers above 0.');
      return;
    }
    if (continuous > total) {
      setState(() => _error = 'Continuous can\'t be more than total.');
      return;
    }
    await ref.read(exerciseRepositoryProvider).updateGoal(
      widget.exercise.id,
      goalTotal: total,
      goalContinuous: continuous,
      deadline: _deadline,
    );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final unit = widget.exercise.unit;
    final keyboard = TextInputType.numberWithOptions(decimal: unit == 'km');

    return SheetBody(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(widget.exercise.name, style: theme.textTheme.headlineSmall),
          Text('Goal',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _total,
                  keyboardType: keyboard,
                  decoration:
                  InputDecoration(labelText: 'Total', suffixText: unit),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _continuous,
                  keyboardType: keyboard,
                  decoration: InputDecoration(
                      labelText: 'Continuous', suffixText: unit),
                ),
              ),
            ],
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.flag_outlined),
            title: const Text('Deadline'),
            subtitle: Text(formatLongDate(_deadline)),
            trailing: const Icon(Icons.chevron_right),
            onTap: _pickDeadline,
          ),
          if (_error != null)
            Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(onPressed: _save, child: const Text('Save')),
          ),
        ],
      ),
    );
  }
}