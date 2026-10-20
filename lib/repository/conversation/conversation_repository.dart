
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:startup_mobile/cor/reseau/dio_provider.dart';
import 'package:startup_mobile/models/ConversationModel.dart';

part 'conversation_repository.g.dart';

class ConversationRepository {
  final Dio _dio;

  ConversationRepository(this._dio);

  Future<ConversationModel> ouvrirConversation(int projetId) async {
    try {
      final response = await _dio.post(
        '/api/conversations/projet/$projetId',
      );

      return ConversationModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      throw Exception(_messageErreur(
        e,
        'Impossible d’ouvrir la conversation.',
      ));
    } on FormatException {
      throw Exception('Les données de la conversation sont invalides.');
    } catch (e) {
      throw Exception(
        'Impossible de traiter les données de la conversation.',
      );
    }
  }

  Future<List<ConversationModel>> mesConversations() async {
    try {
      final response = await _dio.get(
        '/api/conversations/mes-conversations',
      );

      final data = response.data as List<dynamic>;

      return data
          .map(
            (item) => ConversationModel.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();
    } on DioException catch (e) {
      throw Exception(_messageErreur(
        e,
        'Impossible de charger les conversations.',
      ));
    } catch (e) {
      throw Exception(
        'Impossible de traiter la liste des conversations.',
      );
    }
  }

  String _messageErreur(DioException e, String parDefaut) {
    final data = e.response?.data;

    if (data is Map && data['message'] is String) {
      return data['message'] as String;
    }

    if (e.response == null) {
      return 'Impossible de joindre le serveur.';
    }

    if (e.response?.statusCode == 401) {
      return 'Votre session a expiré. Veuillez vous reconnecter.';
    }

    if (e.response?.statusCode == 403) {
      return 'Vous n’êtes pas autorisé à accéder à cette conversation.';
    }

    return parDefaut;
  }
}

@riverpod
ConversationRepository conversationRepository(Ref ref) {
  return ConversationRepository(ref.watch(dioProvider));
}
