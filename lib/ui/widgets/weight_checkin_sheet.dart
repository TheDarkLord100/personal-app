import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/dates.dart';
import '../../core/format.dart';
import '../../database/app_database.dart';
import '../../weight/weight_state.dart';
import 'sheet_body.dart';

Future<void> showWeightCheckinSheet(
    BuildContext context, {
      required DateTime date,
      WeightEntry? existing,
      double? lastKg,
    }) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) =>
          WeightCheckinSheet(date: date, existing: existing, lastKg: lastKg),
    );

class WeightCheckinSheet extends ConsumerStatefulWidget {
  const WeightCheckinSheet({
    super.key,
    required this.date,
    this.existing,
    this.lastKg,
  });

  final DateTime date;
  final WeightEntry? existing;
  final double? lastKg;

  @override
  ConsumerState<WeightCheckinSheet> createState() =>
      _WeightCheckinSheetState();
}

class _WeightCheckinSheetState extends ConsumerState<WeightCheckinSheet> {
  late final _kg = TextEditingController(
      text: widget.existing == null ? '' : formatNumber(widget.existing!.kg));
  late final _note = TextEditingController(text: widget.existing?.note ?? '');
  String? _error;

  @override
  void dispose() {
    _kg.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final kg = double.tryParse(_kg.text.trim());
    if (kg == null || kg < 20 || kg > 300) {
      setState(() => _error = 'Enter a weight between 20 and 300 kg.');
      return;
    }
    final note = _note.text.trim();
    await ref
        .read(weightRepositoryProvider)
        .log(widget.date, kg, note: note.isEmpty ? null : note);
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    await ref.read(weightRepositoryProvider).delete(widget.date);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SheetBody(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Weight', style: theme.textTheme.headlineSmall),
          Text(formatLongDate(widget.date),
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 20),
          TextField(
            controller: _kg,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Weight',
              suffixText: 'kg',
              hintText: widget.lastKg == null
                  ? null
                  : 'Last: ${formatNumber(widget.lastKg!)}',
              errorText: _error,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _note,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(labelText: 'Note'),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              if (widget.existing != null)
                TextButton(onPressed: _delete, child: const Text('Delete')),
              const Spacer(),
              FilledButton(onPressed: _save, child: const Text('Save')),
            ],
          ),
        ],
      ),
    );
  }
}