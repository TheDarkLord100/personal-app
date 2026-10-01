import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/dates.dart';
import '../../core/format.dart';
import '../../database/app_database.dart';
import '../../database/tables.dart';
import '../../sessions/session_repository.dart';
import '../../sessions/sessions_state.dart';
import '../../sessions/target_suggestion.dart';
import 'amount_fields.dart';
import 'session_tile.dart';
import 'sheet_body.dart';

Future<void> showLogSessionSheet(
    BuildContext context, {
      required Exercise exercise,
      required DateTime date,
      Session? session,
      bool suggest = true,
    }) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => LogSessionSheet(
          exercise: exercise, date: date, session: session, suggest: suggest),
    );

typedef _Parsed = ({
double? targetTotal,
double? targetContinuous,
double? targetRunning,
double? actualTotal,
double? actualContinuous,
double? actualRunning,
List<num>? sets,
});

class LogSessionSheet extends ConsumerStatefulWidget {
  const LogSessionSheet({
    super.key,
    required this.exercise,
    required this.date,
    this.session,
    this.suggest = true,
  });

  final Exercise exercise;
  final DateTime date;
  final Session? session;

  /// Pre-fill suggested targets when the day has none. Off for backfilling,
  /// so past days don't get targets that were never set.
  final bool suggest;

  @override
  ConsumerState<LogSessionSheet> createState() => _LogSessionSheetState();
}

class _LogSessionSheetState extends ConsumerState<LogSessionSheet> {
  final _targetTotal = TextEditingController();
  final _targetContinuous = TextEditingController();
  final _targetRunning = TextEditingController();
  final _actualTotal = TextEditingController();
  final _actualContinuous = TextEditingController();
  final _actualRunning = TextEditingController();
  final _sets = TextEditingController();
  final _note = TextEditingController();

  SessionStatus? _override;
  bool _suggested = false;
  bool _saving = false;
  String? _error;

  bool get _usesSets => widget.exercise.unit == 'reps';

  bool get _hasRunning => widget.exercise.goalRunning != null;

  bool get _wasLogged =>
      widget.session?.actualTotal != null ||
          widget.session?.actualContinuous != null ||
          widget.session?.actualRunning != null;

  @override
  void initState() {
    super.initState();
    final s = widget.session;
    _targetTotal.text = _fmt(s?.targetTotal);
    _targetContinuous.text = _fmt(s?.targetContinuous);
    _targetRunning.text = _fmt(s?.targetRunning);
    _actualTotal.text = _fmt(s?.actualTotal);
    _actualContinuous.text = _fmt(s?.actualContinuous);
    _actualRunning.text = _fmt(s?.actualRunning);
    if (s != null && s.setList.isNotEmpty) {
      _sets.text = s.setList.map(formatNumber).join(', ');
    }
    _note.text = s?.note ?? '';
    _override = s?.statusOverride;
    _sets.addListener(() => setState(() {}));

    if (widget.suggest &&
        s?.targetTotal == null &&
        s?.targetContinuous == null &&
        s?.targetRunning == null) {
      ref.listenManual(
        targetSuggestionProvider((widget.exercise.id, widget.date)),
            (_, next) => _applySuggestion(next.value),
        fireImmediately: true,
      );
    }
  }

