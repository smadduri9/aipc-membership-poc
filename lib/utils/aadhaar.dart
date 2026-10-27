// Aadhaar number checks. For the demo any 12 digits are accepted; the number is only ever stored masked.

/// Strips spaces and dashes.
String cleanAadhaar(String input) => input.replaceAll(RegExp(r'[\s-]'), '');

bool isValidAadhaar(String input) =>
    RegExp(r'^\d{12}$').hasMatch(cleanAadhaar(input));

/// Shows only the last four digits, for example XXXX XXXX 1234.
String maskAadhaar(String input) {
  final digits = cleanAadhaar(input);
  final last4 = digits.substring(digits.length - 4);
  return 'XXXX XXXX $last4';
}
