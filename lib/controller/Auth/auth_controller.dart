import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:startup_mobile/repository/auth_repository.dart';
import '../../models/InvestorRegisterDto.dart';
import '../../models/LoginResponse.dart';

part 'auth_controller.g.dart';

// keepAlive : le contrôleur n'est pas détruit si l'utilisateur quitte l'écran
// pendant une requête (évite une erreur en écrivant l'état après coup).
@Riverpod(keepAlive: true)
class AuthController extends _$AuthController {
  @override
  FutureOr<void> build() {}

  /// Cette application est réservée aux investisseurs.
  /// Accepte « INVESTISSEUR » comme « ROLE_INVESTISSEUR ».
  bool _isInvestor(LoginResponse response) {
    return '${response.role}'.toUpperCase().contains('INVESTISSEUR');
  }

  /// Connexion de l'investisseur auprès du serveur Spring Boot
  Future<LoginResponse?> login({
    required String email,
    required String password,
  }) async {
    if (state.isLoading) return null;

    if (email.trim().isEmpty || password.trim().isEmpty) {
      state = AsyncError(
        'Veuillez remplir tous les champs !',
        StackTrace.current,
      );
      return null;
    }

    state = const AsyncLoading();

    final repository = ref.read(authRepositoryProvider);

    final result = await AsyncValue.guard<LoginResponse>(() async {
      final response = await repository.login(email.trim(), password);

      // Un porteur ou un mentor ne doit pas entrer dans l'app investisseur :
      // on supprime le token qui vient d'être enregistré et on refuse.
      if (!_isInvestor(response)) {
        await repository.logout();
        throw Exception('Cette application est réservée aux investisseurs.');
      }

      return response;
    });

    state = result;

    return result.hasError ? null : result.value;
  }

  /// Inscription d'un nouvel investisseur (vérifications locales avant
  /// l'envoi au serveur)
  Future<bool> inscrirIvestisseur({
    required String nom,
    required String prenom,
    required String email,
    required String telephone,
    required String password,
    required String typeInvestisseurCode,
  }) async {
    if (state.isLoading) return false;

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
      // En minuscules, comme au login, pour éviter un compte introuvable
      // à cause de la casse.
      email: email.trim().toLowerCase(),
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