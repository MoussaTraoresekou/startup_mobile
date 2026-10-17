import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:startup_mobile/pages/Login/loginscreen.dart';
import 'package:startup_mobile/pages/register/registerScreen.dart';
import 'package:startup_mobile/pages/splush/splushScreen.dart';


part 'routes.g.dart';

enum AppRoutes {
  splash,
  login,
  investorDashboard,
  register,
}

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

@riverpod
GoRouter appRouter(Ref ref) {
  final storage = ref.watch(secureStorageProvider);

  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true,

    redirect: (context, state) async {
      final token = await storage.read(key: 'jwt_token');
      final currentLoc = state.matchedLocation;

      if (currentLoc == '/splash' || currentLoc == '/register') {
        return null;
      }

      if (token == null && currentLoc != '/login') {
        return '/login';
      }

      if (token != null && (currentLoc == '/login' || currentLoc == '/splash')) {
        return '/investor-dashboard';
      }

      return null;
    },

    routes: [
      GoRoute(
        path: '/splash',
        name: AppRoutes.splash.name,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        name: AppRoutes.login.name,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: AppRoutes.register.name,
        builder: (context, state) => const RegisterScreen(),
      ),
      /*
      GoRoute(
        path: '/investor-dashboard',
        name: AppRoutes.investorDashboard.name,
        builder: (context, state) => const InvestorDashboardScreen(),
      ),
      */
    ],
  );
}