  @override
  void dispose() {
    for (final c in [
      _targetTotal, _targetContinuous, _targetRunning, _actualTotal,
      _actualContinuous, _actualRunning, _sets, _note,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _applySuggestion(TargetSuggestion? suggestion) {
    if (suggestion == null || _suggested) return;
    // Don't overwrite anything typed before the suggestion arrived.
    if (_targetTotal.text.isNotEmpty ||
        _targetContinuous.text.isNotEmpty ||
        _targetRunning.text.isNotEmpty) {
      return;
    }
    _targetTotal.text = _fmt(suggestion.total);
    _targetContinuous.text = _fmt(suggestion.continuous);
    _targetRunning.text = _fmt(suggestion.running);
    _suggested = true;
    if (mounted) setState(() {});
  }

  String _fmt(double? v) => v == null ? '' : formatNumber(v);

  double? _number(TextEditingController c, String field) {
    final text = c.text.trim();
    if (text.isEmpty) return null;
    final value = double.tryParse(text);
    if (value == null || value < 0) {
      throw FormatException('$field must be a number of 0 or more.');
    }
    return value;
  }

  List<num>? _parseSets() {
    final text = _sets.text.trim();
    if (text.isEmpty) return null;
    final values = <num>[];
    for (final part in text.split(RegExp(r'[,\s]+'))) {
      if (part.isEmpty) continue;
      final value = num.tryParse(part);
      if (value == null || value <= 0) {
        throw const FormatException(
            'Sets must be positive numbers separated by commas.');
      }
      values.add(value);
    }
    return values.isEmpty ? null : values;
  }

  _Parsed? _parse() {
    try {
      final targetTotal = _number(_targetTotal, 'Target total');
      final targetContinuous = _number(_targetContinuous, 'Target continuous');
      final targetRunning =
      _hasRunning ? _number(_targetRunning, 'Target running') : null;
      final sets = _usesSets ? _parseSets() : null;

      var actualTotal = _number(_actualTotal, 'Total');
      var actualContinuous = _number(_actualContinuous, 'Continuous');
      final actualRunning =
      _hasRunning ? _number(_actualRunning, 'Running') : null;
      if (sets != null) {
        final t = totalsFromSets(sets);
        actualTotal = t.total;
        actualContinuous = t.continuous;
      }

      final orderError = amountOrderError(
        total: targetTotal,
        running: targetRunning,
        continuous: targetContinuous,
        target: true,
      ) ??
          amountOrderError(
            total: actualTotal,
            running: actualRunning,
            continuous: actualContinuous,
          );
      if (orderError != null) throw FormatException(orderError);

      return (
      targetTotal: targetTotal,
      targetContinuous: targetContinuous,
      targetRunning: targetRunning,
      actualTotal: actualTotal,
      actualContinuous: actualContinuous,
      actualRunning: actualRunning,
      sets: sets,
      );
    } on FormatException catch (e) {
      setState(() => _error = e.message);
      return null;
    }
  }

  String? _setsPreview() {
    try {
      final sets = _parseSets();
      if (sets == null) return null;
      final t = totalsFromSets(sets);
      return '${formatNumber(t.total)} total, '
          '${formatNumber(t.continuous)} continuous';
    } on FormatException {
      return null;
    }
  }

  Future<void> _save() async {
    final p = _parse();
    if (p == null) return;
    setState(() {
      _saving = true;
      _error = null;
    });

    final actions = ref.read(sessionActionsProvider);
    final id = widget.exercise.id;
    final day = widget.date;
    final note = _note.text.trim();
    final hasLog = p.actualTotal != null ||
        p.actualContinuous != null ||
        p.actualRunning != null;

    try {
      await actions.setTargets(id, day,
          total: p.targetTotal,
          continuous: p.targetContinuous,
          running: p.targetRunning);
      if (hasLog || note.isNotEmpty) {
        await actions.log(id, day,
            total: p.actualTotal,
            continuous: p.actualContinuous,
            running: p.actualRunning,
            sets: p.sets,
            note: note);
      } else if (_wasLogged) {
        await actions.clearLog(id, day);
      }
      await actions.setStatusOverride(id, day, _override);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      setState(() {
        _saving = false;
        _error = 'Couldn\'t save: $e';
      });
    }
  }

  Future<void> _clear() async {
    await ref
        .read(sessionActionsProvider)
        .clearLog(widget.exercise.id, widget.date);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final unit = widget.exercise.unit;
    final usingSets = _usesSets && _sets.text.trim().isNotEmpty;

    return SheetBody(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(widget.exercise.name, style: theme.textTheme.headlineSmall),
          Text(formatLongDate(widget.date),
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 20),
          _SectionLabel('Target', note: _suggested ? 'Suggested' : null),
          AmountFields(
            total: _targetTotal,
            continuous: _targetContinuous,
            running: _hasRunning ? _targetRunning : null,
            unit: unit,
          ),
          const SizedBox(height: 20),
          const _SectionLabel('What you did'),
          if (_usesSets) ...[
            TextField(
              controller: _sets,
              decoration: InputDecoration(
                labelText: 'Sets',
                hintText: 'e.g. 40, 30, 25',
                helperText: _setsPreview() ?? 'Or enter total and continuous',
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (!usingSets) ...[
            AmountFields(
              total: _actualTotal,
              continuous: _actualContinuous,
              running: _hasRunning ? _actualRunning : null,
              unit: unit,
            ),
            const SizedBox(height: 12),
          ],
          TextField(
            controller: _note,
            minLines: 1,
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(labelText: 'Note'),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<SessionStatus?>(
            initialValue: _override,
            decoration: const InputDecoration(labelText: 'Status'),
            items: [
              const DropdownMenuItem(value: null, child: Text('Automatic')),
              for (final s in SessionStatus.values)
                DropdownMenuItem(value: s, child: Text(statusLabel(s))),
            ],
            onChanged: (v) => setState(() => _override = v),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
          ],
          const SizedBox(height: 20),
          Row(
            children: [
              if (_wasLogged)
                TextButton(
                  onPressed: _saving ? null : _clear,
                  child: const Text('Clear log'),
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
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text, {this.note});

  final String text;
  final String? note;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(text, style: theme.textTheme.titleSmall),
          if (note != null) ...[
            const SizedBox(width: 8),
            Text(note!,
                style: theme.textTheme.labelSmall
                    ?.copyWith(color: theme.colorScheme.primary)),
          ],
        ],
      ),
    );
  }
}