import 'package:go_router/go_router.dart';

import 'screens/admin/admin_audit_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/admin/admin_detail_screen.dart';
import 'screens/admin/admin_list_screen.dart';
import 'screens/admin/admin_login_screen.dart';
import 'screens/member/home_screen.dart';
import 'screens/member/landing_screen.dart';
import 'screens/member/language_screen.dart';
import 'screens/member/membership_card_screen.dart';
import 'screens/member/otp_screen.dart';
import 'screens/member/payment_result_screen.dart';
import 'screens/member/payment_screen.dart';
import 'screens/member/phone_screen.dart';
import 'screens/member/register_screen.dart';
import 'screens/member/review_screen.dart';
import 'screens/member/role_screen.dart';
import 'screens/member/status_screen.dart';
import 'screens/member/submitted_screen.dart';

/// Member screens are nested under /home and admin screens under /admin/dashboard, so `context.go`
/// always leaves a parent on the stack. That keeps the iOS back button and swipe-back working
/// after flows that replace the stack, such as payment.
GoRouter buildRouter() {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const LandingScreen()),
      GoRoute(
        path: '/language',
        builder: (context, state) => const LanguageScreen(),
        routes: [
          GoRoute(
            path: 'role',
            builder: (context, state) => const RoleScreen(),
          ),
          GoRoute(
            path: 'phone',
            builder: (context, state) => const PhoneScreen(),
            routes: [
              GoRoute(
                path: 'otp',
                builder: (context, state) => const OtpScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/phone',
        builder: (context, state) => const PhoneScreen(),
        routes: [
          GoRoute(path: 'otp', builder: (context, state) => const OtpScreen()),
        ],
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
        routes: [
          GoRoute(
            path: 'register',
            builder: (context, state) => RegisterScreen(
              initialStep:
                  int.tryParse(state.uri.queryParameters['step'] ?? '') ?? 0,
            ),
          ),
          GoRoute(
            path: 'submitted',
            builder: (context, state) =>
                SubmittedScreen(referenceNo: state.extra as String? ?? ''),
          ),
          GoRoute(
            path: 'review',
            builder: (context, state) => const ReviewScreen(),
          ),
          GoRoute(
            path: 'payment',
            builder: (context, state) => const PaymentScreen(),
          ),
          GoRoute(
            path: 'payment-result',
            builder: (context, state) => PaymentResultScreen(
              success: state.uri.queryParameters['success'] == 'true',
            ),
          ),
          GoRoute(
            path: 'status',
            builder: (context, state) => const StatusScreen(),
            routes: [
              GoRoute(
                path: 'card',
                builder: (context, state) => const MembershipCardScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminLoginScreen(),
        routes: [
          GoRoute(
            path: 'dashboard',
            builder: (context, state) => const AdminDashboardScreen(),
            routes: [
              GoRoute(
                path: 'list',
                builder: (context, state) => const AdminListScreen(),
              ),
              GoRoute(
                path: 'detail/:ref',
                builder: (context, state) => AdminDetailScreen(
                  referenceNo: state.pathParameters['ref'] ?? '',
                ),
              ),
              GoRoute(
                path: 'audit',
                builder: (context, state) => const AdminAuditScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
