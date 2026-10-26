import '../models/application.dart';

/// Sample data only. Names, phone numbers and constituency names are fictional.
const Map<String, String> stateNames = {
  'PB': 'Punjab',
  'RJ': 'Rajasthan',
  'MP': 'Madhya Pradesh',
  'CG': 'Chhattisgarh',
  'OD': 'Odisha',
};

/// stateCode -> parliamentary constituency -> assembly constituencies.
const Map<String, Map<String, List<String>>> constituencies = {
  'PB': {
    'Amritsar': ['Amritsar North', 'Amritsar Central', 'Amritsar West'],
    'Ludhiana': ['Ludhiana Central', 'Ludhiana West', 'Ludhiana North'],
    'Jalandhar': ['Jalandhar Central', 'Jalandhar West', 'Jalandhar Cantt'],
    'Patiala': ['Patiala', 'Patiala Rural', 'Rajpura'],
  },
  'RJ': {
    'Jaipur': ['Malviya Nagar', 'Hawa Mahal', 'Civil Lines'],
    'Jodhpur': ['Sardarpura', 'Soorsagar', 'Jodhpur'],
    'Udaipur': ['Udaipur', 'Udaipur Rural', 'Gogunda'],
    'Kota': ['Kota North', 'Kota South', 'Ladpura'],
  },
  'MP': {
    'Bhopal': ['Bhopal Uttar', 'Bhopal Dakshin-Paschim', 'Govindpura'],
    'Indore': ['Indore-1', 'Indore-2', 'Rau'],
    'Jabalpur': ['Jabalpur Cantt', 'Jabalpur Paschim', 'Jabalpur Uttar'],
    'Gwalior': ['Gwalior', 'Gwalior East', 'Gwalior South'],
  },
  'CG': {
    'Raipur': ['Raipur City North', 'Raipur City South', 'Raipur City West'],
    'Bilaspur': ['Bilaspur', 'Beltara', 'Takhatpur'],
    'Durg': ['Durg City', 'Durg Rural', 'Bhilai Nagar'],
    'Bastar': ['Jagdalpur', 'Bastar', 'Chitrakot'],
  },
  'OD': {
    'Bhubaneswar': [
      'Ekamra-Bhubaneswar',
      'Bhubaneswar Central',
      'Bhubaneswar North',
    ],
    'Cuttack': ['Cuttack Sadar', 'Cuttack-Barabati', 'Choudwar-Cuttack'],
    'Puri': ['Puri', 'Brahmagiri', 'Pipili'],
    'Sambalpur': ['Sambalpur', 'Rengali', 'Kuchinda'],
  },
};

const List<String> professionalDomains = [
  'Civil Society & Policy Research',
  'IT Professionals',
  'Chartered Accountants',
  'Architects',
  'Academia',
  'Healthcare',
  'Financial Services',
  'Agri Professionals',
  'MSME',
  'Legal',
  'Creative & Media',
  'Other',
];

class _SeedRow {
  const _SeedRow(
    this.name,
    this.phone,
    this.state,
    this.pc,
    this.ac,
    this.domain,
    this.type,
    this.amount,
    this.status,
    this.daysAgo, [
    this.rejectReason,
  ]);

  final String name;
  final String phone;
  final String state;
  final String pc;
  final String ac;
  final String domain;
  final MembershipType type;
  final int amount;
  final AppStatus status;
  final int daysAgo;
  final String? rejectReason;
}

