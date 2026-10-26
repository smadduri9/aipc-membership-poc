import 'package:flutter/foundation.dart';

import '../models/application.dart';

/// Session state shared across screens: language, logged-in member, admin session and the registration draft.
class AppState extends ChangeNotifier {
  String lang = 'hi';
  String? phone;
  bool adminLoggedIn = false;
  String adminEmail = '';
  Application draft = Application();

  void setLang(String code) {
    lang = code;
    notifyListeners();
  }

  void setPhone(String value) {
    phone = value;
    notifyListeners();
  }

  void adminSignIn(String email) {
    adminLoggedIn = true;
    adminEmail = email;
    notifyListeners();
  }

  void adminSignOut() {
    adminLoggedIn = false;
    adminEmail = '';
    notifyListeners();
  }

  void resetDraft() {
    draft = Application();
    notifyListeners();
  }
}
