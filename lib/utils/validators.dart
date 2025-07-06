import 'package:email_validator/email_validator.dart';

String? validateEmail(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Email is required';
  }
  if (!EmailValidator.validate(value.trim())) {
    return 'Enter a valid email';
  }
  return null;
}

String? validatePassword(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Password is required';
  }
  if (value.length < 8) {
    return 'Password must be at least 8 characters long';
  }

  final hasUpper = value.contains(RegExp(r'[A-Z]'));
  final hasLower = value.contains(RegExp(r'[a-z]'));
  final hasDigit = value.contains(RegExp(r'[0-9]'));
  final hasSpecial = value.contains(RegExp(r'[!@#\\$&*~]'));

  if (!hasUpper || !hasLower || !hasDigit || !hasSpecial) {
    return 'Must include upper, lower, digit, and special char';
  }

  return null;
}
