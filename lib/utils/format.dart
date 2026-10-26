import 'package:intl/intl.dart';

/// Formats whole rupees with Indian digit grouping, e.g. ₹1,00,000.
String formatRupees(int amount) => NumberFormat.currency(
  locale: 'en_IN',
  symbol: '₹',
  decimalDigits: 0,
).format(amount);

String formatDate(DateTime date) => DateFormat('d MMM yyyy').format(date);

String formatDateTime(DateTime date) =>
    DateFormat('d MMM yyyy, h:mm a').format(date);
