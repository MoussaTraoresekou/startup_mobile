import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:startup_mobile/repository/message/message_repository.dart';

part 'messagerie_controller.g.dart';

@Riverpod(keepAlive: true)
class MessagerieController extends _$MessagerieController {
  @override
  FutureOr<void> build() {}

  Future<bool> connecter(int conversationId) async {
    if (state.isLoading) return false;

    final repository = ref.read(messageRepositoryProvider);
    state = const AsyncLoading();

    try {
      await repository.connecterConversation(conversationId);

      if (!ref.mounted) return false;

      state = const AsyncData(null);
      return true;
    } catch (e, stackTrace) {
      if (!ref.mounted) return false;

      state = AsyncError(e, stackTrace);
      return false;
    }
  }

  Future<bool> envoyer({
    required int conversationId,
    required String contenu,
  }) async {
    if (state.isLoading) return false;

    final texte = contenu.trim();

    if (texte.isEmpty) {
      state = AsyncError(
        'Le message ne peut pas être vide.',
        StackTrace.current,
      );
      return false;
    }

    final repository = ref.read(messageRepositoryProvider);
    state = const AsyncLoading();

    try {
      await repository.envoyerMessage(
        conversationId: conversationId,
        contenu: texte,
      );

      if (!ref.mounted) return false;

      state = const AsyncData(null);
      return true;
    } catch (e, stackTrace) {
      if (!ref.mounted) return false;

      state = AsyncError(e, stackTrace);
      return false;
    }
  }

  Future<bool> deconnecter() async {
    if (state.isLoading) return false;

    final repository = ref.read(messageRepositoryProvider);
    state = const AsyncLoading();

    try {
      repository.deconnecter();

      if (!ref.mounted) return false;

      state = const AsyncData(null);
      return true;
    } catch (e, stackTrace) {
      if (!ref.mounted) return false;

      state = AsyncError(e, stackTrace);
      return false;
    }
  }
}