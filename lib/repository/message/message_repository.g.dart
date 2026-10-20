// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(messageRepository)
final messageRepositoryProvider = MessageRepositoryProvider._();

final class MessageRepositoryProvider
    extends
        $FunctionalProvider<
          MessageRepository,
          MessageRepository,
          MessageRepository
        >
    with $Provider<MessageRepository> {
  MessageRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'messageRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$messageRepositoryHash();

  @$internal
  @override
  $ProviderElement<MessageRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  MessageRepository create(Ref ref) {
    return messageRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MessageRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MessageRepository>(value),
    );
  }
}

String _$messageRepositoryHash() => r'd79cae7b977cd0e7f2cfdf160be94b7fb5c0ec3a';

/// Provider pour récupérer l'historique d'une conversation.

@ProviderFor(historiqueMessages)
final historiqueMessagesProvider = HistoriqueMessagesFamily._();

/// Provider pour récupérer l'historique d'une conversation.

final class HistoriqueMessagesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<MessageResponseModel>>,
          List<MessageResponseModel>,
          FutureOr<List<MessageResponseModel>>
        >
    with
        $FutureModifier<List<MessageResponseModel>>,
        $FutureProvider<List<MessageResponseModel>> {
  /// Provider pour récupérer l'historique d'une conversation.
  HistoriqueMessagesProvider._({
    required HistoriqueMessagesFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'historiqueMessagesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$historiqueMessagesHash();

  @override
  String toString() {
    return r'historiqueMessagesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<MessageResponseModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<MessageResponseModel>> create(Ref ref) {
    final argument = this.argument as int;
    return historiqueMessages(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is HistoriqueMessagesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$historiqueMessagesHash() =>
    r'ab8a287c3d5901f7e0f4e600572808b8da9014ef';

/// Provider pour récupérer l'historique d'une conversation.

final class HistoriqueMessagesFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<MessageResponseModel>>, int> {
  HistoriqueMessagesFamily._()
    : super(
        retry: null,
        name: r'historiqueMessagesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider pour récupérer l'historique d'une conversation.

  HistoriqueMessagesProvider call(int conversationId) =>
      HistoriqueMessagesProvider._(argument: conversationId, from: this);

  @override
  String toString() => r'historiqueMessagesProvider';
}
