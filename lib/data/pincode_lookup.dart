import 'dart:convert';

import 'package:flutter/services.dart';

/// One post office record from the trimmed PIN directory in assets/data.
/// [block] holds the postal division name, used as a stand-in for the block.
class PinRecord {
  const PinRecord({
    required this.pin,
    required this.office,
    required this.block,
    required this.district,
    required this.state,
  });

  factory PinRecord.fromJson(Map<String, dynamic> json) => PinRecord(
    pin: json['pin'] as String,
    office: json['office'] as String,
    block: json['block'] as String,
    district: json['district'] as String,
    state: json['state'] as String,
  );

  final String pin;
  final String office;
  final String block;
  final String district;

  /// State or UT code.
  final String state;
}

/// PIN to place lookup. Load once with [load], then query synchronously.
/// PRODUCTION: replace with the official PIN directory service or a full local table.
class PinIndex {
  PinIndex(this._records);

  static const assetPath = 'assets/data/pincodes_sample.json';

  final List<PinRecord> _records;

  static Future<PinIndex> load([AssetBundle? bundle]) async {
    final text = await (bundle ?? rootBundle).loadString(assetPath);
    final list = jsonDecode(text) as List<dynamic>;
    return PinIndex([
      for (final item in list) PinRecord.fromJson(item as Map<String, dynamic>),
    ]);
  }

  /// All post offices for this PIN. Empty when the PIN is not in the sample.
  List<PinRecord> forPin(String pin) =>
      _records.where((r) => r.pin == pin).toList();
}

extension PinIndexDistricts on PinIndex {
  /// Districts in this state that appear in the PIN table.
  Set<String> districtsIn(String stateCode) => {
    for (final r in _records)
      if (r.state == stateCode) r.district,
  };
}

/// State or UT for any Indian PIN, from its postal-circle prefix. Null when the prefix is not used.
/// Used when the post office itself is not in the sample table, so the state is still filled.
String? stateForPin(String pin) {
  if (!RegExp(r'^[1-9]\d{5}$').hasMatch(pin)) return null;
  final p3 = int.parse(pin.substring(0, 3));
  final p6 = int.parse(pin);
  // Small territories that share a prefix with a larger state.
  if (p6 >= 682551 && p6 <= 682559) return 'LD';
  if (p6 >= 396210 && p6 <= 396240) return 'DH';
  if (p3 == 160) return 'CH';
  if (p3 == 194) return 'LA';
  if (p3 == 403) return 'GA';
  if (p3 == 605 || p3 == 607 && p6 >= 607402 && p6 <= 607403) return 'PY';
  if (p3 == 609 && p6 >= 609601 && p6 <= 609609) return 'PY';
  if (p3 == 673 && p6 >= 673310 && p6 <= 673311) return 'PY';
  if (p3 == 737) return 'SK';
  if (p3 == 744) return 'AN';
  if (p3 >= 790 && p3 <= 792) return 'AR';
  if (p3 >= 793 && p3 <= 794) return 'ML';
  if (p3 == 795) return 'MN';
  if (p3 == 796) return 'MZ';
  if (p3 >= 797 && p3 <= 798) return 'NL';
  if (p3 == 799) return 'TR';
  if ((p3 >= 244 && p3 <= 249 && p3 != 245) || p3 == 262 || p3 == 263) {
    return 'UK';
  }
  if (p3 >= 814 && p3 <= 816 || p3 >= 822 && p3 <= 835) return 'JH';
  final p2 = p3 ~/ 10;
  return switch (p2) {
    11 => 'DL',
    12 || 13 => 'HR',
    14 || 15 || 16 => 'PB',
    17 => 'HP',
    18 || 19 => 'JK',
    >= 20 && <= 28 => 'UP',
    >= 30 && <= 34 => 'RJ',
    >= 36 && <= 39 => 'GJ',
    >= 40 && <= 44 => 'MH',
    >= 45 && <= 48 => 'MP',
    49 => 'CG',
    50 => 'TS',
    >= 51 && <= 53 => 'AP',
    >= 56 && <= 59 => 'KA',
    >= 60 && <= 64 => 'TN',
    >= 67 && <= 69 => 'KL',
    >= 70 && <= 74 => 'WB',
    >= 75 && <= 77 => 'OD',
    78 => 'AS',
    >= 80 && <= 85 => 'BR',
    _ => null,
  };
}
