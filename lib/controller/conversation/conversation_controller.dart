import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:startup_mobile/models/ConversationModel.dart';
import 'package:startup_mobile/repository/conversation/conversation_repository.dart';

part 'conversation_controller.g.dart';

@riverpod
class ConversationController extends _$ConversationController {
  @override
  FutureOr<void> build() {}

  /// Action : ouvrir ou récupérer une conversation liée à un projet.
  Future<ConversationModel?> ouvrirConversation(int projetId) async {
    if (state.isLoading) return null;

    state = const AsyncLoading();

    try {
      // Récupérer le repository avant l'appel asynchrone.
      final repository = ref.read(conversationRepositoryProvider);

      final conversation = await repository.ouvrirConversation(projetId);

      // Le provider peut avoir été détruit pendant l'appel HTTP.
      if (!ref.mounted) return conversation;

      state = const AsyncData(null);

      return conversation;
    } catch (e, st) {
      // Ne pas modifier state si le provider a été détruit.
      if (!ref.mounted) return null;

      state = AsyncError(e, st);

      return null;
    }
  }
}
