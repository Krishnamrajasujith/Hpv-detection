import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'services/auth_service.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/auth/verify_otp_screen.dart';
import 'screens/auth/reset_password_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/dashboard/history_screen.dart';
import 'screens/dashboard/profile_screen.dart';
import 'screens/admin/admin_screen.dart';
import 'screens/admin/admin_users_screen.dart';
import 'screens/admin/admin_reports_screen.dart';
import 'screens/admin/admin_audit_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authNotifier = ref.watch(authStateProvider.notifier);

  return GoRouter(
    initialLocation: '/dashboard',
    redirect: (context, state) {
      final isLoggedIn = ref.read(authStateProvider) != null;
      final isAuthRoute = state.matchedLocation.startsWith('/login') ||
          state.matchedLocation.startsWith('/register') ||
          state.matchedLocation.startsWith('/forgot') ||
          state.matchedLocation.startsWith('/verify') ||
          state.matchedLocation.startsWith('/reset');

      if (!isLoggedIn && !isAuthRoute) return '/login';
      if (isLoggedIn && isAuthRoute) return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (c, s) => const LoginScreen()),
      GoRoute(path: '/register', builder: (c, s) => const RegisterScreen()),
      GoRoute(path: '/forgot-password', builder: (c, s) => const ForgotPasswordScreen()),
      GoRoute(
        path: '/verify-otp',
        builder: (c, s) => VerifyOTPScreen(
          email: s.extra != null ? (s.extra as Map)['email'] as String : '',
          purpose: s.extra != null ? (s.extra as Map)['purpose'] as String : 'register',
        ),
      ),
      GoRoute(
        path: '/reset-password',
        builder: (c, s) => ResetPasswordScreen(
          email: s.extra != null ? (s.extra as Map)['email'] as String : '',
        ),
      ),
      GoRoute(path: '/dashboard', builder: (c, s) => const DashboardScreen()),
      GoRoute(path: '/history', builder: (c, s) => const HistoryScreen()),
      GoRoute(path: '/profile', builder: (c, s) => const ProfileScreen()),
      GoRoute(path: '/admin', builder: (c, s) => const AdminScreen()),
      GoRoute(path: '/admin/users', builder: (c, s) => const AdminUsersScreen()),
      GoRoute(path: '/admin/reports', builder: (c, s) => const AdminReportsScreen()),
      GoRoute(path: '/admin/audit', builder: (c, s) => const AdminAuditScreen()),
    ],
  );
});
