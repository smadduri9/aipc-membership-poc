import 'package:flutter/foundation.dart';

import '../models/application.dart';

/// Session state shared across screens: language, logged-in member, admin session and the registration draft.
class AppState extends ChangeNotifier {
  String lang = 'hi';
  String? phone;
  bool adminLoggedIn = false;
  String adminEmail = '';
  AdminUser? admin;

  /// When the admin signed in. Applications that arrive after this count as "new" for them.
  DateTime adminSignedInAt = DateTime.now();

  /// Applications the admin has already looked at in the review list.
  final Set<String> seenRefs = {};
  Application draft = Application();

  void setLang(String code) {
    lang = code;
    notifyListeners();
  }

  void setPhone(String value) {
    phone = value;
    notifyListeners();
  }

  void adminSignIn(AdminUser user) {
    adminLoggedIn = true;
    adminSignedInAt = DateTime.now();
    seenRefs.clear();
    admin = user;
    adminEmail = user.email;
    notifyListeners();
  }

  void markSeen(Iterable<String> refs) {
    seenRefs.addAll(refs);
    notifyListeners();
  }

  void adminSignOut() {
    adminLoggedIn = false;
    adminEmail = '';
    admin = null;
    notifyListeners();
  }

  void resetDraft() {
    draft = Application();
    notifyListeners();
  }
}
