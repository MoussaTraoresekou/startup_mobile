// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'like_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(likeRepository)
final likeRepositoryProvider = LikeRepositoryProvider._();

final class LikeRepositoryProvider
    extends $FunctionalProvider<LikeRepository, LikeRepository, LikeRepository>
    with $Provider<LikeRepository> {
  LikeRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'likeRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$likeRepositoryHash();

  @$internal
  @override
  $ProviderElement<LikeRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LikeRepository create(Ref ref) {
    return likeRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LikeRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LikeRepository>(value),
    );
  }
}

String _$likeRepositoryHash() => r'75233f9ae3c68442a829815bb9429cba9cdea7ac';

/// État partagé des projets aimés par l'investisseur.

@ProviderFor(Likes)
final likesProvider = LikesProvider._();

/// État partagé des projets aimés par l'investisseur.
final class LikesProvider extends $AsyncNotifierProvider<Likes, Set<int>> {
  /// État partagé des projets aimés par l'investisseur.
  LikesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'likesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$likesHash();

  @$internal
  @override
  Likes create() => Likes();
}

String _$likesHash() => r'07a8d76cd997a42a4ad8d24cb27238a25e7ffd4b';

/// État partagé des projets aimés par l'investisseur.

abstract class _$Likes extends $AsyncNotifier<Set<int>> {
  FutureOr<Set<int>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<Set<int>>, Set<int>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Set<int>>, Set<int>>,
              AsyncValue<Set<int>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Source de vérité commune pour les compteurs de likes.

@ProviderFor(LikeCounts)
final likeCountsProvider = LikeCountsProvider._();

/// Source de vérité commune pour les compteurs de likes.
final class LikeCountsProvider
    extends $NotifierProvider<LikeCounts, Map<int, int>> {
  /// Source de vérité commune pour les compteurs de likes.
  LikeCountsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'likeCountsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$likeCountsHash();

  @$internal
  @override
  LikeCounts create() => LikeCounts();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<int, int> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<int, int>>(value),
    );
  }
}

String _$likeCountsHash() => r'c1064dc9c68bfc584368a46e784a7f38df22fae0';

/// Source de vérité commune pour les compteurs de likes.

abstract class _$LikeCounts extends $Notifier<Map<int, int>> {
  Map<int, int> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Map<int, int>, Map<int, int>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Map<int, int>, Map<int, int>>,
              Map<int, int>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
