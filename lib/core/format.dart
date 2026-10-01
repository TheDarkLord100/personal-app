/// Up to two decimals, trailing zeros dropped: 2.0 → "2", 2.50 → "2.5".
String formatNumber(double value) =>
    value.toStringAsFixed(2).replaceFirst(RegExp(r'\.?0+$'), '');

String formatAmount(double value, String unit) =>
    '${formatNumber(value)} $unit';

String formatKg(double value) => '${value.toStringAsFixed(1)} kg';