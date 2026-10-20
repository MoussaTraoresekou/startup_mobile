import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:startup_mobile/cor/reseau/dio_provider.dart';
import 'package:startup_mobile/model/commentaire_model.dart';

part 'commentaire_repository.g.dart';

class CommentaireRepository {
  final Dio _dio;

  CommentaireRepository(this._dio);

  /// Récupère les commentaires d'un projet.
  Future<List<CommentaireModel>> lister(int projetId) async {
    try {
      final response = await _dio.get(
        '/api/investisseur/projet/$projetId/commentaires',
      );

      final data = response.data as List<dynamic>;

      return data
          .map(
            (item) => CommentaireModel.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();
    } on DioException catch (e) {
      throw Exception(
        _messageErreur(e, 'Impossible de charger les commentaires.'),
      );
    }
  }

  /// Envoie un commentaire au backend.
  Future<CommentaireModel> ajouter(
    int projetId,
    String contenu,
  ) async {
    try {
      final response = await _dio.post(
        '/api/investisseur/projet/$projetId/commentaires',
        data: {
          'contenu': contenu.trim(),
        },
      );

      return CommentaireModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      throw Exception(
        _messageErreur(e, 'Impossible d’envoyer votre commentaire.'),
      );
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
CommentaireRepository commentaireRepository(Ref ref) {
  return CommentaireRepository(ref.watch(dioProvider));
}