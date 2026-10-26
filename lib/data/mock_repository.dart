import 'dart:math';

import 'package:flutter/foundation.dart';

import '../models/application.dart';
import 'mock_data.dart';

/// In-memory stand-in for a backend. Every call waits briefly so the UI feels real.
/// Data resets when the app restarts.
class MockRepository extends ChangeNotifier {
  MockRepository()
      : applications = seedApplications(),
        auditLog = [] {
    auditLog.addAll(seedAuditEntries(applications));
  }

  final List<Application> applications;
  final List<AuditEntry> auditLog;
  int _nextSeq = 101;
  final _random = Random();

  Future<void> _wait() => Future.delayed(const Duration(milliseconds: 600));

  Future<void> sendOtp(String phone) async {
    await _wait();
  }

  Future<bool> verifyOtp(String phone, String code) async {
    await _wait();
    return code == '123456';
  }

  /// Latest non-draft application for this phone, or null.
  Application? findByPhone(String phone) {
    final matches = applications
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

  Future<Application> submit(Application draft) async {
    await _wait();
    draft.referenceNo =
        'AIPC-${draft.state}-26-${_nextSeq.toString().padLeft(6, '0')}';
    _nextSeq++;
    draft.status = AppStatus.paymentPending;
    draft.history.add(StatusEvent(AppStatus.paymentPending, DateTime.now()));
    if (!applications.contains(draft)) applications.add(draft);
    notifyListeners();
    return draft;
  }

  /// Simulates a payment result. Success goes straight to approval pending, as the SOP requires.
  Future<void> fakePay(String ref, {required bool success}) async {
    await _wait();
    final app = findByRef(ref);
    if (app == null) return;
    final now = DateTime.now();
    if (success) {
      app.paymentId = 'pay_Demo${_randomCode(6)}';
      app.status = AppStatus.paymentVerified;
      app.history.add(StatusEvent(AppStatus.paymentVerified, now));
      app.status = AppStatus.approvalPending;
      app.history.add(StatusEvent(AppStatus.approvalPending, now));
    } else {
      app.status = AppStatus.paymentFailed;
      app.history.add(StatusEvent(AppStatus.paymentFailed, now));
    }
    notifyListeners();
  }

  Future<bool> adminLogin(String email, String password) async {
    await _wait();
    return email == 'admin@aipc.demo' && password == 'demo1234';
  }

  /// Synchronous search over non-draft applications, newest first.
  List<Application> search({String? state, AppStatus? status, String query = ''}) {
    final q = query.trim().toLowerCase();
    final result = applications.where((a) {
      if (a.status == AppStatus.draft) return false;
      if (state != null && a.state != state) return false;
      if (status != null && a.status != status) return false;
      if (q.isEmpty) return true;
      return a.referenceNo.toLowerCase().contains(q) ||
          a.phone.startsWith(q) ||
          a.name.toLowerCase().contains(q);
    }).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return result;
  }

  Future<void> approve(String ref, String actor) async {
    await _wait();
    final app = findByRef(ref);
    if (app == null) return;
    final now = DateTime.now();
    app.status = AppStatus.approved;
    app.approvedAt = now;
    app.validUntil = app.type == MembershipType.ordinary
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
  String exportCsv() {
    const header =
        'reference,name,phone,state,parliamentary,assembly,type,amount,status,created';
    final rows = search().map((a) {
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
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    return List.generate(length, (_) => chars[_random.nextInt(chars.length)]).join();
  }
}
