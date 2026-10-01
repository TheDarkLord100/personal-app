import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/dates.dart';
import '../../core/today_state.dart';
import '../../database/app_database.dart';
import '../../sessions/sessions_state.dart';
import 'sheet_body.dart';

Future<void> showSetTargetsSheet(
    BuildContext context, {
      required List<Exercise> exercises,
    }) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => SetTargetsSheet(exercises: exercises),
    );

/// Sets the same targets on the next N scheduled sessions of one exercise.
class SetTargetsSheet extends ConsumerStatefulWidget {
  const SetTargetsSheet({super.key, required this.exercises});

  final List<Exercise> exercises;

  @override
  ConsumerState<SetTargetsSheet> createState() => _SetTargetsSheetState();
}

class _SetTargetsSheetState extends ConsumerState<SetTargetsSheet> {
  late Exercise _exercise = widget.exercises.first;
  int _count = 3;
  final _total = TextEditingController();
  final _continuous = TextEditingController();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _total.dispose();
    _continuous.dispose();
    super.dispose();
  }

  double? _number(TextEditingController c, String field) {
    final text = c.text.trim();
    if (text.isEmpty) return null;
    final value = double.tryParse(text);
    if (value == null || value <= 0) {
      throw FormatException('$field must be a number above 0.');
    }
    return value;
  }

  Future<void> _save() async {
    final double? total;
    final double? continuous;
    try {
      total = _number(_total, 'Total');
      continuous = _number(_continuous, 'Continuous');
      if (total == null && continuous == null) {
        throw const FormatException('Enter a total, a continuous, or both.');
      }
      if (total != null && continuous != null && continuous > total) {
        throw const FormatException('Continuous can\'t be more than total.');
      }
    } on FormatException catch (e) {
      setState(() => _error = e.message);
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });
    // Grab these before the sheet closes and its context goes away.
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      final days = await ref.read(sessionActionsProvider).setTargetsForNext(
        exerciseId: _exercise.id,
        from: ref.read(todayProvider),
        count: _count,
        total: total,
        continuous: continuous,
      );
      navigator.pop();
      messenger.showSnackBar(SnackBar(
        content: Text(days.isEmpty
            ? 'No upcoming ${_exercise.name} sessions to set.'
            : '${_exercise.name} targets set for '
            '${days.map(formatShortDate).join(', ')}'),
      ));
    } catch (e) {
      setState(() {
        _saving = false;
        _error = 'Couldn\'t save: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final unit = _exercise.unit;
    final keyboard = TextInputType.numberWithOptions(decimal: unit == 'km');

    return SheetBody(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Set targets', style: theme.textTheme.headlineSmall),
          Text('For the next sessions from today',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 20),
          SegmentedButton<int>(
            segments: [
              for (final e in widget.exercises)
                ButtonSegment(value: e.id, label: Text(e.name)),
            ],
            selected: {_exercise.id},
            onSelectionChanged: (s) => setState(() => _exercise =
                widget.exercises.firstWhere((e) => e.id == s.first)),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text('Sessions', style: theme.textTheme.bodyLarge),
              const Spacer(),
              IconButton.outlined(
                onPressed: _count > 1 ? () => setState(() => _count--) : null,
                icon: const Icon(Icons.remove),
              ),
              SizedBox(
                width: 96,
                child: Text(
                  _count == 1 ? 'Next 1' : 'Next $_count',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleSmall,
                ),
              ),
              IconButton.outlined(
                onPressed: _count < 14 ? () => setState(() => _count++) : null,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(height: 16),
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
          const SizedBox(height: 8),
          Text(
            'Skips days already logged. Replaces any targets already set '
                'on the chosen days.',
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
          ],
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              onPressed: _saving ? null : _save,
              child: const Text('Save'),
            ),
          ),
        ],
      ),
    );
  }
}
