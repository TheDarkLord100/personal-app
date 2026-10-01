import 'package:flutter_test/flutter_test.dart';
import 'package:personal_trainer/ui/widgets/amount_fields.dart';

void main() {
  group('amountOrderError', () {
    test('accepts continuous <= running <= total, and missing values', () {
      expect(amountOrderError(total: 6, running: 4, continuous: 1.5), isNull);
      expect(amountOrderError(total: 6, running: 6, continuous: 6), isNull);
      expect(amountOrderError(running: 4), isNull);
      expect(amountOrderError(), isNull);
    });

    test('continuous above running', () {
      expect(amountOrderError(total: 6, running: 2, continuous: 3),
          'Continuous can\'t be more than running.');
    });

    test('running above total', () {
      expect(amountOrderError(total: 3, running: 4),
          'Running can\'t be more than total.');
    });

    test('continuous above total when there is no running', () {
      expect(amountOrderError(total: 50, continuous: 60),
          'Continuous can\'t be more than total.');
    });

    test('target wording', () {
      expect(amountOrderError(total: 3, running: 4, target: true),
          'Target running can\'t be more than target total.');
    });
  });
}
