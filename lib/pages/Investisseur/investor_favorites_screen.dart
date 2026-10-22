import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:startup_mobile/cor/theme/app_theme.dart';
import 'package:startup_mobile/cor/utils/size_config.dart';
import 'package:startup_mobile/models/ProjetModel .dart';
import 'package:startup_mobile/pages/Investisseur/investor_project_card.dart';
import 'package:startup_mobile/pages/Investisseur/investor_project_detail_screen.dart';
import 'package:startup_mobile/repository/like/like_repository.dart';
import 'package:startup_mobile/repository/project_repository.dart';

/// Projets que l'investisseur a aimés.
/// On croise le flux de projets avec la liste des likes : aucune route
/// supplémentaire n'est nécessaire côté backend.
class InvestorFavoritesScreen extends ConsumerWidget {
  const InvestorFavoritesScreen({super.key});

  Future<void> _basculerLike(
    BuildContext context,
    WidgetRef ref,
    int projetId,
  ) async {
    try {
      await ref.read(likesProvider.notifier).basculer(projetId);
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Impossible de mettre à jour le like.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
    }
  }

  Future<void> _actualiser(WidgetRef ref) async {
    ref.invalidate(fluxProjetsProvider);
    ref.invalidate(likesProvider);
    try {
      await ref.read(fluxProjetsProvider.future);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(fluxProjetsProvider);
    final likesAsync = ref.watch(likesProvider);
    final likes = likesAsync.value ?? <int>{};

    return Scaffold(
      backgroundColor: context.bgColor,
      appBar: AppBar(
        backgroundColor: context.background,
        foregroundColor: context.textDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        shape: Border(bottom: BorderSide(color: context.borderColor)),
        title: Text('Mes favoris', style: context.headingTextStyle),
      ),
      body: SafeArea(
        child: projectsAsync.when(
          loading: () => Center(
            child: CircularProgressIndicator(color: context.primary),
          ),
          error: (error, stackTrace) => _Etat(
            icon: Icons.cloud_off_outlined,
            titre: 'Chargement impossible',
            message: 'Vérifiez votre connexion puis réessayez.',
            actionLabel: 'Réessayer',
            onAction: () => ref.invalidate(fluxProjetsProvider),
          ),
          data: (projects) {
            if (likesAsync.isLoading && !likesAsync.hasValue) {
              return Center(
                child: CircularProgressIndicator(color: context.primary),
              );
            }

            final favoris =
                projects.where((p) => likes.contains(p.id)).toList();

            if (favoris.isEmpty) {
              return const _Etat(
                icon: Icons.favorite_border_rounded,
                titre: 'Aucun favori',
                message:
                    'Appuyez sur le cœur d’un projet pour le retrouver ici.',
              );
            }

            return RefreshIndicator(
              color: context.primary,
              onRefresh: () => _actualiser(ref),
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                itemCount: favoris.length + 1,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Text(
                      favoris.length == 1
                          ? '1 projet aimé'
                          : '${favoris.length} projets aimés',
                      style: context.normalTextStyle.copyWith(
                        fontSize: 13.sp(context),
                        color: context.textMuted,
                      ),
                    );
                  }

                  final ProjetModel project = favoris[index - 1];

                  return InvestorProjectCard(
                    project: project,
                    isLiked: true,
                    onLikePressed: () =>
                        _basculerLike(context, ref, project.id),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              InvestorProjectDetailScreen(projet: project),
                        ),
                      );
                    },
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

// Message simple pour les états « vide » et « erreur ».
class _Etat extends StatelessWidget {
  const _Etat({
    required this.icon,
    required this.titre,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String titre;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 44, color: context.textMuted),
            const SizedBox(height: 14),
            Text(
              titre,
              textAlign: TextAlign.center,
              style: context.titleTextStyle.copyWith(
                fontSize: 16.sp(context),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: context.normalTextStyle.copyWith(
                fontSize: 13.sp(context),
                height: 1.4,
                color: context.textMuted,
              ),
            ),
            if (actionLabel != null) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}