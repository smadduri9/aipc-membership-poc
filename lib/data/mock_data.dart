import '../models/application.dart';
import 'reference_data.dart';

/// Sample data only. Names, phone numbers and constituency names are fictional.
final Map<String, String> stateNames = {
  for (final r in regions) r.code: r.name,
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
    MembershipType.aicpMember,
    1000,
    AppStatus.submitted,
    1,
  ),
  _SeedRow(
    'Rajesh Meena',
    '9829023456',
    'RJ',
    'Jaipur',
    'Malviya Nagar',
    'Chartered Accountants',
    MembershipType.aicpMember,
    1000,
    AppStatus.submitted,
    2,
  ),
  _SeedRow(
    'Ananya Mishra',
    '9826034567',
    'MP',
    'Bhopal',
    'Govindpura',
    'Academia',
    MembershipType.aicpMember,
    1000,
    AppStatus.submitted,
    2,
  ),
  _SeedRow(
    'Sunil Sahu',
    '9827045678',
    'CG',
    'Raipur',
    'Raipur City West',
    'MSME',
    MembershipType.aicpMember,
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
    MembershipType.aicpMember,
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
    MembershipType.aicpMember,
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
    MembershipType.aicpMember,
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
    MembershipType.aicpMember,
    1000,
    AppStatus.submitted,
    0,
  ),
  _SeedRow(
    'Manpreet Gill',
    '9876112345',
    'PB',
    'Patiala',
    'Rajpura',
    'Civil Society & Policy Research',
    MembershipType.aicpMember,
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
    MembershipType.aicpMember,
    1000,
    AppStatus.submitted,
    0,
  ),
];

/// Builds the 12 seed applications. Row numbers start at 1 and become the reference sequence.
List<Application> seedApplications() {
  final now = DateTime.now();
  final result = <Application>[];
  final rows = [..._rows, ..._generatedRows()];
  for (var i = 0; i < rows.length; i++) {
    final row = rows[i];
    final number = i + 1;
    final created = now.subtract(Duration(days: row.daysAgo));
    final parts = row.name.split(' ');
    final app = Application()
      ..referenceNo =
          'AIPC-${row.state}-26-${number.toString().padLeft(6, '0')}'
      ..firstName = parts.first
      ..lastName = parts.sublist(1).join(' ')
      ..phone = row.phone
      ..aadhaarMasked = 'XXXX XXXX ${1000 + number}'
      ..professionalDomain = row.domain
      ..state = row.state
      ..district = regionByCode(row.state)?.districts.first ?? ''
      ..cityVillage = row.ac
      ..parliamentary = row.pc
      ..assembly = row.ac
      ..pinCode = '14${number.toString().padLeft(4, '0')}'
      ..selfieIndex = number % 3
      ..instagramUrl = 'https://www.instagram.com/demo${number}member'
      ..type = row.type
      ..amount = row.amount
      ..createdAt = created;

    app.history.add(StatusEvent(AppStatus.submitted, created));
    switch (row.status) {
      case AppStatus.paymentFailed:
        app.status = AppStatus.paymentFailed;
        app.history.add(StatusEvent(AppStatus.paymentFailed, created));
      case AppStatus.approved || AppStatus.awaitingPayment || AppStatus.active:
        final approved = created.add(const Duration(days: 1));
        app.approvedAt = approved;
        app.reviewedBy = 'state.rep@aipc.demo';
        app.history.add(StatusEvent(AppStatus.approved, approved));
        app.status = AppStatus.approved;
        if (row.status == AppStatus.active) {
          app.paymentId = 'pay_DemoSeed$number';
          app.validUntil = row.type == MembershipType.aicpMember
              ? approved.add(const Duration(days: 730))
              : null;
          app.history.add(StatusEvent(AppStatus.active, approved));
          app.status = AppStatus.active;
        }
      case AppStatus.rejected:
        app.rejectReason = row.rejectReason;
        app.history.add(
          StatusEvent(AppStatus.rejected, created, row.rejectReason),
        );
        app.status = AppStatus.rejected;
      default:
        app.status = AppStatus.submitted;
    }
    result.add(app);
  }
  return result;
}

/// Two applications for each state or UT that has no hand-written rows, so every state dashboard has data.
List<_SeedRow> _generatedRows() {
  const handWritten = {'PB', 'RJ', 'MP', 'CG', 'OD'};
  final rows = <_SeedRow>[];
  for (final region in regions) {
    if (handWritten.contains(region.code)) continue;
    for (var n = 1; n <= 2; n++) {
      rows.add(
        _SeedRow(
          'Demo Member ${region.code}$n',
          '${900000000 + regions.indexOf(region) * 10 + n}',
          region.code,
          '',
          '',
          professionalDomains[(n + region.code.length) %
              professionalDomains.length],
          n == 1 ? MembershipType.aicpMember : MembershipType.patron,
          n == 1 ? 1000 : 50000,
          n == 1 ? AppStatus.submitted : AppStatus.active,
          n * 5,
        ),
      );
    }
  }
  return rows;
}

/// Demo Aadhaar addresses, picked by the last digit of the number. Stands in for the e-KYC address.
const List<({String state, String district, String pin, String cityVillage})>
demoAadhaarAddresses = [
  (state: 'PB', district: 'Ludhiana', pin: '142026', cityVillage: 'Jagraon HO'),
  (
    state: 'DL',
    district: 'New Delhi',
    pin: '110001',
    cityVillage: 'Sansad Marg HO',
  ),
  (state: 'MH', district: 'Nanded', pin: '431601', cityVillage: 'Nanded H.O'),
  (
    state: 'KA',
    district: 'Bengaluru Urban',
    pin: '560001',
    cityVillage: 'Bengaluru G.P.O.',
  ),
  (
    state: 'WB',
    district: 'Kolkata',
    pin: '700033',
    cityVillage: 'Tollygunge HO',
  ),
  (
    state: 'TN',
    district: 'Chengalpattu',
    pin: '600045',
    cityVillage: 'Tambaram HO',
  ),
  (
    state: 'UP',
    district: 'Farrukhabad',
    pin: '209601',
    cityVillage: 'Fatehgarh HO',
  ),
  (
    state: 'RJ',
    district: 'Hanumangarh',
    pin: '335512',
    cityVillage: 'Hanumangarh Jn. H.O',
  ),
  (state: 'OD', district: 'Khordha', pin: '752055', cityVillage: 'Khurda H.O'),
  (
    state: 'KL',
    district: 'Ernakulam',
    pin: '682011',
    cityVillage: 'Ernakulam HO',
  ),
];

/// Demo admin accounts: one master, and one state representative per state or UT.
/// Every password is demo1234.
final List<AdminUser> adminUsers = [
  const AdminUser(
    email: 'master@aipc.demo',
    name: 'Master',
    role: AdminRole.master,
  ),
  for (final r in regions)
    AdminUser(
      email: '${r.code.toLowerCase()}@aipc.demo',
      name: '${r.name} Representative',
      role: AdminRole.stateRep,
      stateCode: r.code,
    ),
];

/// Five approvals and one rejection from earlier, newest first.
List<AuditEntry> seedAuditEntries(List<Application> apps) {
  const actor = 'state.rep@aipc.demo';
  final entries = <AuditEntry>[];
  for (final app in apps) {
    if (app.approvedAt != null) {
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
