enum MembershipType { ordinary, patron }

enum AppStatus {
  draft,
  paymentPending,
  paymentFailed,
  paymentVerified,
  approvalPending,
  approved,
  rejected,
}

class StatusEvent {
  StatusEvent(this.status, this.at, [this.note]);

  final AppStatus status;
  final DateTime at;
  final String? note;
}

class AuditEntry {
  AuditEntry({
    required this.at,
    required this.actor,
    required this.action,
    required this.referenceNo,
    this.note,
  });

  final DateTime at;
  final String actor;
  final String action;
  final String referenceNo;
  final String? note;
}

class Application {
  String referenceNo = '';
  String name = '';
  String phone = '';
  String? voterId;
  String domain = '';
  String state = '';
  String parliamentary = '';
  String assembly = '';
  String pinCode = '';
  String? referrerPhone;
  int? selfieIndex;
  MembershipType type = MembershipType.ordinary;
  int amount = 1000;
  AppStatus status = AppStatus.draft;
  String? paymentId;
  String? rejectReason;
  DateTime createdAt = DateTime.now();
  DateTime? approvedAt;
  DateTime? validUntil;
  final List<StatusEvent> history = [];
}
