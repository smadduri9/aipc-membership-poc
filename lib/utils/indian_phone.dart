final RegExp _mobilePattern = RegExp(r'^[6-9]\d{9}$');

/// True when [value] is a 10-digit Indian mobile number starting 6–9.
bool isValidMobile(String value) => _mobilePattern.hasMatch(value);
