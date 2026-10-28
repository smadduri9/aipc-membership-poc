import 'dart:convert';

import '../models/application.dart';
import '../models/notification.dart';

/// JSON form of the demo data, so applications, approvals and notices survive an app restart.
/// PRODUCTION: replaced by the backend API; nothing here is used outside the demo.

String? _date(DateTime? d) => d?.toIso8601String();
DateTime? _parse(Object? s) => s == null ? null : DateTime.parse(s as String);

Map<String, Object?> applicationToJson(Application a) => {
  'referenceNo': a.referenceNo,
  'firstName': a.firstName,
  'lastName': a.lastName,
  'phone': a.phone,
  'aadhaarMasked': a.aadhaarMasked,
  'professionalDomain': a.professionalDomain,
  'professionalDomainOther': a.professionalDomainOther,
  'state': a.state,
  'stateOther': a.stateOther,
  'district': a.district,
  'districtOther': a.districtOther,
  'tehsil': a.tehsil,
  'block': a.block,
  'cityVillage': a.cityVillage,
  'pinCode': a.pinCode,
  'parliamentary': a.parliamentary,
  'assembly': a.assembly,
  'selfiePath': a.selfiePath,
  'selfieIndex': a.selfieIndex,
  'instagramUrl': a.instagramUrl,
  'linkedinUrl': a.linkedinUrl,
  'facebookUrl': a.facebookUrl,
  'type': a.type.name,
  'amount': a.amount,
  'status': a.status.name,
  'paymentId': a.paymentId,
  'rejectReason': a.rejectReason,
  'reviewedBy': a.reviewedBy,
  'createdAt': _date(a.createdAt),
  'approvedAt': _date(a.approvedAt),
  'validUntil': _date(a.validUntil),
  'history': [
    for (final e in a.history)
      {'status': e.status.name, 'at': _date(e.at), 'note': e.note},
  ],
};

Application applicationFromJson(Map<String, dynamic> j) {
  final a = Application()
    ..referenceNo = j['referenceNo'] as String
    ..firstName = j['firstName'] as String
    ..lastName = j['lastName'] as String
    ..phone = j['phone'] as String
    ..aadhaarMasked = j['aadhaarMasked'] as String
    ..professionalDomain = j['professionalDomain'] as String
    ..professionalDomainOther = j['professionalDomainOther'] as String?
    ..state = j['state'] as String
    ..stateOther = j['stateOther'] as String?
    ..district = j['district'] as String
    ..districtOther = j['districtOther'] as String?
    ..tehsil = j['tehsil'] as String?
    ..block = j['block'] as String?
    ..cityVillage = j['cityVillage'] as String
    ..pinCode = j['pinCode'] as String
    ..parliamentary = j['parliamentary'] as String
    ..assembly = j['assembly'] as String
    ..selfiePath = j['selfiePath'] as String?
    ..selfieIndex = j['selfieIndex'] as int?
    ..instagramUrl = j['instagramUrl'] as String?
    ..linkedinUrl = j['linkedinUrl'] as String?
    ..facebookUrl = j['facebookUrl'] as String?
    ..type = MembershipType.values.byName(j['type'] as String)
    ..amount = j['amount'] as int
    ..status = AppStatus.values.byName(j['status'] as String)
    ..paymentId = j['paymentId'] as String?
    ..rejectReason = j['rejectReason'] as String?
    ..reviewedBy = j['reviewedBy'] as String?
    ..createdAt = _parse(j['createdAt'])!
    ..approvedAt = _parse(j['approvedAt'])
    ..validUntil = _parse(j['validUntil']);
  for (final e in j['history'] as List<dynamic>) {
    final m = e as Map<String, dynamic>;
    a.history.add(
      StatusEvent(
        AppStatus.values.byName(m['status'] as String),
        _parse(m['at'])!,
        m['note'] as String?,
      ),
    );
  }
  return a;
}

Map<String, Object?> auditToJson(AuditEntry e) => {
  'at': _date(e.at),
  'actor': e.actor,
  'action': e.action,
  'referenceNo': e.referenceNo,
  'note': e.note,
};

AuditEntry auditFromJson(Map<String, dynamic> j) => AuditEntry(
  at: _parse(j['at'])!,
  actor: j['actor'] as String,
  action: j['action'] as String,
  referenceNo: j['referenceNo'] as String,
  note: j['note'] as String?,
);

Map<String, Object?> noticeToJson(AppNotification n) => {
  'phone': n.phone,
  'title': n.title,
  'body': n.body,
  'at': _date(n.at),
  'read': n.read,
};

AppNotification noticeFromJson(Map<String, dynamic> j) => AppNotification(
  phone: j['phone'] as String,
  title: j['title'] as String,
  body: j['body'] as String,
  at: _parse(j['at'])!,
)..read = j['read'] as bool;

/// Everything the demo needs to restore.
class DemoSnapshot {
  DemoSnapshot(this.applications, this.audit, this.notices, this.nextSeq);

  final List<Application> applications;
  final List<AuditEntry> audit;
  final List<AppNotification> notices;
  final int nextSeq;

  String encode() => jsonEncode({
    'version': 1,
    'nextSeq': nextSeq,
    'applications': [for (final a in applications) applicationToJson(a)],
    'audit': [for (final e in audit) auditToJson(e)],
    'notices': [for (final n in notices) noticeToJson(n)],
  });

  /// Null when the text is missing or from an older format, so the app falls back to fresh seed data.
  static DemoSnapshot? decode(String? text) {
    if (text == null || text.isEmpty) return null;
    try {
      final j = jsonDecode(text) as Map<String, dynamic>;
      if (j['version'] != 1) return null;
      return DemoSnapshot(
        [
          for (final a in j['applications'] as List<dynamic>)
            applicationFromJson(a as Map<String, dynamic>),
        ],
        [
          for (final e in j['audit'] as List<dynamic>)
            auditFromJson(e as Map<String, dynamic>),
        ],
        [
          for (final n in j['notices'] as List<dynamic>)
            noticeFromJson(n as Map<String, dynamic>),
        ],
        j['nextSeq'] as int,
      );
    } catch (_) {
      return null;
    }
  }
}
