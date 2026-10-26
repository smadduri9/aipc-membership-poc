import 'package:go_router/go_router.dart';

import 'screens/admin/admin_audit_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/admin/admin_detail_screen.dart';
import 'screens/admin/admin_list_screen.dart';
import 'screens/admin/admin_login_screen.dart';
import 'screens/member/home_screen.dart';
import 'screens/member/membership_card_screen.dart';
import 'screens/member/payment_result_screen.dart';
import 'screens/member/payment_screen.dart';
import 'screens/member/status_screen.dart';
import 'screens/member/register_screen.dart';
import 'screens/member/review_screen.dart';
import 'screens/member/language_screen.dart';
import 'screens/member/otp_screen.dart';
import 'screens/member/phone_screen.dart';
import 'screens/member/splash_screen.dart';

GoRouter buildRouter() {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/language', builder: (context, state) => const LanguageScreen()),
      GoRoute(path: '/phone', builder: (context, state) => const PhoneScreen()),
      GoRoute(path: '/otp', builder: (context, state) => const OtpScreen()),
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => RegisterScreen(
          initialStep: int.tryParse(state.uri.queryParameters['step'] ?? '') ?? 0,
          editing: state.uri.queryParameters['edit'] == '1',
        ),
      ),
      GoRoute(path: '/review', builder: (context, state) => const ReviewScreen()),
      GoRoute(path: '/payment', builder: (context, state) => const PaymentScreen()),
      GoRoute(
        path: '/payment-result',
        builder: (context, state) => PaymentResultScreen(success: state.uri.queryParameters['success'] == 'true'),
      ),
      GoRoute(path: '/status', builder: (context, state) => const StatusScreen()),
      GoRoute(path: '/card', builder: (context, state) => const MembershipCardScreen()),
      GoRoute(path: '/admin', builder: (context, state) => const AdminLoginScreen()),
      GoRoute(path: '/admin/dashboard', builder: (context, state) => const AdminDashboardScreen()),
      GoRoute(path: '/admin/list', builder: (context, state) => const AdminListScreen()),
      GoRoute(
        path: '/admin/detail/:ref',
        builder: (context, state) => AdminDetailScreen(referenceNo: state.pathParameters['ref'] ?? ''),
      ),
      GoRoute(path: '/admin/audit', builder: (context, state) => const AdminAuditScreen()),
    ],
  );
}
