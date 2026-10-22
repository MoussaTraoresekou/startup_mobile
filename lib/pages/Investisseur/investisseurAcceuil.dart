
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:startup_mobile/cor/theme/app_theme.dart';
import 'package:startup_mobile/cor/utils/size_config.dart';
import 'package:startup_mobile/cor/storage/token_storage.dart';
import 'package:startup_mobile/models/ProjetModel .dart';
import 'package:startup_mobile/pages/Investisseur/investor_project_card.dart';
import 'package:startup_mobile/pages/Investisseur/investor_project_detail_screen.dart';
import 'package:startup_mobile/repository/like/like_repository.dart';
import 'package:startup_mobile/repository/profilInvestisseur/ProfileRepository.dart';
import 'package:startup_mobile/repository/project_repository.dart';

class InvestorDashboardScreen extends ConsumerStatefulWidget {
  const InvestorDashboardScreen({super.key});

  @override
  ConsumerState<InvestorDashboardScreen> createState() =>
      _InvestorDashboardScreenState();
}

class _InvestorDashboardScreenState
    extends ConsumerState<InvestorDashboardScreen> {
  final TextEditingController _searchController = TextEditingController();

  late Future<Map<String, String?>> _profileFuture;

  String? _selectedSector;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _profileFuture = ref.read(tokenStorageProvider).readUserProfile();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ProjetModel> _filterProjects(List<ProjetModel> projects) {
    final query = _query.trim().toLowerCase();

    return projects.where((project) {
      final matchSector = _selectedSector == null ||
          project.secteur.toLowerCase() == _selectedSector!.toLowerCase();

      final matchQuery = query.isEmpty ||
          project.titre.toLowerCase().contains(query) ||
          project.description.toLowerCase().contains(query) ||
          project.secteur.toLowerCase().contains(query) ||
          project.porteurNomComplet.toLowerCase().contains(query);

      return matchSector && matchQuery;
    }).toList();
  }

  Future<void> _toggleLike(int id) async {
    try {
      await ref.read(likesProvider.notifier).basculer(id);
    } catch (_) {
      if (!mounted) return;

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

  @override
  Widget build(BuildContext context) {
    final projectsAsync = ref.watch(fluxProjetsProvider);
    final sectorsAsync = ref.watch(secteursProvider);
    final likes = ref.watch(likesProvider).value ?? <int>{};

    return Scaffold(
      backgroundColor: context.bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 20),
              Text(
                'Découvrez les projets',
                style: context.headingTextStyle.copyWith(
                  fontSize: 20.sp(context),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Explorez les opportunités d’investissement.',
                style: context.normalTextStyle.copyWith(
                  fontSize: 14.sp(context),
                  color: context.textMuted,
                ),
              ),
              const SizedBox(height: 16),
              _buildSearch(context),
              const SizedBox(height: 16),
              SizedBox(
                height: 38,
                child: sectorsAsync.when(
                  loading: () => const Align(
                    alignment: Alignment.centerLeft,
                    child: LinearProgressIndicator(),
                  ),
                  error: (error, stackTrace) => Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Impossible de charger les secteurs.',
                      style: context.normalTextStyle.copyWith(
                        fontSize: 12.sp(context),
                        color: context.textMuted,
                      ),
                    ),
                  ),
                  data: (sectors) {
                    final names =
                        sectors.map((sector) => sector.nom).toSet().toList();

                    return ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _sectorChip(context, 'Tous', null),
                        ...names.map(
                          (name) => _sectorChip(context, name, name),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: projectsAsync.when(
                  loading: () => Center(
                    child: CircularProgressIndicator(
                      color: context.primary,
                    ),
                  ),
                  error: (error, stackTrace) => _Message(
                    icon: Icons.cloud_off_outlined,
                    text:
                        'Une erreur est survenue lors du chargement des projets.',
                    actionLabel: 'Réessayer',
                    onAction: () => ref.invalidate(fluxProjetsProvider),
                  ),
                  data: (projects) {
                    final filtered = _filterProjects(projects);

                    if (filtered.isEmpty) {
                      return const _Message(
                        icon: Icons.search_off_rounded,
                        text: 'Aucun projet trouvé.',
                      );
                    }

                    return RefreshIndicator(
                      color: context.primary,
                      onRefresh: () async {
                        ref.invalidate(fluxProjetsProvider);

                        try {
                          await ref.read(fluxProjetsProvider.future);
                        } catch (_) {}
                      },
                      child: ListView.separated(
                        itemCount: filtered.length,
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(bottom: 24),
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final project = filtered[index];

                          return InvestorProjectCard(
                            project: project,
                            isLiked: likes.contains(project.id),
                            onLikePressed: () => _toggleLike(project.id),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      InvestorProjectDetailScreen(
                                    projet: project,
                                  ),
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
            ],
          ),
        ),
      ),
    );
  }

  // En-tête : logo, nom de l'utilisateur connecté et notifications.
  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Image.asset(
          'assets/images/onboarding/logo_startup.png',
          width: 70,
          height: 70,
          fit: BoxFit.contain,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: FutureBuilder<Map<String, String?>>(
            future: _profileFuture,
            builder: (context, snapshot) {
              final profil = snapshot.data ?? {};

              final prenom = (profil['prenom'] ?? '').trim();
              final nom = (profil['nom'] ?? '').trim();

              final nomComplet = '$prenom $nom'.trim();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    nomComplet.isNotEmpty
                        ? nomComplet
                        : snapshot.connectionState == ConnectionState.waiting
                            ? 'Chargement...'
                            : 'Investisseur',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.headingTextStyle.copyWith(
                      fontSize: 16.sp(context),
                    ),
                  ),
                  Text(
                    'Espace Investisseur',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.normalTextStyle.copyWith(
                      fontSize: 12.sp(context),
                      color: context.textMuted,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        Stack(
          children: [
            IconButton(
              icon: Icon(
                Icons.notifications_none_rounded,
                size: 26,
                color: context.textDark,
              ),
              onPressed: () {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    const SnackBar(
                      content: Text('Notifications : bientôt disponible'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
              },
            ),
            Positioned(
              right: 11,
              top: 11,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: context.badgeRed,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearch(BuildContext context) {
    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: color, width: width),
        );

    return TextField(
      controller: _searchController,
      onChanged: (value) => setState(() => _query = value),
      style: context.normalTextStyle.copyWith(
        fontSize: 15.sp(context),
      ),
      decoration: InputDecoration(
        hintText: 'Rechercher un projet...',
        hintStyle: context.normalTextStyle.copyWith(
          fontSize: 14.sp(context),
          color: context.textMuted,
        ),
        prefixIcon: Icon(
          Icons.search,
          color: context.textMuted,
        ),
        suffixIcon: _query.isNotEmpty
            ? IconButton(
                onPressed: () {
                  _searchController.clear();
                  setState(() => _query = '');
                },
                icon: Icon(
                  Icons.close,
                  color: context.textMuted,
                ),
              )
            : null,
        filled: true,
        fillColor: context.background,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 16,
        ),
        border: border(context.borderColor),
        enabledBorder: border(context.borderColor),
        focusedBorder: border(context.borderSelected, 1.5),
      ),
    );
  }

  Widget _sectorChip(
    BuildContext context,
    String label,
    String? value,
  ) {
    final isSelected = _selectedSector == value;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        showCheckmark: false,
        onSelected: (_) => setState(() => _selectedSector = value),
        shape: const StadiumBorder(),
        selectedColor: context.primary,
        backgroundColor: context.background,
        side: BorderSide(
          color: isSelected ? context.primary : context.borderColor,
        ),
        labelStyle: context.normalTextStyle.copyWith(
          fontSize: 13.sp(context),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? context.textInverse : context.textDark,
        ),
      ),
    );
  }
}

// Widget commun pour afficher les erreurs et les listes vides.
class _Message extends StatelessWidget {
  const _Message({
    required this.icon,
    required this.text,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String text;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 44,
              color: context.textMuted,
            ),
            const SizedBox(height: 12),
            Text(
              text,
              textAlign: TextAlign.center,
              style: context.normalTextStyle.copyWith(
                fontSize: 14.sp(context),
                color: context.textMuted,
              ),
            ),
            if (actionLabel != null) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.refresh),
                label: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
