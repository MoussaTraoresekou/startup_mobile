// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(conversationRepository)
final conversationRepositoryProvider = ConversationRepositoryProvider._();

final class ConversationRepositoryProvider
    extends
        $FunctionalProvider<
          ConversationRepository,
          ConversationRepository,
          ConversationRepository
        >
    with $Provider<ConversationRepository> {
  ConversationRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'conversationRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$conversationRepositoryHash();

  @$internal
  @override
  $ProviderElement<ConversationRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ConversationRepository create(Ref ref) {
    return conversationRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ConversationRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ConversationRepository>(value),
    );
  }
}

String _$conversationRepositoryHash() =>
    r'72b03d375a1b821c0e22a692aaee02394a8cf1aa';

/// Provider pour récupérer les conversations de l'investisseur.

@ProviderFor(mesConversations)
final mesConversationsProvider = MesConversationsProvider._();

/// Provider pour récupérer les conversations de l'investisseur.

final class MesConversationsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ConversationModel>>,
          List<ConversationModel>,
          FutureOr<List<ConversationModel>>
        >
    with
        $FutureModifier<List<ConversationModel>>,
        $FutureProvider<List<ConversationModel>> {
  /// Provider pour récupérer les conversations de l'investisseur.
  MesConversationsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mesConversationsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mesConversationsHash();

  @$internal
  @override
  $FutureProviderElement<List<ConversationModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ConversationModel>> create(Ref ref) {
    return mesConversations(ref);
  }
}

String _$mesConversationsHash() => r'ae6124bc7146edec3da1b6d069e36ca33084910c';
