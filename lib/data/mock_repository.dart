import 'dart:math';

import 'package:flutter/foundation.dart';

import '../models/application.dart';
import 'mock_data.dart';

/// In-memory stand-in for a backend. Every call waits briefly so the UI feels real.
/// Data resets when the app restarts.
class MockRepository extends ChangeNotifier {
  MockRepository() : applications = seedApplications(), auditLog = [] {
    auditLog.addAll(seedAuditEntries(applications));
  }

  final List<Application> applications;
  final List<AuditEntry> auditLog;
  int _nextSeq = 101;
  final _random = Random();

  Future<void> _wait() => Future.delayed(const Duration(milliseconds: 600));

  /// Demo member with an application that is already approved, so the payment step can be shown.
  static const approvedDemoPhone = '9876500000';

  Future<void> sendOtp(String phone) async {
    await _wait();
  }

  Future<bool> verifyOtp(String phone, String code) async {
    await _wait();
    return code == '123456';
  }

  /// Latest non-draft application for this phone, or null.
  Application? findByPhone(String phone) {
    final matches =
        applications
            .where((a) => a.phone == phone && a.status != AppStatus.draft)
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return matches.isEmpty ? null : matches.first;
  }

  Application? findByRef(String ref) {
    for (final app in applications) {
      if (app.referenceNo == ref) return app;
    }
    return null;
  }

  /// Member submits the application. It waits for the state representative.
  Future<Application> submit(Application draft) async {
    await _wait();
    draft.referenceNo =
        'AIPC-${draft.state}-26-${_nextSeq.toString().padLeft(6, '0')}';
    _nextSeq++;
    draft.status = AppStatus.submitted;
    draft.history.add(StatusEvent(AppStatus.submitted, DateTime.now()));
    if (!applications.contains(draft)) applications.add(draft);
    notifyListeners();
    return draft;
  }

  /// Simulated payment, after approval. Success makes the membership active.
  Future<void> fakePay(String ref, {required bool success}) async {
    await _wait();
    final app = findByRef(ref);
    if (app == null) return;
    final now = DateTime.now();
    if (success) {
      app.paymentId = 'pay_Demo${_randomCode(6)}';
      app.status = AppStatus.active;
      app.validUntil = app.type == MembershipType.aicpMember
          ? now.add(const Duration(days: 730))
          : null;
      app.history.add(StatusEvent(AppStatus.active, now));
    } else {
      app.status = AppStatus.paymentFailed;
      app.history.add(StatusEvent(AppStatus.paymentFailed, now));
    }
    notifyListeners();
  }

  /// Returns the account for these credentials, or null. Every demo password is demo1234.
  Future<AdminUser?> adminLogin(String email, String password) async {
    await _wait();
    if (password != 'demo1234') return null;
    final normalized = email.trim().toLowerCase();
    for (final user in adminUsers) {
      if (user.email == normalized) return user;
    }
    return null;
  }

  /// Non-draft applications, newest first. A state representative only sees their own state.
  List<Application> search({
    String? state,
    AppStatus? status,
    String query = '',
    AdminUser? viewer,
  }) {
    final q = query.trim().toLowerCase();
    final result = applications.where((a) {
      if (a.status == AppStatus.draft) return false;
      if (viewer != null && !viewer.isMaster && a.state != viewer.stateCode) {
        return false;
      }
      if (state != null && a.state != state) return false;
      if (status != null && a.status != status) return false;
      if (q.isEmpty) return true;
      return a.referenceNo.toLowerCase().contains(q) ||
          a.phone.startsWith(q) ||
          a.name.toLowerCase().contains(q);
    }).toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return result;
  }

  /// Totals for a dashboard. Pass a state code for a state view, or null for all states.
  ({int total, int pending, int approved, int rejected, int active, int money})
  dashboardStats({String? stateCode}) {
    final apps = search(state: stateCode);
    var money = 0;
    for (final a in apps) {
      if (a.status == AppStatus.active) money += a.amount;
    }
    return (
      total: apps.length,
      pending: apps.where((a) => a.status == AppStatus.submitted).length,
      approved: apps.where((a) => a.status == AppStatus.approved).length,
      rejected: apps.where((a) => a.status == AppStatus.rejected).length,
      active: apps.where((a) => a.status == AppStatus.active).length,
      money: money,
    );
  }

  Future<void> approve(String ref, String actor) async {
    await _wait();
    final app = findByRef(ref);
    if (app == null) return;
    final now = DateTime.now();
    app.status = AppStatus.approved;
    app.approvedAt = now;
    app.reviewedBy = actor;
    app.validUntil = app.type == MembershipType.aicpMember
        ? now.add(const Duration(days: 730))
        : null;
    app.history.add(StatusEvent(AppStatus.approved, now));
    auditLog.insert(
      0,
      AuditEntry(at: now, actor: actor, action: 'Approved', referenceNo: ref),
    );
    notifyListeners();
  }

  Future<void> reject(String ref, String actor, String reason) async {
    await _wait();
    final app = findByRef(ref);
    if (app == null) return;
    final now = DateTime.now();
    app.status = AppStatus.rejected;
    app.rejectReason = reason;
    app.reviewedBy = actor;
    app.history.add(StatusEvent(AppStatus.rejected, now, reason));
    auditLog.insert(
      0,
      AuditEntry(
        at: now,
        actor: actor,
        action: 'Rejected',
        referenceNo: ref,
        note: reason,
      ),
    );
    notifyListeners();
  }

  /// CSV of all non-draft applications. Every field is quoted.
  String exportCsv({AdminUser? viewer}) {
    const header =
        'reference,name,phone,state,parliamentary,assembly,type,amount,status,created';
    final rows = search(viewer: viewer).map((a) {
      final fields = [
        a.referenceNo,
        a.name,
        a.phone,
        a.state,
        a.parliamentary,
        a.assembly,
        a.type.name,
        a.amount.toString(),
        a.status.name,
        a.createdAt.toIso8601String(),
      ];
      return fields.map((f) => '"${f.replaceAll('"', '""')}"').join(',');
    });
    return [header, ...rows].join('\n');
  }

  String _randomCode(int length) {
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    return List.generate(
      length,
      (_) => chars[_random.nextInt(chars.length)],
    ).join();
  }
}
