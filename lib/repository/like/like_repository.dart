import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:startup_mobile/cor/reseau/dio_provider.dart';

part 'like_repository.g.dart';

// =============================================================================
// REPOSITORY : appels vers le backend
// =============================================================================

class LikeRepository {
  final Dio _dio;

  LikeRepository(this._dio);

  /// Identifiants des projets déjà aimés par l'investisseur connecté.
  Future<Set<int>> getMesLikes() async {
    try {
      final response = await _dio.get('/api/investisseur/likes');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data.map((id) => id as int).toSet();
      }
      throw Exception('Impossible de charger vos likes.');
    } on DioException catch (e) {
      throw Exception(_messageErreur(e, 'Erreur réseau lors du chargement des likes.'));
    }
  }

  /// Bascule le like. Retourne true si le projet est maintenant aimé.
  Future<bool> basculerLike(int projetId) async {
    try {
      final response =
          await _dio.post('/api/investisseur/projet/$projetId/like');
      if (response.statusCode == 200) {
        return response.data['liked'] as bool;
      }
      throw Exception('Impossible de mettre à jour le like.');
    } on DioException catch (e) {
      throw Exception(_messageErreur(e, 'Erreur réseau lors de la mise à jour du like.'));
    }
  }

  String _messageErreur(DioException e, String parDefaut) {
    final data = e.response?.data;
    if (data is Map && data['message'] is String) {
      return data['message'] as String;
    }
    return parDefaut;
  }
}

@riverpod
LikeRepository likeRepository(Ref ref) {
  final dio = ref.watch(dioProvider);
  return LikeRepository(dio);
}

// =============================================================================
// PROVIDER : l'état des likes, partagé par tous les écrans
// =============================================================================

@riverpod
class Likes extends _$Likes {
  @override
  Future<Set<int>> build() {
    return ref.read(likeRepositoryProvider).getMesLikes();
  }

  Future<void> basculer(int projetId) async {
    final avant = state.value ?? <int>{};
    final dejaAime = avant.contains(projetId);

    // 1. On met l'écran à jour tout de suite, sans attendre le serveur
    state = AsyncData(
      dejaAime ? ({...avant}..remove(projetId)) : {...avant, projetId},
    );

    // 2. On prévient le serveur ; en cas d'erreur, on revient en arrière
    try {
      await ref.read(likeRepositoryProvider).basculerLike(projetId);
    } catch (e) {
      state = AsyncData(avant);
      rethrow;
    }
  }
}