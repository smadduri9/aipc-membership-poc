enum MembershipType { aicpMember, patron }

/// Application lifecycle. Payment happens only after the state representative approves.
enum AppStatus {
  draft,
  submitted,
  underReview,
  approved,
  rejected,
  awaitingPayment,
  paymentFailed,
  active,
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

/// Who can sign in to the admin area.
enum AdminRole { master, stateRep }

class AdminUser {
  const AdminUser({
    required this.email,
    required this.name,
    required this.role,
    this.stateCode,
  });

  final String email;
  final String name;
  final AdminRole role;

  /// Null for the master account.
  final String? stateCode;

  bool get isMaster => role == AdminRole.master;
}

class Application {
  String referenceNo = '';
  String firstName = '';
  String lastName = '';
  String phone = '';

  /// Stored masked (XXXX XXXX 1234). The full number is never kept.
  String aadhaarMasked = '';
  String professionalDomain = '';
  String? professionalDomainOther;

  // Voter ID and referrer were removed from registration in V2. They stay until the registration screens are rebuilt.
  String? voterId;
  String? referrerPhone;

  /// State or UT code from the reference data, for example PB.
  String state = '';
  String? stateOther;
  String district = '';
  String? districtOther;
  String? tehsil;
  String? block;
  String cityVillage = '';
  String pinCode = '';
  String parliamentary = '';
  String assembly = '';

  String? selfiePath;
  int? selfieIndex;
  String? instagramUrl;
  String? linkedinUrl;
  String? facebookUrl;

  MembershipType type = MembershipType.aicpMember;
  int amount = 1000;
  AppStatus status = AppStatus.draft;
  String? paymentId;
  String? rejectReason;
  String? reviewedBy;
  DateTime createdAt = DateTime.now();
  DateTime? approvedAt;
  DateTime? validUntil;
  final List<StatusEvent> history = [];

  String get name => '$firstName $lastName'.trim();

  set name(String value) {
    final parts = value.trim().split(RegExp(r'\s+'));
    firstName = parts.first;
    lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';
  }

  /// At least one social profile link is required.
  bool get hasSocialLink => [
    instagramUrl,
    linkedinUrl,
    facebookUrl,
  ].any((u) => u != null && u.isNotEmpty);
}
