// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ConversationController)
final conversationControllerProvider = ConversationControllerProvider._();

final class ConversationControllerProvider
    extends $AsyncNotifierProvider<ConversationController, void> {
  ConversationControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'conversationControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$conversationControllerHash();

  @$internal
  @override
  ConversationController create() => ConversationController();
}

String _$conversationControllerHash() =>
    r'1d02bad20da099f755d33225c58a96a50cf6f541';

abstract class _$ConversationController extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
