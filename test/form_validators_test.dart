import 'package:flutter_test/flutter_test.dart';
import 'package:job_board/services/form_validators.dart';

void main() {
  group('FormValidators', () {
    test('full name', () {
      expect(FormValidators.fullName(''), isNotNull);
      expect(FormValidators.fullName('Ab'), isNotNull);
      expect(FormValidators.fullName('R4vi'), isNotNull);
      expect(FormValidators.fullName('Ravi Kumar'), isNull);
    });

    test('email', () {
      expect(FormValidators.email(''), isNotNull);
      expect(FormValidators.email('ravi@'), isNotNull);
      expect(FormValidators.email('ravi@example.com'), isNull);
    });

    test('phone', () {
      expect(FormValidators.phone(''), isNotNull);
      expect(FormValidators.phone('12345'), isNotNull);
      expect(FormValidators.phone('5123456789'), isNotNull);
      expect(FormValidators.phone('9876543210'), isNull);
    });

    test('experience', () {
      expect(FormValidators.experience(null), isNotNull);
      expect(FormValidators.experience('1 to 2 years'), isNull);
    });

    test('cover letter', () {
      expect(FormValidators.coverLetter(''), isNotNull);
      expect(FormValidators.coverLetter('Too short'), isNotNull);
      expect(FormValidators.coverLetter('a' * 601), isNotNull);
      expect(FormValidators.coverLetter('a' * 40), isNull);
    });
  });
}
