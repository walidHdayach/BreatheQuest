import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../screens/onboarding_screen.dart';
import '../screens/login_screen.dart';
import '../screens/home_screen.dart';
import '../screens/session_screen.dart';
import '../screens/result_screen.dart';
import '../screens/profile_screen.dart';
import '../utils/prefs.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    redirect: (context, state) async {
      final isLoggedIn = authState.valueOrNull != null;
      final location = state.uri.path;
      final isOnboarding = location == '/onboarding';
      final isLogin = location == '/login';

      final seenOnboarding = await ref.read(hasSeenOnboardingProvider.future);
      if (!seenOnboarding && !isOnboarding && !isLogin) {
        return '/onboarding';
      }
      if (!isLoggedIn && !isOnboarding && !isLogin) {
        return '/login';
      }
      if (isLoggedIn && (isLogin || isOnboarding)) {
        return '/home';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (_, __) => const Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (_, __) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (_, __) => const HomeScreen(),
      ),
      GoRoute(
        path: '/session/:mode',
        builder: (context, state) {
          final mode = state.pathParameters['mode']!;
          return SessionScreen(mode: mode);
        },
      ),
      GoRoute(
        path: '/result',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return ResultScreen(
            mode: extra?['mode'] as String? ?? 'calm',
            durationSec: extra?['durationSec'] as int? ?? 0,
            cycles: extra?['cycles'] as int? ?? 0,
            score: extra?['score'] as int? ?? 0,
          );
        },
      ),
      GoRoute(
        path: '/profile',
        builder: (_, __) => const ProfileScreen(),
      ),
    ],
  );
});