const List<_SeedRow> _rows = [
  _SeedRow(
    'Harpreet Kaur',
    '9814012345',
    'PB',
    'Ludhiana',
    'Ludhiana West',
    'IT Professionals',
    MembershipType.ordinary,
    1000,
    AppStatus.approvalPending,
    1,
  ),
  _SeedRow(
    'Rajesh Meena',
    '9829023456',
    'RJ',
    'Jaipur',
    'Malviya Nagar',
    'Chartered Accountants',
    MembershipType.ordinary,
    1000,
    AppStatus.approvalPending,
    2,
  ),
  _SeedRow(
    'Ananya Mishra',
    '9826034567',
    'MP',
    'Bhopal',
    'Govindpura',
    'Academia',
    MembershipType.ordinary,
    1000,
    AppStatus.approvalPending,
    2,
  ),
  _SeedRow(
    'Sunil Sahu',
    '9827045678',
    'CG',
    'Raipur',
    'Raipur City West',
    'MSME',
    MembershipType.ordinary,
    1000,
    AppStatus.approved,
    5,
  ),
  _SeedRow(
    'Priyanka Patnaik',
    '9861056789',
    'OD',
    'Bhubaneswar',
    'Bhubaneswar Central',
    'Healthcare',
    MembershipType.ordinary,
    1000,
    AppStatus.approved,
    6,
  ),
  _SeedRow(
    'Gurmeet Singh Sandhu',
    '9815067890',
    'PB',
    'Amritsar',
    'Amritsar Central',
    'Legal',
    MembershipType.patron,
    50000,
    AppStatus.approved,
    8,
  ),
  _SeedRow(
    'Kavita Sharma',
    '9828078901',
    'RJ',
    'Kota',
    'Kota South',
    'Financial Services',
    MembershipType.patron,
    100000,
    AppStatus.approved,
    9,
  ),
  _SeedRow(
    'Amit Verma',
    '9893089012',
    'MP',
    'Indore',
    'Indore-2',
    'Architects',
    MembershipType.ordinary,
    1000,
    AppStatus.rejected,
    10,
    'Incomplete details',
  ),
  _SeedRow(
    'Deepak Netam',
    '9826190123',
    'CG',
    'Bastar',
    'Jagdalpur',
    'Agri Professionals',
    MembershipType.ordinary,
    1000,
    AppStatus.paymentFailed,
    3,
  ),
  _SeedRow(
    'Sasmita Behera',
    '9437101234',
    'OD',
    'Puri',
    'Puri',
    'Creative & Media',
    MembershipType.ordinary,
    1000,
    AppStatus.paymentPending,
    0,
  ),
  _SeedRow(
    'Manpreet Gill',
    '9876112345',
    'PB',
    'Patiala',
    'Rajpura',
    'Civil Society & Policy Research',
    MembershipType.ordinary,
    1000,
    AppStatus.approved,
    12,
  ),
  _SeedRow(
    'Neha Tiwari',
    '9893123456',
    'MP',
    'Gwalior',
    'Gwalior East',
    'IT Professionals',
    MembershipType.ordinary,
    1000,
    AppStatus.approvalPending,
    0,
  ),
];

/// Builds the 12 seed applications. Row numbers start at 1 and become the reference sequence.
List<Application> seedApplications() {
  final now = DateTime.now();
  final result = <Application>[];
  for (var i = 0; i < _rows.length; i++) {
    final row = _rows[i];
    final number = i + 1;
    final created = now.subtract(Duration(days: row.daysAgo));
    final app = Application()
      ..referenceNo =
          'AIPC-${row.state}-26-${number.toString().padLeft(6, '0')}'
      ..name = row.name
      ..phone = row.phone
      ..domain = row.domain
      ..state = row.state
      ..parliamentary = row.pc
      ..assembly = row.ac
      ..pinCode = '14${number.toString().padLeft(4, '0')}'
      ..selfieIndex = number % 3
      ..type = row.type
      ..amount = row.amount
      ..createdAt = created;

    final pending = StatusEvent(AppStatus.paymentPending, created);
    app.history.add(pending);
    if (row.status == AppStatus.paymentFailed) {
      app.status = AppStatus.paymentFailed;
      app.history.add(StatusEvent(AppStatus.paymentFailed, created));
    } else if (row.status != AppStatus.paymentPending) {
      app.paymentId = 'pay_DemoSeed$number';
      app.history.add(StatusEvent(AppStatus.paymentVerified, created));
      app.history.add(StatusEvent(AppStatus.approvalPending, created));
      app.status = AppStatus.approvalPending;
      if (row.status == AppStatus.approved) {
        final approved = created.add(const Duration(days: 1));
        app.approvedAt = approved;
        app.validUntil = row.type == MembershipType.ordinary
            ? approved.add(const Duration(days: 730))
            : null;
        app.history.add(StatusEvent(AppStatus.approved, approved));
        app.status = AppStatus.approved;
      } else if (row.status == AppStatus.rejected) {
        app.rejectReason = row.rejectReason;
        app.history.add(
          StatusEvent(AppStatus.rejected, created, row.rejectReason),
        );
        app.status = AppStatus.rejected;
      }
    } else {
      app.status = AppStatus.paymentPending;
    }
    result.add(app);
  }
  return result;
}

/// Five approvals and one rejection from earlier, newest first.
List<AuditEntry> seedAuditEntries(List<Application> apps) {
  const actor = 'chairperson.office@aipc.demo';
  final entries = <AuditEntry>[];
  for (final app in apps) {
    if (app.status == AppStatus.approved) {
      entries.add(
        AuditEntry(
          at: app.approvedAt!,
          actor: actor,
          action: 'Approved',
          referenceNo: app.referenceNo,
        ),
      );
    } else if (app.status == AppStatus.rejected) {
      entries.add(
        AuditEntry(
          at: app.history.last.at,
          actor: actor,
          action: 'Rejected',
          referenceNo: app.referenceNo,
          note: app.rejectReason,
        ),
      );
    }
  }
  entries.sort((a, b) => b.at.compareTo(a.at));
  return entries;
}
