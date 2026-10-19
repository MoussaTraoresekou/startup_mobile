import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:startup_mobile/cor/reseau/dio_provider.dart';
import 'package:startup_mobile/cor/storage/token_storage.dart';
import 'package:startup_mobile/repository/profilInvestisseur/ProfileRepository.dart';

part 'profile_controller.g.dart';

@riverpod
class ProfileController extends _$ProfileController {
  @override
  FutureOr<void> build() {
    // État de repos initial
  }

  /// Transmet la liste des IDs des secteurs cochés à Spring Boot
  Future<bool> enregistrerSecteurs(List<int> secteurIds) async {
    if (state.isLoading) return false;

    if (secteurIds.isEmpty) {
      state = AsyncError(
        'Veuillez sélectionner au moins un secteur ou cliquer sur Passer.',
        StackTrace.current,
      );
      return false;
    }

    state = const AsyncLoading();

    final result = await AsyncValue.guard(() async {
      // 1. Envoi de la requête PUT à Spring Boot
      await ref.read(profileRepositoryProvider).saveSecteurs(secteurIds);
      
      // 2. Mise à jour de la session locale pour libérer l'aiguillage du GoRouter
      await ref.read(tokenStorageProvider).saveProfileStatus(true);
    });

    state = result;
    return !result.hasError;
  }

  /// Action du bouton « Passer »
  Future<bool> passerEtape() async {
    if (state.isLoading) return false;

    state = const AsyncLoading();

    final result = await AsyncValue.guard(() async {
      // 1. Envoi de la requête POST /passer à Spring Boot
      await ref.read(profileRepositoryProvider).skip();
      
      // 2. Mémorisation locale pour ne plus bloquer l'investisseur au démarrage
      await ref.read(tokenStorageProvider).saveProfileStatus(true);
    });

    state = result;
    return !result.hasError;
  }
}
