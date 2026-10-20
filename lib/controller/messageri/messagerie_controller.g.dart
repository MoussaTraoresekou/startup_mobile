// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'messagerie_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(MessagerieController)
final messagerieControllerProvider = MessagerieControllerProvider._();

final class MessagerieControllerProvider
    extends $AsyncNotifierProvider<MessagerieController, void> {
  MessagerieControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'messagerieControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$messagerieControllerHash();

  @$internal
  @override
  MessagerieController create() => MessagerieController();
}

String _$messagerieControllerHash() =>
    r'd30cff028877017af31b1ccd4c8c27094758a9d1';

abstract class _$MessagerieController extends $AsyncNotifier<void> {
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
