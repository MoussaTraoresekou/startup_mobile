import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:startup_mobile/cor/storage/token_storage.dart';
import 'package:startup_mobile/models/ConversationModel.dart';
import 'package:startup_mobile/models/ProjetModel%20.dart';
import 'package:startup_mobile/pages/Investisseur/investisseurAcceuil.dart';
import 'package:startup_mobile/pages/Investisseur/investor_project_detail_screen.dart';
import 'package:startup_mobile/pages/Login/loginscreen.dart';
import 'package:startup_mobile/pages/chat/private_chat_screen.dart';
import 'package:startup_mobile/pages/register/registerScreen.dart';
import 'package:startup_mobile/pages/secteur/secteurPourInv.dart';
import 'package:startup_mobile/pages/splush/splushScreen.dart';

part 'routes.g.dart';

enum AppRoutes {
  splash,
  login,
  register,
  sectorsSelection,
  investorDashboard, projetDetail,
}

const Set<String> _publicRoutes = {'/splash', '/login', '/register'};
const Set<String> _guestOnlyRoutes = {'/login', '/register'};

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  final storage = ref.watch(secureStorageProvider);

  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true,

    redirect: (context, state) async {
      final location = state.matchedLocation;

      if (location == '/splash') return null;

      final token = await storage.read(key: 'jwt_token');
      final isLoggedIn = token != null && token.trim().isNotEmpty;

      if (!isLoggedIn && !_publicRoutes.contains(location)) {
        return '/login';
      }

      if (isLoggedIn) {
        final profileCompletedStr = await storage.read(key: 'profile_completed');
        
        // CORRECTION : Si la valeur est null (première installation), on considère par défaut que le profil est complété 
        // SAUF si l'état a été explicitement mis à 'false' par le processus d'authentification.
        final isProfileCompleted = profileCompletedStr != 'false';

        if (!isProfileCompleted && location != '/choix-secteurs') {
          return '/choix-secteurs';
        }

        if (isProfileCompleted && location == '/choix-secteurs') {
          return '/investor-dashboard';
        }

        if (_guestOnlyRoutes.contains(location)) {
          return isProfileCompleted ? '/investor-dashboard' : '/choix-secteurs';
        }
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
      GoRoute(
        path: '/choix-secteurs',
        name: AppRoutes.sectorsSelection.name,
        builder: (context, state) => const secteurPourInv(),
      ),
      GoRoute(
        path: '/investor-dashboard',
        name: AppRoutes.investorDashboard.name,
        builder: (context, state) => const InvestorDashboardScreen(),
      ),
      GoRoute(
        name: AppRoutes.projetDetail.name,
        path: '/detailactive',
        builder: (context, state) {
           final projet = state.extra as ProjetModel;

          return InvestorProjectDetailScreen(projet: projet);
        },
      ),
      GoRoute(
  path: '/conversation',
  builder: (context, state) {
    final conversation = state.extra as ConversationModel;
    final tokenStorage = ref.read(tokenStorageProvider);

    return FutureBuilder<int?>(
      future: tokenStorage.readUserId(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final utilisateurId = snapshot.data;

        if (utilisateurId == null) {
          return const Scaffold(
            body: Center(
              child: Text(
                'Impossible de récupérer votre compte. '
                'Veuillez vous reconnecter.',
              ),
            ),
          );
        }

        return PrivateChatScreen(
          conversationId: conversation.id,
          interlocuteurNom: conversation.porteurNom,
          projetTitre: conversation.projetTitre,
          utilisateurConnecteId: utilisateurId,
        );
      },
    );
  },
),
    ],
  );
}
