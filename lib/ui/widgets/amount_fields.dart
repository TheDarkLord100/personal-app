import 'package:flutter/material.dart';

/// Total / continuous fields, plus running for exercises that track it.
/// Shared by the log, set-targets and goal sheets so they stay alike.
class AmountFields extends StatelessWidget {
  const AmountFields({
    super.key,
    required this.total,
    required this.continuous,
    required this.unit,
    this.running,
  });

  final TextEditingController total;
  final TextEditingController continuous;
  final String unit;

  /// Null for exercises without running distance.
  final TextEditingController? running;

  @override
  Widget build(BuildContext context) {
    final keyboard = TextInputType.numberWithOptions(decimal: unit == 'km');
    Widget field(TextEditingController c, String label, {String? helper}) =>
        TextField(
          controller: c,
          keyboardType: keyboard,
          decoration: InputDecoration(
              labelText: label, suffixText: unit, helperText: helper),
        );

    final running = this.running;
    if (running == null) {
      return Row(
        children: [
          Expanded(child: field(total, 'Total')),
          const SizedBox(width: 12),
          Expanded(child: field(continuous, 'Continuous')),
        ],
      );
    }

    // Three across is too tight on a phone: two rows instead.
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: field(total, 'Total', helper: 'Walk + run')),
            const SizedBox(width: 12),
            Expanded(child: field(running, 'Running')),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: field(continuous, 'Continuous')),
            const SizedBox(width: 12),
            const Expanded(child: SizedBox()),
          ],
        ),
      ],
    );
  }
}

/// Checks continuous <= running <= total, skipping any that are missing.
/// Returns a message for the first problem, or null.
String? amountOrderError({
  double? total,
  double? running,
  double? continuous,
  bool target = false,
}) {
  final t = target ? 'target ' : '';
  String sentence(String s) => '${s[0].toUpperCase()}${s.substring(1)}';

  if (running != null && continuous != null && continuous > running) {
    return sentence('${t}continuous can\'t be more than ${t}running.');
  }
  if (total != null && running != null && running > total) {
    return sentence('${t}running can\'t be more than ${t}total.');
  }
  if (total != null && continuous != null && continuous > total) {
    return sentence('${t}continuous can\'t be more than ${t}total.');
  }
  return null;
}
