import 'package:go_router/go_router.dart';

import 'screens/member/home_screen.dart';
import 'screens/member/language_screen.dart';
import 'screens/member/otp_screen.dart';
import 'screens/member/phone_screen.dart';
import 'screens/member/splash_screen.dart';
import 'screens/placeholder_screen.dart';

GoRouter buildRouter() {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/language', builder: (context, state) => const LanguageScreen()),
      GoRoute(path: '/phone', builder: (context, state) => const PhoneScreen()),
      GoRoute(path: '/otp', builder: (context, state) => const OtpScreen()),
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
      GoRoute(path: '/register', builder: (context, state) => const PlaceholderScreen(title: 'Register')),
      GoRoute(path: '/review', builder: (context, state) => const PlaceholderScreen(title: 'Review')),
      GoRoute(path: '/payment', builder: (context, state) => const PlaceholderScreen(title: 'Payment')),
      GoRoute(path: '/payment-result', builder: (context, state) => const PlaceholderScreen(title: 'Payment result')),
      GoRoute(path: '/status', builder: (context, state) => const PlaceholderScreen(title: 'Status')),
      GoRoute(path: '/card', builder: (context, state) => const PlaceholderScreen(title: 'Membership card')),
      GoRoute(path: '/admin', builder: (context, state) => const PlaceholderScreen(title: 'Admin login')),
      GoRoute(path: '/admin/dashboard', builder: (context, state) => const PlaceholderScreen(title: 'Dashboard')),
      GoRoute(path: '/admin/list', builder: (context, state) => const PlaceholderScreen(title: 'Applications')),
      GoRoute(path: '/admin/detail/:ref', builder: (context, state) => PlaceholderScreen(title: state.pathParameters['ref'] ?? '')),
      GoRoute(path: '/admin/audit', builder: (context, state) => const PlaceholderScreen(title: 'Audit log')),
    ],
  );
}
