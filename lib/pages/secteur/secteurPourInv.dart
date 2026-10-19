import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:startup_mobile/commun_widget/primary_button.dart';
import 'package:startup_mobile/controller/Auth/profil/profile_controller.dart';
import 'package:startup_mobile/cor/theme/app_theme.dart';
import 'package:startup_mobile/cor/utils/async_value_ui.dart';
import 'package:startup_mobile/models/Secteur.dart';
import 'package:startup_mobile/repository/profilInvestisseur/ProfileRepository.dart';

class secteurPourInv extends ConsumerStatefulWidget {
  const secteurPourInv({super.key});

  @override
  ConsumerState<secteurPourInv> createState() => _SectorsSelectionScreenState();
}

class _SectorsSelectionScreenState extends ConsumerState<secteurPourInv>
    with SingleTickerProviderStateMixin {
  static const double _sheetOverlap = 32;
  final Set<int> _selected = {};

  void _toggleSelection(int id) {
    setState(() {
      if (_selected.contains(id)) {
        _selected.remove(id);
      } else {
        _selected.add(id);
      }
    });
  }

  Future<void> _submit() async {
    if (_selected.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Choisissez au moins un secteur, ou passez cette étape.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      return;
    }

    final ids = _selected.toList()..sort();
    final success = await ref.read(profileControllerProvider.notifier).enregistrerSecteurs(ids);
    if (success && mounted) {
      context.go('/investor-dashboard');
    }
  }

  Future<void> _skip() async {
    final success = await ref.read(profileControllerProvider.notifier).passerEtape();
    if (success && mounted) {
      context.go('/investor-dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    final sectorsAsync = ref.watch(secteursProvider);
    final state = ref.watch(profileControllerProvider);

    ref.listen<AsyncValue>(profileControllerProvider, (_, nextState) {
      nextState.showErrorDialog(context);
    });

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: context.bgColor,
        body: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(context),
              Transform.translate(
                offset: const Offset(0, -_sheetOverlap),
                child: _buildSheet(context, sectorsAsync, state.isLoading),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final Color start = context.navbarColor;
    final Color end = Color.lerp(context.navbarColor, Colors.black, 0.30)!;

    return Container(
      width: double.infinity,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [start, end],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -60,
            right: -50,
            child: _decorCircle(190, 0.10),
          ),
          Positioned(
            top: 60,
            left: -70,
            child: _decorCircle(150, 0.07),
          ),
          SafeArea(
            bottom: false,
            child: SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, _sheetOverlap + 28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.interests_outlined,
                        size: 36,
                        color: context.navbarColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Vos centres d'intérêt",
                      textAlign: TextAlign.center,
                      style: context.headingTextStyle.copyWith(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Pour vous proposer les projets qui vous correspondent.',
                      textAlign: TextAlign.center,
                      style: context.normalTextStyle.copyWith(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _decorCircle(double size, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: opacity),
      ),
    );
  }

  Widget _buildSheet(
    BuildContext context,
    AsyncValue<List<Secteur>> sectorsAsync,
    bool isLoading,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: context.bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      child: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Dans quels secteurs voulez-vous investir ?',
              style: context.headingTextStyle.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Choisissez-en un ou plusieurs. Vous pourrez modifier ce choix plus tard.',
              style: context.normalTextStyle.copyWith(
                fontSize: 14,
                height: 1.45,
                color: context.textMuted,
              ),
            ),
            const SizedBox(height: 22),
            sectorsAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, _) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  'Erreur lors du chargement des secteurs : $error',
                  style: TextStyle(color: context.badgeRed),
                  textAlign: TextAlign.center,
                ),
              ),
              data: (sectors) => Wrap(
                spacing: 10,
                runSpacing: 12,
                children: sectors.map((sector) {
                  final isSelected = _selected.contains(sector.id);
                  return FilterChip(
                    label: Text(sector.nom),
                    selected: isSelected,
                    onSelected: (_) => _toggleSelection(sector.id),
                    selectedColor: context.primary,
                    checkmarkColor: Colors.white,
                    labelStyle: context.normalTextStyle.copyWith(
                      fontSize: 14,
                      color: isSelected ? Colors.white : context.textDark,
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 28),
            PrimaryButton(
              label: 'Continuer',
              isLoading: isLoading,
              onPressed: _submit,
            ),
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: isLoading ? null : _skip,
                child: Text(
                  "Passer pour l'instant",
                  style: context.normalTextStyle.copyWith(
                    fontSize: 14,
                    color: context.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
