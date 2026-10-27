/// Aadhaar number checks. The number is validated with the Verhoeff checksum and only ever stored masked.
const _d = [
  [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
  [1, 2, 3, 4, 0, 6, 7, 8, 9, 5],
  [2, 3, 4, 0, 1, 7, 8, 9, 5, 6],
  [3, 4, 0, 1, 2, 8, 9, 5, 6, 7],
  [4, 0, 1, 2, 3, 9, 5, 6, 7, 8],
  [5, 9, 8, 7, 6, 0, 4, 3, 2, 1],
  [6, 5, 9, 8, 7, 1, 0, 4, 3, 2],
  [7, 6, 5, 9, 8, 2, 1, 0, 4, 3],
  [8, 7, 6, 5, 9, 3, 2, 1, 0, 4],
  [9, 8, 7, 6, 5, 4, 3, 2, 1, 0],
];

const _p = [
  [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
  [1, 5, 7, 6, 2, 8, 3, 0, 9, 4],
  [5, 8, 0, 3, 7, 9, 6, 1, 4, 2],
  [8, 9, 1, 6, 0, 4, 3, 5, 2, 7],
  [9, 4, 5, 3, 1, 2, 6, 8, 7, 0],
  [4, 2, 8, 6, 5, 7, 3, 9, 0, 1],
  [2, 7, 9, 3, 8, 0, 6, 4, 1, 5],
  [7, 0, 4, 6, 9, 1, 3, 2, 5, 8],
];

/// Strips spaces and dashes.
String cleanAadhaar(String input) => input.replaceAll(RegExp(r'[\s-]'), '');

bool isValidAadhaar(String input) {
  final digits = cleanAadhaar(input);
  if (!RegExp(r'^[2-9]\d{11}$').hasMatch(digits)) return false;
  var c = 0;
  final reversed = digits.split('').reversed.toList();
  for (var i = 0; i < reversed.length; i++) {
    c = _d[c][_p[i % 8][int.parse(reversed[i])]];
  }
  return c == 0;
}

/// Shows only the last four digits, for example XXXX XXXX 1234.
String maskAadhaar(String input) {
  final digits = cleanAadhaar(input);
  final last4 = digits.substring(digits.length - 4);
  return 'XXXX XXXX $last4';
}
