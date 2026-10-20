
import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:startup_mobile/repository/message/message_repository.dart';

part 'messagerie_controller.g.dart';

@riverpod
class MessagerieController extends _$MessagerieController {
  @override
  FutureOr<void> build() {}

  /// Action : connecter une conversation.
  Future<bool> connecter(int conversationId) async {
    if (state.isLoading) return false;

    state = const AsyncLoading();

    final result = await AsyncValue.guard(() async {
      await ref
          .read(messageRepositoryProvider)
          .connecterConversation(conversationId);
    });

    state = result;
    return !result.hasError;
  }

  /// Action : envoyer un message.
  Future<bool> envoyer({
    required int conversationId,
    required String contenu,
  }) async {
    if (state.isLoading) return false;

    if (contenu.trim().isEmpty) {
      state = AsyncError(
        'Le message ne peut pas être vide.',
        StackTrace.current,
      );
      return false;
    }

    state = const AsyncLoading();

    final result = await AsyncValue.guard(() async {
      await ref.read(messageRepositoryProvider).envoyerMessage(
            conversationId: conversationId,
            contenu: contenu.trim(),
          );
    });

    state = result;
    return !result.hasError;
  }

  /// Action : déconnecter la conversation.
  Future<bool> deconnecter() async {
    if (state.isLoading) return false;

    state = const AsyncLoading();

    final result = await AsyncValue.guard(() async {
      ref.read(messageRepositoryProvider).deconnecter();
    });

    state = result;
    return !result.hasError;
  }
}
