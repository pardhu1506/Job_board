import 'package:flutter_test/flutter_test.dart';
import 'package:job_board/services/salary_parser.dart';

void main() {
  group('SalaryParser', () {
    test('parses a salary range with compact units', () {
      final range = SalaryParser.parse('\$50k - \$80k per year');

      expect(range?.minimum, 50000);
      expect(range?.maximum, 80000);
    });

    test('applies a trailing unit to both values', () {
      final range = SalaryParser.parse('10-15 LPA');

      expect(range?.minimum, 1000000);
      expect(range?.maximum, 1500000);
    });

    test('does not reapply a leading unit to a full second value', () {
      final range = SalaryParser.parse('50k - 80,000');

      expect(range?.minimum, 50000);
      expect(range?.maximum, 80000);
    });

    test('parses a single salary value', () {
      final range = SalaryParser.parse('USD 75,000 annually');

      expect(range?.minimum, 75000);
      expect(range?.maximum, 75000);
    });

    test('returns null when salary is absent or not numeric', () {
      expect(SalaryParser.parse(''), isNull);
      expect(SalaryParser.parse('Not specified'), isNull);
    });
  });
}
