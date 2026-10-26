import 'package:go_router/go_router.dart';
import 'screens/placeholder_screen.dart';

GoRouter buildRouter() {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (c, s) => const PlaceholderScreen(title: 'AIPC')),
      GoRoute(path: '/language', builder: (c, s) => const PlaceholderScreen(title: 'Language')),
      GoRoute(path: '/phone', builder: (c, s) => const PlaceholderScreen(title: 'Phone')),
      GoRoute(path: '/otp', builder: (c, s) => const PlaceholderScreen(title: 'OTP')),
      GoRoute(path: '/home', builder: (c, s) => const PlaceholderScreen(title: 'Home')),
      GoRoute(path: '/register', builder: (c, s) => const PlaceholderScreen(title: 'Register')),
      GoRoute(path: '/review', builder: (c, s) => const PlaceholderScreen(title: 'Review')),
      GoRoute(path: '/payment', builder: (c, s) => const PlaceholderScreen(title: 'Payment')),
      GoRoute(path: '/payment-result', builder: (c, s) => const PlaceholderScreen(title: 'Payment result')),
      GoRoute(path: '/status', builder: (c, s) => const PlaceholderScreen(title: 'Status')),
      GoRoute(path: '/card', builder: (c, s) => const PlaceholderScreen(title: 'Membership card')),
      GoRoute(path: '/admin', builder: (c, s) => const PlaceholderScreen(title: 'Admin login')),
      GoRoute(path: '/admin/dashboard', builder: (c, s) => const PlaceholderScreen(title: 'Dashboard')),
      GoRoute(path: '/admin/list', builder: (c, s) => const PlaceholderScreen(title: 'Applications')),
      GoRoute(path: '/admin/detail/:ref', builder: (c, s) => PlaceholderScreen(title: s.pathParameters['ref'] ?? '')),
      GoRoute(path: '/admin/audit', builder: (c, s) => const PlaceholderScreen(title: 'Audit log')),
    ],
  );
}
