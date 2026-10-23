
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:startup_mobile/cor/reseau/dio_provider.dart';

part 'like_repository.g.dart';

class LikeRepository {
  final Dio _dio;

  LikeRepository(this._dio);

  Future<Set<int>> getMesLikes() async {
    try {
      final response = await _dio.get('/api/investisseur/likes');

      if (response.statusCode != 200) {
        throw Exception('Impossible de charger vos likes.');
      }

      final data = response.data as List<dynamic>;

      return data.map((id) {
        if (id is num) return id.toInt();
        return int.parse(id.toString());
      }).toSet();
    } on DioException catch (e) {
      throw Exception(
        _messageErreur(
          e,
          'Erreur réseau lors du chargement des likes.',
        ),
      );
    }
  }

  Future<Map<String, dynamic>> basculerLike(int projetId) async {
    try {
      final response = await _dio.post(
        '/api/investisseur/projet/$projetId/like',
      );

      if (response.statusCode != 200) {
        throw Exception('Impossible de mettre à jour le like.');
      }

      final data = Map<String, dynamic>.from(response.data as Map);
      final liked = data['liked'];
      final nombreLikes = data['nombreLikes'];

      if (liked is! bool || nombreLikes is! num) {
        throw Exception(
          'Réponse du serveur invalide : '
          'liked et nombreLikes sont attendus.',
        );
      }

      return {
        'liked': liked,
        'nombreLikes': nombreLikes.toInt(),
      };
    } on DioException catch (e) {
      throw Exception(
        _messageErreur(
          e,
          'Erreur réseau lors de la mise à jour du like.',
        ),
      );
    }
  }

  String _messageErreur(DioException e, String parDefaut) {
    final data = e.response?.data;

    if (data is Map) {
      final message =
          data['message'] ?? data['error'] ?? data['detail'];

      if (message != null && message.toString().trim().isNotEmpty) {
        return message.toString();
      }
    }

    if (e.response?.statusCode == 401) {
      return 'Votre session a expiré. Veuillez vous reconnecter.';
    }

    if (e.response?.statusCode == 403) {
      return 'Vous n’êtes pas autorisé à effectuer cette action.';
    }

    return parDefaut;
  }
}

@riverpod
LikeRepository likeRepository(Ref ref) {
  return LikeRepository(ref.watch(dioProvider));
}

/// État partagé des projets aimés par l'investisseur.
@riverpod
class Likes extends _$Likes {
  final Set<int> _projetsEnCours = {};

  @override
  Future<Set<int>> build() {
    return ref.read(likeRepositoryProvider).getMesLikes();
  }

  Future<int> basculer(int projetId) async {
    if (_projetsEnCours.contains(projetId)) {
      throw Exception('Une opération est déjà en cours pour ce projet.');
    }

    _projetsEnCours.add(projetId);

    try {
      // Attend le chargement initial si nécessaire.
      final avant = state.value ?? await future;

      // Mise à jour optimiste du cœur.
      final likesOptimistes = {...avant};
      final dejaAime = likesOptimistes.contains(projetId);

      if (dejaAime) {
        likesOptimistes.remove(projetId);
      } else {
        likesOptimistes.add(projetId);
      }

      state = AsyncData(likesOptimistes);

      try {
        final resultat = await ref
            .read(likeRepositoryProvider)
            .basculerLike(projetId);

        final liked = resultat['liked'] as bool;
        final nombreLikes = resultat['nombreLikes'] as int;

        // Le serveur décide de l'état final du cœur.
        final likesActualises = {...(state.value ?? likesOptimistes)};

        if (liked) {
          likesActualises.add(projetId);
        } else {
          likesActualises.remove(projetId);
        }

        state = AsyncData(likesActualises);

        // Compteur commun au tableau de bord et au détail.
        ref
            .read(likeCountsProvider.notifier)
            .setCount(projetId, nombreLikes);

        return nombreLikes;
      } catch (_) {
        // Restaure l'état antérieur si le serveur échoue.
        state = AsyncData(avant);
        rethrow;
      }
    } finally {
      _projetsEnCours.remove(projetId);
    }
  }
}

/// Source de vérité commune pour les compteurs de likes.
@Riverpod(keepAlive: true)
class LikeCounts extends _$LikeCounts {
  @override
  Map<int, int> build() => {};

  void setCount(int projetId, int nombreLikes) {
    state = {
      ...state,
      projetId: nombreLikes,
    };
  }
}
