
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:startup_mobile/cor/theme/app_theme.dart';
import 'package:startup_mobile/cor/utils/size_config.dart';
import 'package:startup_mobile/models/ProjetModel .dart';
import 'package:startup_mobile/pages/Investisseur/investor_project_card.dart';
import 'package:startup_mobile/pages/Investisseur/investor_project_detail_screen.dart';
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

  String? _selectedSector;
  String _query = '';

  final Set<int> _liked = {};

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

  @override
  Widget build(BuildContext context) {
    final projectsAsync = ref.watch(fluxProjetsProvider);
    final sectorsAsync = ref.watch(secteursProvider);

    return Scaffold(
      backgroundColor: context.bgColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            16.w(context),
            16.h(context),
            16.w(context),
            0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              SizedBox(height: 24.h(context)),
              Text(
                'Découvrez les projets',
                style: context.headingTextStyle.copyWith(
                  fontSize: 20.w(context),
                  fontWeight: FontWeight.bold,
                  color: context.textDark,
                ),
              ),
              SizedBox(height: 5.h(context)),
              Text(
                'Explorez les opportunités d’investissement.',
                style: context.normalTextStyle.copyWith(
                  fontSize: 14.w(context),
                  color: context.textMuted,
                ),
              ),
              SizedBox(height: 18.h(context)),
              TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() => _query = value);
                },
                style: TextStyle(
                  color: context.textDark,
                  fontSize: 14.w(context),
                ),
                decoration: InputDecoration(
                  hintText: 'Rechercher un projet...',
                  hintStyle: TextStyle(
                    color: context.textMuted,
                    fontSize: 14.w(context),
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
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 12.h(context),
                    horizontal: 14.w(context),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14.w(context)),
                    borderSide: BorderSide(color: context.borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14.w(context)),
                    borderSide: BorderSide(color: context.borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14.w(context)),
                    borderSide: BorderSide(
                      color: context.primary,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 22.h(context)),
              Text(
                'Secteurs',
                style: context.normalTextStyle.copyWith(
                  fontSize: 15.w(context),
                  fontWeight: FontWeight.bold,
                  color: context.textDark,
                ),
              ),
              SizedBox(height: 10.h(context)),
              SizedBox(
                height: 42.h(context),
                child: sectorsAsync.when(
                  loading: () => const Center(
                    child: LinearProgressIndicator(),
                  ),
                  error: (error, stackTrace) => Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Impossible de charger les secteurs.',
                      style: TextStyle(
                        color: context.textMuted,
                        fontSize: 12.w(context),
                      ),
                    ),
                  ),
                  data: (sectors) {
                    final names = sectors
                        .map((sector) => sector.nom)
                        .toSet()
                        .toList();

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
              SizedBox(height: 20.h(context)),
              Expanded(
                child: projectsAsync.when(
                  loading: () => Center(
                    child: CircularProgressIndicator(
                      color: context.primary,
                    ),
                  ),
                  error: (error, stackTrace) => Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.w(context)),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.cloud_off_outlined,
                            size: 45.w(context),
                            color: context.textMuted,
                          ),
                          SizedBox(height: 12.h(context)),
                          Text(
                            'Une erreur est survenue lors du chargement des projets.',
                            textAlign: TextAlign.center,
                            style: context.normalTextStyle.copyWith(
                              fontSize: 14.w(context),
                              color: context.textMuted,
                            ),
                          ),
                          SizedBox(height: 12.h(context)),
                          OutlinedButton.icon(
                            onPressed: () {
                              ref.invalidate(fluxProjetsProvider);
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Réessayer'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  data: (projects) {
                    final filteredProjects = _filterProjects(projects);

                    if (filteredProjects.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.search_off_rounded,
                              size: 42.w(context),
                              color: context.textMuted,
                            ),
                            SizedBox(height: 10.h(context)),
                            Text(
                              'Aucun projet trouvé.',
                              style: context.normalTextStyle.copyWith(
                                fontSize: 14.w(context),
                                color: context.textMuted,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.separated(
                      itemCount: filteredProjects.length,
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.only(
                        top: 4.h(context),
                        bottom: 24.h(context),
                      ),
                      separatorBuilder: (context, index) => SizedBox(
                        height: 12.h(context),
                      ),
                      itemBuilder: (context, index) {
                        final project = filteredProjects[index];
                        final isLiked = _liked.contains(project.id);

                        return InvestorProjectCard(
                          project: project,
                          isLiked: isLiked,
                          onLikePressed: () {
                            setState(() {
                              if (isLiked) {
                                _liked.remove(project.id);
                              } else {
                                _liked.add(project.id);
                              }
                            });
                          },
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

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10.w(context)),
                child: Image.asset(
                  'assets/images/onboarding/logo_startup.png',
                  width: 44.w(context),
                  height: 44.w(context),
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(width: 12.w(context)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Entrepreneur360',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.headingTextStyle.copyWith(
                        fontSize: 20.w(context),
                        fontWeight: FontWeight.bold,
                        color: context.textDark,
                      ),
                    ),
                    Text(
                      'Espace Investisseur',
                      style: context.normalTextStyle.copyWith(
                        fontSize: 13.w(context),
                        color: context.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Stack(
          children: [
            IconButton(
              icon: Icon(
                Icons.notifications_none_rounded,
                size: 26.w(context),
                color: context.textDark,
              ),
              onPressed: () {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Notifications : bientôt disponible',
                      ),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
              },
            ),
            Positioned(
              right: 8.w(context),
              top: 8.h(context),
              child: Container(
                width: 8.w(context),
                height: 8.w(context),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _sectorChip(
    BuildContext context,
    String label,
    String? value,
  ) {
    final isSelected = _selectedSector == value;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w(context)),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            setState(() => _selectedSector = value);
          }
        },
        selectedColor: context.primary,
        checkmarkColor: Colors.white,
        backgroundColor: context.background,
        side: BorderSide(
          color: isSelected ? context.primary : context.borderColor,
          width: 1,
        ),
        labelStyle: context.normalTextStyle.copyWith(
          color: isSelected ? Colors.white : context.textDark,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 13.w(context),
        ),
      ),
    );
  }
}
