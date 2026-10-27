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
