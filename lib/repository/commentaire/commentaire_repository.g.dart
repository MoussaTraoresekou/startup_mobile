// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'commentaire_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(commentaireRepository)
final commentaireRepositoryProvider = CommentaireRepositoryProvider._();

final class CommentaireRepositoryProvider
    extends
        $FunctionalProvider<
          CommentaireRepository,
          CommentaireRepository,
          CommentaireRepository
        >
    with $Provider<CommentaireRepository> {
  CommentaireRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'commentaireRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$commentaireRepositoryHash();

  @$internal
  @override
  $ProviderElement<CommentaireRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CommentaireRepository create(Ref ref) {
    return commentaireRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CommentaireRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CommentaireRepository>(value),
    );
  }
}

String _$commentaireRepositoryHash() =>
    r'0ef5f369094c16c74ab1e6e74265ac8a677ec4ea';
