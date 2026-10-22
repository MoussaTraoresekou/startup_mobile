import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:startup_mobile/models/message_response_model.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'package:startup_mobile/cor/reseau/dio_provider.dart';
import 'package:startup_mobile/cor/storage/token_storage.dart';
import 'package:flutter/foundation.dart';

part 'message_repository.g.dart';

class MessageRepository {
  final Dio _dio;
  final TokenStorage _tokenStorage;

  StompClient? _client;
  int? _conversationConnectee;
  bool _connecte = false;

  final StreamController<MessageResponseModel> _messagesController =
      StreamController<MessageResponseModel>.broadcast();

  MessageRepository(this._dio, this._tokenStorage);

  /// Flux des nouveaux messages reçus par WebSocket.
  Stream<MessageResponseModel> get messages => _messagesController.stream;

  /// Récupère l'historique d'une conversation depuis Spring Boot.
  Future<List<MessageResponseModel>> historique(int conversationId) async {
    try {
      final response = await _dio.get(
        '/api/conversations/$conversationId/messages',
      );

      final data = response.data as List<dynamic>;

      return data
          .map(
            (item) => MessageResponseModel.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();
    } on DioException catch (e) {
      throw Exception(_messageErreur(e, 'Impossible de charger les messages.'));
    }
  }

  /// Lit le JWT et ouvre la connexion WebSocket d'une conversation.
  
Future<void> connecterConversation(int conversationId) async {
  final token = await _tokenStorage.readToken();

  if (token == null || token.isEmpty) {
    throw Exception('Session expirée. Veuillez vous reconnecter.');
  }

  if (_conversationConnectee == conversationId &&
      _client != null &&
      _connecte) {
    return;
  }

  deconnecter();

  final baseUri = Uri.parse(_dio.options.baseUrl);

  final websocketUri = Uri(
    scheme: baseUri.scheme == 'https' ? 'wss' : 'ws',
    host: baseUri.host,
    port: baseUri.hasPort ? baseUri.port : null,
    path: '/ws',
  );

  final completer = Completer<void>();

  late final StompClient client;

  client = StompClient(
    config: StompConfig(
      url: websocketUri.toString(),
      stompConnectHeaders: {
        'Authorization': 'Bearer $token',
      },
      onConnect: (frame) {
        _connecte = true;

        client.subscribe(
          destination: '/topic/conversations/$conversationId',
          callback: (frame) {
            final body = frame.body;
            if (body == null || body.isEmpty) return;

            try {
              final json = jsonDecode(body) as Map<String, dynamic>;
              final message = MessageResponseModel.fromJson(json);

              if (message.conversationId == conversationId &&
                  !_messagesController.isClosed) {
                _messagesController.add(message);
              }
            } catch (e) {
              // Ignorer les messages mal formés.
            }
          },
        );

        if (!completer.isCompleted) {
          completer.complete();
        }
      },
      onStompError: (frame) {
        _connecte = false;

        if (!completer.isCompleted) {
          completer.completeError(
            Exception(
              'Erreur STOMP : ${frame.body ?? "connexion refusée"}',
            ),
          );
        }
      },
      onWebSocketError: (error) {
        _connecte = false;

        if (!completer.isCompleted) {
          completer.completeError(
            Exception('Erreur WebSocket : $error'),
          );
        }
      },
      onDisconnect: (frame) {
        _connecte = false;
      },
    ),
  );

  _client = client;
  _conversationConnectee = conversationId;

  client.activate();

  try {
    await completer.future.timeout(
      const Duration(seconds: 15),
      onTimeout: () {
        throw TimeoutException(
          'La connexion WebSocket n’a pas été établie en 15 secondes.',
        );
      },
    );
  } catch (_) {
    if (identical(_client, client)) {
      deconnecter();
    }
    rethrow;
  }
}


  /// Envoie un message au contrôleur WebSocket Spring Boot.
  /*
  Future<void> envoyerMessage({
    required int conversationId,
    required String contenu,
  }) async {
    final texte = contenu.trim();

    if (texte.isEmpty) {
      throw Exception('Le message ne peut pas être vide.');
    }

    final client = _client;

    if (client == null ||
        !_connecte ||
        _conversationConnectee != conversationId) {
      throw Exception('La messagerie n’est pas connectée.');
    }

    client.send(
      destination: '/app/conversations/$conversationId/envoyer',
      body: jsonEncode({'contenu': texte}),
    );
  }
  */
  Future<void> envoyerMessage({
  required int conversationId,
  required String contenu,
}) async {
  final texte = contenu.trim();

  if (texte.isEmpty) {
    throw Exception('Le message ne peut pas être vide.');
  }

  final client = _client;

  if (client == null ||
      !_connecte ||
      _conversationConnectee != conversationId) {
    debugPrint('ENVOI IMPOSSIBLE : WebSocket non connecté.');
    debugPrint('Conversation demandée : $conversationId');
    debugPrint('Conversation connectée : $_conversationConnectee');
    debugPrint('Client présent : ${client != null}');
    debugPrint('STOMP connecté : $_connecte');

    throw Exception(
      'La messagerie n’est pas connectée. '
      'Veuillez quitter puis rouvrir la conversation.',
    );
  }

  try {
    debugPrint('ENVOI STOMP : /app/conversations/$conversationId/envoyer');
    debugPrint('CONTENU DU MESSAGE : $texte');

    client.send(
      destination: '/app/conversations/$conversationId/envoyer',
      body: jsonEncode({'contenu': texte}),
    );

    debugPrint('TRAME STOMP ENVOYÉE.');
  } catch (e, stackTrace) {
    debugPrint('ERREUR ENVOI STOMP : $e');
    debugPrint('$stackTrace');
    rethrow;
  }
}

  /// Ferme la connexion WebSocket.
  void deconnecter() {
    final client = _client;

    _client = null;
    _conversationConnectee = null;
    _connecte = false;

    if (client != null) {
      client.deactivate();
    }
  }

  /// Libère les ressources du repository.
  Future<void> dispose() async {
    deconnecter();
    await _messagesController.close();
  }

  String _messageErreur(DioException e, String parDefaut) {
    final data = e.response?.data;

    if (data is Map && data['message'] is String) {
      return data['message'] as String;
    }

    if (e.response == null) {
      return 'Impossible de joindre le serveur.';
    }

    return parDefaut;
  }
}

@Riverpod(keepAlive: true)
MessageRepository messageRepository(Ref ref) {
  final repository = MessageRepository(
    ref.watch(dioProvider),
    ref.watch(tokenStorageProvider),
  );

  ref.onDispose(() {
    repository.dispose();
  });

  return repository;
}

/// Provider pour récupérer l'historique d'une conversation.
@riverpod
Future<List<MessageResponseModel>> historiqueMessages(
  Ref ref,
  int conversationId,
) {
  return ref.watch(messageRepositoryProvider).historique(conversationId);
}
