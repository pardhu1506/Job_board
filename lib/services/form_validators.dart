/// Validation rules for the application form. Each returns null when valid,
/// or a clear message for the user when not.
class FormValidators {
  FormValidators._();

  static const int coverLetterMin = 30;
  static const int coverLetterMax = 600;

  static String? fullName(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Please enter your full name';
    if (text.length < 3) return 'Name must be at least 3 characters';
    if (!RegExp(r"^[A-Za-z][A-Za-z .'-]*$").hasMatch(text)) {
      return 'Use letters only (spaces, dots and hyphens are allowed)';
    }
    return null;
  }

  static String? email(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Please enter your email address';
    if (!RegExp(
      r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9-]+(\.[A-Za-z0-9-]+)+$',
    ).hasMatch(text)) {
      return 'Enter a valid email, for example name@example.com';
    }
    return null;
  }

  static String? phone(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Please enter your mobile number';
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(text)) {
      return 'Enter a valid 10-digit mobile number starting with 6 to 9';
    }
    return null;
  }

  static String? experience(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select your experience level';
    }
    return null;
  }

  static String? coverLetter(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Please write a short cover letter';
    if (text.length < coverLetterMin) {
      return 'Write at least $coverLetterMin characters '
          '(${text.length} so far)';
    }
    if (text.length > coverLetterMax) {
      return 'Keep it under $coverLetterMax characters';
    }
    return null;
  }
}
