import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:startup_mobile/repository/auth_repository.dart';
import '../../models/InvestorRegisterDto.dart';
import '../../models/LoginResponse.dart';

part 'auth_controller.g.dart';

@riverpod
class AuthController extends _$AuthController {
  @override
  FutureOr<void> build() async {
    return null;
  }

  /// Connexion de l'investisseur auprès du serveur Spring Boot
  Future<LoginResponse?> login({
    required String email,
    required String password,
  }) async {
    if (email.trim().isEmpty || password.trim().isEmpty) {
      state = AsyncError(
        'Veuillez remplir tous les champs !',
        StackTrace.current,
      );
      return null;
    }

    state = const AsyncLoading();

    final result = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).login(
            email.trim(),
            password,
          ),
    );

    state = result;

    if (!state.hasError && result.value != null) {
      final loginResponse = result.value!;
      print("Authentifié avec succès : ${loginResponse.prenom} ${loginResponse.nom}");
      print("Rôle système détecté : ${loginResponse.role}");
      return loginResponse;
    }

    return null;
  }

  /// Inscription d'un nouvel investisseur (Vérifications locales avant envoi MySQL)
  Future<bool> inscrirIvestisseur({
    required String nom,
    required String prenom,
    required String email,
    required String telephone,
    required String password,
    required String typeInvestisseurCode,
  }) async {
    if (nom.trim().isEmpty ||
        prenom.trim().isEmpty ||
        email.trim().isEmpty ||
        telephone.trim().isEmpty ||
        password.trim().isEmpty ||
        typeInvestisseurCode.isEmpty) {
      state = AsyncError(
        'Veuillez remplir toutes les informations obligatoires !',
        StackTrace.current,
      );
      return false;
    }

    if (password.length < 6) {
      state = AsyncError(
        'Le mot de passe doit contenir au moins 6 caractères.',
        StackTrace.current,
      );
      return false;
    }

    state = const AsyncLoading();

    final dto = InvestorRegisterDto(
      nom: nom.trim(),
      prenom: prenom.trim(),
      email: email.trim(),
      telephone: telephone.trim(),
      password: password,
      typeInvestisseurCode: typeInvestisseurCode,
    );

    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).register(dto),
    );

    return !state.hasError;
  }

  /// Déconnexion locale et suppression du jeton JWT
  Future<void> logout() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).logout(),
    );
  }
}
