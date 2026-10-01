import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/dates.dart';
import '../../core/today_state.dart';
import '../../database/app_database.dart';
import '../../sessions/sessions_state.dart';
import '../../weight/weight_state.dart';
import 'log_session_sheet.dart';
import 'sheet_body.dart';
import 'weight_checkin_sheet.dart';

/// Earliest day that can be backfilled.
const _earliestDay = '2026-07-01';

/// Segment value for weight; exercise ids start at 1.
const _weight = -1;

Future<void> showBackfillSheet(
    BuildContext context, {
      required List<Exercise> exercises,
    }) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => BackfillSheet(exercises: exercises),
    );

/// Picks an exercise (or weight) and a past day, then opens the normal
/// sheet for it on top. Stays open underneath so several days can be
/// entered in a row.
class BackfillSheet extends ConsumerStatefulWidget {
  const BackfillSheet({super.key, required this.exercises});

  final List<Exercise> exercises;

  @override
  ConsumerState<BackfillSheet> createState() => _BackfillSheetState();
}

class _BackfillSheetState extends ConsumerState<BackfillSheet> {
  final _earliest = parseDay(_earliestDay);
  int _choice = _weight;
  late DateTime _date;
  bool _opening = false;

  @override
  void initState() {
    super.initState();
    final yesterday = addDays(ref.read(todayProvider), -1);
    _date = yesterday.isBefore(_earliest) ? _earliest : yesterday;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: _earliest,
      lastDate: ref.read(todayProvider),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
    );
    if (picked != null) {
      setState(() => _date = DateTime(picked.year, picked.month, picked.day));
    }
  }

  Future<void> _continue() async {
    setState(() => _opening = true);
    try {
      if (_choice == _weight) {
        final key = dayKey(_date);
        final history = await ref.read(weightHistoryProvider.future);
        final existing = history.where((w) => w.date == key).firstOrNull;
        final before = history.where((w) => w.date.compareTo(key) < 0);
        if (!mounted) return;
        await showWeightCheckinSheet(
          context,
          date: _date,
          existing: existing,
          lastKg: before.lastOrNull?.kg,
        );
      } else {
        final exercise = widget.exercises.firstWhere((e) => e.id == _choice);
        final session =
        await ref.read(sessionRepositoryProvider).find(exercise.id, _date);
        if (!mounted) return;
        await showLogSessionSheet(
          context,
          exercise: exercise,
          date: _date,
          session: session,
          suggest: false,
        );
      }
    } finally {
      if (mounted) setState(() => _opening = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final today = ref.watch(todayProvider);

    return SheetBody(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Add past entry', style: theme.textTheme.headlineSmall),
          Text('Back to ${formatDayKey(_earliestDay)}',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 20),
          SegmentedButton<int>(
            showSelectedIcon: false,
            segments: [
              for (final e in widget.exercises)
                ButtonSegment(value: e.id, label: Text(e.name)),
              const ButtonSegment(value: _weight, label: Text('Weight')),
            ],
            selected: {_choice},
            onSelectionChanged: (s) => setState(() => _choice = s.first),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              IconButton.outlined(
                onPressed: _date.isAfter(_earliest)
                    ? () => setState(() => _date = addDays(_date, -1))
                    : null,
                icon: const Icon(Icons.chevron_left),
                tooltip: 'Previous day',
              ),
              Expanded(
                child: TextButton(
                  onPressed: _pickDate,
                  child: Text(formatLongDate(_date)),
                ),
              ),
              IconButton.outlined(
                onPressed: _date.isBefore(today)
                    ? () => setState(() => _date = addDays(_date, 1))
                    : null,
                icon: const Icon(Icons.chevron_right),
                tooltip: 'Next day',
              ),
            ],
          ),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              onPressed: _opening ? null : _continue,
              child: const Text('Continue'),
            ),
          ),
        ],
      ),
    );
  }
}
