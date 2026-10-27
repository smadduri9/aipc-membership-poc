/// In-app notice for a member. Real push notifications are out of scope for the POC.
class AppNotification {
  AppNotification({
    required this.phone,
    required this.title,
    required this.body,
    required this.at,
  });

  final String phone;
  final String title;
  final String body;
  final DateTime at;
  bool read = false;
}
