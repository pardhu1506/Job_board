class SalaryRange {
  const SalaryRange(this.minimum, this.maximum);

  final double minimum;
  final double maximum;
}

class SalaryParser {
  SalaryParser._();

  static final RegExp _amountPattern = RegExp(
    r'(\d[\d,]*(?:\.\d+)?)\s*(k|m|lpa|lakhs?|lacs?|crores?)?',
    caseSensitive: false,
  );

  static SalaryRange? parse(String salary) {
    if (salary.trim().isEmpty) return null;

    final matches = _amountPattern.allMatches(salary).toList();
    if (matches.isEmpty) return null;

    final sharedUnit = matches.last.group(2)?.toLowerCase();
    final amounts = <double>[];
    for (final match in matches) {
      final number = double.tryParse(match.group(1)!.replaceAll(',', ''));
      if (number == null) continue;
      final unit = match.group(2)?.toLowerCase() ?? sharedUnit;
      amounts.add(number * _multiplier(unit));
    }
    if (amounts.isEmpty) return null;
    if (amounts.length == 1) return SalaryRange(amounts.single, amounts.single);

    final minimum = amounts.reduce((a, b) => a < b ? a : b);
    final maximum = amounts.reduce((a, b) => a > b ? a : b);
    return SalaryRange(minimum, maximum);
  }

  static double _multiplier(String? unit) {
    if (unit == null) return 1;
    if (unit == 'k') return 1000;
    if (unit == 'm') return 1000000;
    if (unit == 'lpa' || unit.startsWith('lakh') || unit.startsWith('lac')) {
      return 100000;
    }
    if (unit.startsWith('crore')) return 10000000;
    return 1;
  }
}
