// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(projectRepository)
final projectRepositoryProvider = ProjectRepositoryProvider._();

final class ProjectRepositoryProvider
    extends
        $FunctionalProvider<
          ProjectRepository,
          ProjectRepository,
          ProjectRepository
        >
    with $Provider<ProjectRepository> {
  ProjectRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'projectRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$projectRepositoryHash();

  @$internal
  @override
  $ProviderElement<ProjectRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ProjectRepository create(Ref ref) {
    return projectRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProjectRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProjectRepository>(value),
    );
  }
}

String _$projectRepositoryHash() => r'01ad8c04e1a164259dd9c64ac8485a653de98825';

@ProviderFor(fluxProjets)
final fluxProjetsProvider = FluxProjetsProvider._();

final class FluxProjetsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ProjetModel>>,
          List<ProjetModel>,
          FutureOr<List<ProjetModel>>
        >
    with
        $FutureModifier<List<ProjetModel>>,
        $FutureProvider<List<ProjetModel>> {
  FluxProjetsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'fluxProjetsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$fluxProjetsHash();

  @$internal
  @override
  $FutureProviderElement<List<ProjetModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ProjetModel>> create(Ref ref) {
    return fluxProjets(ref);
  }
}

String _$fluxProjetsHash() => r'6d572feaaf37ea6baae9d57fe94e5bd73648878a';
