/// Reference lists used by the registration form and admin scoping.
/// Sources: states and UTs of India; district names are a sample for the POC (see §7.1 of the V2 spec).
class Region {
  const Region(this.code, this.name, this.districts);

  final String code;
  final String name;
  final List<String> districts;
}

const List<Region> regions = [
  Region('AN', 'Andaman and Nicobar Islands', [
    'South Andaman',
    'Nicobar',
    'North and Middle Andaman',
  ]),
  Region('AP', 'Andhra Pradesh', ['Visakhapatnam', 'Guntur', 'Kurnool']),
  Region('AR', 'Arunachal Pradesh', ['Papum Pare', 'Tawang', 'Lohit']),
  Region('AS', 'Assam', ['Kamrup Metropolitan', 'Dibrugarh', 'Cachar']),
  Region('BR', 'Bihar', ['Patna', 'Gaya', 'Muzaffarpur']),
  Region('CH', 'Chandigarh', ['Chandigarh']),
  Region('CG', 'Chhattisgarh', ['Raipur', 'Bilaspur', 'Durg']),
  Region('DH', 'Dadra and Nagar Haveli and Daman and Diu', [
    'Dadra and Nagar Haveli',
    'Daman',
    'Diu',
  ]),
  Region('DL', 'Delhi', ['New Delhi', 'South West Delhi', 'North East Delhi']),
  Region('GA', 'Goa', ['North Goa', 'South Goa']),
  Region('GJ', 'Gujarat', ['Ahmedabad', 'Surat', 'Vadodara']),
  Region('HR', 'Haryana', ['Gurugram', 'Faridabad', 'Hisar']),
  Region('HP', 'Himachal Pradesh', ['Shimla', 'Kangra', 'Mandi']),
  Region('JK', 'Jammu and Kashmir', ['Srinagar', 'Jammu', 'Anantnag']),
  Region('JH', 'Jharkhand', ['Ranchi', 'Dhanbad', 'Jamshedpur']),
  Region('KA', 'Karnataka', ['Bengaluru Urban', 'Mysuru', 'Belagavi']),
  Region('KL', 'Kerala', ['Thiruvananthapuram', 'Ernakulam', 'Kozhikode']),
  Region('LA', 'Ladakh', ['Leh', 'Kargil']),
  Region('LD', 'Lakshadweep', ['Lakshadweep']),
  Region('MP', 'Madhya Pradesh', ['Bhopal', 'Indore', 'Jabalpur']),
  Region('MH', 'Maharashtra', ['Mumbai Suburban', 'Pune', 'Nagpur']),
  Region('MN', 'Manipur', ['Imphal West', 'Imphal East', 'Thoubal']),
  Region('ML', 'Meghalaya', ['East Khasi Hills', 'West Garo Hills', 'Ri Bhoi']),
  Region('MZ', 'Mizoram', ['Aizawl', 'Lunglei', 'Champhai']),
  Region('NL', 'Nagaland', ['Kohima', 'Dimapur', 'Mokokchung']),
  Region('OD', 'Odisha', ['Khordha', 'Cuttack', 'Ganjam']),
  Region('PY', 'Puducherry', ['Puducherry', 'Karaikal', 'Mahe']),
  Region('PB', 'Punjab', ['Ludhiana', 'Amritsar', 'Jalandhar']),
  Region('RJ', 'Rajasthan', ['Jaipur', 'Jodhpur', 'Udaipur']),
  Region('SK', 'Sikkim', ['East Sikkim', 'West Sikkim', 'North Sikkim']),
  Region('TN', 'Tamil Nadu', ['Chennai', 'Coimbatore', 'Madurai']),
  Region('TS', 'Telangana', ['Hyderabad', 'Rangareddy', 'Warangal Urban']),
  Region('TR', 'Tripura', ['West Tripura', 'Gomati', 'Khowai']),
  Region('UP', 'Uttar Pradesh', ['Lucknow', 'Varanasi', 'Kanpur Nagar']),
  Region('UK', 'Uttarakhand', ['Dehradun', 'Haridwar', 'Nainital']),
  Region('WB', 'West Bengal', ['Kolkata', 'Howrah', 'Darjeeling']),
];

Region? regionByCode(String code) {
  for (final r in regions) {
    if (r.code == code) return r;
  }
  return null;
}

/// The 24 professional domains from the client's website, in its order, plus "Other".
const List<String> professionalDomains = [
  'Academia',
  'Agri Professionals',
  'Architects',
  'Arts & Culture',
  'Aviation',
  'CA (Chartered Accountant)',
  'Civil Society and Policy Research',
  'Colleges / Schools / Institutions – Mentoring / Career Guidance',
  'Communications',
  'Creative',
  'Engineers',
  'Environment',
  'Financial Services',
  'Healthcare',
  'IT Professionals',
  'Legal Aid Clinics',
  'LGBTQIA+',
  'Media (Advertising, Cinema, TV & Journalism)',
  'Minorities, Adivasi, OBC, SC & ST Scholars',
  'MSME',
  'Social Group Heads',
  'Sports',
  'Tourism & Hospitality, Wellness',
  'Woman Wing',
];

const String otherOption = 'Other';
