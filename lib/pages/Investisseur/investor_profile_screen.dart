
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:startup_mobile/cor/theme/app_theme.dart';
import 'package:startup_mobile/cor/utils/size_config.dart';
import 'package:startup_mobile/cor/storage/token_storage.dart';
import 'package:startup_mobile/models/Secteur.dart';
import 'package:startup_mobile/repository/auth_repository.dart';
import 'package:startup_mobile/repository/profilInvestisseur/ProfileRepository.dart';

class InvestorProfileScreen extends ConsumerStatefulWidget {
  const InvestorProfileScreen({super.key});

  @override
  ConsumerState<InvestorProfileScreen> createState() =>
      _InvestorProfileScreenState();
}

class _InvestorProfileScreenState
    extends ConsumerState<InvestorProfileScreen> {
  late Future<Map<String, String?>> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = ref.read(tokenStorageProvider).readUserProfile();
  }

  String _initiales(String? prenom, String? nom) {
    final p = (prenom ?? '').trim();
    final n = (nom ?? '').trim();

    if (p.isEmpty && n.isEmpty) return 'I';

    return '${p.isNotEmpty ? p[0] : ''}'
            '${n.isNotEmpty ? n[0] : ''}'
        .toUpperCase();
  }

  Future<void> _deconnecter() async {
    final confirmer = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text(
          'Voulez-vous vraiment vous déconnecter de votre compte ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );

    if (confirmer != true || !mounted) return;

    try {
      await ref.read(authRepositoryProvider).logout();

      if (!mounted) return;
      context.go('/login');
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible de vous déconnecter. Réessayez.'),
        ),
      );
    }
  }

  void _ouvrirApparence() {
    Navigator.of(context).pop();

    showDialog<void>(
      context: context,
      builder: (dialogContext) => Consumer(
        builder: (context, dialogRef, child) {
          final mode = dialogRef.watch(themeModeProvider);

          return AlertDialog(
            title: const Text('Apparence'),
            content: RadioGroup<ThemeMode>(
              groupValue: mode,
              onChanged: (value) {
                if (value != null) {
                  dialogRef
                      .read(themeModeProvider.notifier)
                      .state = value;
                }
              },
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile<ThemeMode>(
                    value: ThemeMode.light,
                    title: Text('Jour'),
                    secondary: Icon(Icons.light_mode_outlined),
                  ),
                  RadioListTile<ThemeMode>(
                    value: ThemeMode.dark,
                    title: Text('Nuit'),
                    secondary: Icon(Icons.dark_mode_outlined),
                  ),
                  RadioListTile<ThemeMode>(
                    value: ThemeMode.system,
                    title: Text('Automatique'),
                    secondary: Icon(Icons.settings_brightness_outlined),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Fermer'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgColor,
      drawer: _construireMenuLateral(context),
      appBar: AppBar(
        backgroundColor: context.background,
        foregroundColor: context.textDark,
        elevation: 0,
        title: Text(
          'Mon profil',
          style: context.titleTextStyle,
        ),
        centerTitle: false,
      ),
      body: FutureBuilder<Map<String, String?>>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _messageCentral(
              icon: Icons.error_outline,
              message: 'Impossible de charger votre profil.',
              actionLabel: 'Réessayer',
              onAction: () {
                setState(() {
                  _profileFuture =
                      ref.read(tokenStorageProvider).readUserProfile();
                });
              },
            );
          }

          final profil = snapshot.data ?? {};
          final nom = profil['nom'];
          final prenom = profil['prenom'];
          final email = profil['email'];
          final role = profil['role'];

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(secteursChoisisProvider);
              setState(() {
                _profileFuture =
                    ref.read(tokenStorageProvider).readUserProfile();
              });
              await _profileFuture;
            },
            child: ListView(
              padding: EdgeInsets.all(20.w(context)),
              children: [
                _construireCarteProfil(
                  nom: nom,
                  prenom: prenom,
                  email: email,
                  role: role,
                ),
                SizedBox(height: 28.h(context)),
                _titreSection(
                  'Mes informations',
                  Icons.person_outline_rounded,
                ),
                SizedBox(height: 12.h(context)),
                _construireInformations(
                  nom: nom,
                  prenom: prenom,
                  email: email,
                  role: role,
                ),
                SizedBox(height: 28.h(context)),
                _titreSection(
                  'Mes secteurs d’investissement',
                  Icons.trending_up_rounded,
                ),
                SizedBox(height: 8.h(context)),
                Text(
                  'Les domaines qui vous intéressent.',
                  style: context.normalTextStyle.copyWith(
                    fontSize: 13.sp(context),
                    color: context.textMuted,
                  ),
                ),
                SizedBox(height: 14.h(context)),
                _construireSecteurs(),
                SizedBox(height: 24.h(context)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _construireMenuLateral(BuildContext context) {
    return Drawer(
      backgroundColor: context.background,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.all(20.w(context)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.account_circle_outlined,
                    size: 42,
                    color: context.primary,
                  ),
                  SizedBox(height: 10.h(context)),
                  Text(
                    'Mon espace',
                    style: context.headingTextStyle,
                  ),
                  SizedBox(height: 4.h(context)),
                  Text(
                    'Entrepreneur360',
                    style: context.normalTextStyle.copyWith(
                      fontSize: 13.sp(context),
                      color: context.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: context.borderColor),
            ListTile(
              leading: Icon(
                Icons.palette_outlined,
                color: context.primary,
              ),
              title: const Text('Apparence'),
              subtitle: const Text('Jour, nuit ou automatique'),
              onTap: _ouvrirApparence,
            ),
            const Spacer(),
            Divider(color: context.borderColor),
            ListTile(
              leading: const Icon(
                Icons.logout_rounded,
                color: Colors.red,
              ),
              title: const Text('Déconnexion'),
              textColor: Colors.red,
              onTap: () {
                Navigator.of(context).pop();
                _deconnecter();
              },
            ),
            SizedBox(height: 12.h(context)),
          ],
        ),
      ),
    );
  }

  Widget _construireCarteProfil({
    required String? nom,
    required String? prenom,
    required String? email,
    required String? role,
  }) {
    final nomComplet =
        '${prenom ?? ''} ${nom ?? ''}'.trim();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(22.w(context)),
      decoration: BoxDecoration(
        color: context.primarySoft,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 42,
            backgroundColor: context.primary,
            child: Text(
              _initiales(prenom, nom),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 14.h(context)),
          Text(
            nomComplet.isEmpty ? 'Investisseur' : nomComplet,
            textAlign: TextAlign.center,
            style: context.headingTextStyle.copyWith(
              fontSize: 21.sp(context),
            ),
          ),
          SizedBox(height: 6.h(context)),
          Text(
            email?.isNotEmpty == true
                ? email!
                : 'Adresse e-mail non renseignée',
            textAlign: TextAlign.center,
            style: context.normalTextStyle.copyWith(
              color: context.textMuted,
              fontSize: 13.sp(context),
            ),
          ),
          SizedBox(height: 12.h(context)),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: context.background,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              (role?.isNotEmpty == true ? role! : 'INVESTISSEUR')
                  .replaceAll('_', ' '),
              style: TextStyle(
                color: context.primary,
                fontSize: 11.sp(context),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _titreSection(String titre, IconData icone) {
    return Row(
      children: [
        Icon(icone, color: context.primary, size: 22),
        SizedBox(width: 9.w(context)),
        Expanded(
          child: Text(
            titre,
            style: context.titleTextStyle,
          ),
        ),
      ],
    );
  }

  Widget _construireInformations({
    required String? nom,
    required String? prenom,
    required String? email,
    required String? role,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w(context)),
      decoration: BoxDecoration(
        color: context.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        children: [
          _ligneInformation(
            icone: Icons.badge_outlined,
            libelle: 'Prénom',
            valeur: prenom,
          ),
          Divider(color: context.borderColor, height: 1),
          _ligneInformation(
            icone: Icons.person_outline,
            libelle: 'Nom',
            valeur: nom,
          ),
          Divider(color: context.borderColor, height: 1),
          _ligneInformation(
            icone: Icons.email_outlined,
            libelle: 'E-mail',
            valeur: email,
          ),
          Divider(color: context.borderColor, height: 1),
          _ligneInformation(
            icone: Icons.work_outline,
            libelle: 'Type de compte',
            valeur: role?.replaceAll('_', ' '),
          ),
        ],
      ),
    );
  }

  Widget _ligneInformation({
    required IconData icone,
    required String libelle,
    required String? valeur,
  }) {
    final valeurAffichee =
        valeur == null || valeur.trim().isEmpty
            ? 'Non renseigné'
            : valeur;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 14.h(context)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icone, color: context.iconColor, size: 21),
          SizedBox(width: 12.w(context)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  libelle,
                  style: context.normalTextStyle.copyWith(
                    color: context.textMuted,
                    fontSize: 12.sp(context),
                  ),
                ),
                SizedBox(height: 4.h(context)),
                Text(
                  valeurAffichee,
                  style: context.normalTextStyle.copyWith(
                    fontSize: 14.sp(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _construireSecteurs() {
    final secteursAsync = ref.watch(secteursChoisisProvider);

    return secteursAsync.when(
      loading: () => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: context.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.borderColor),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stackTrace) => _messageCentral(
        icon: Icons.cloud_off_outlined,
        message: 'Impossible de charger vos secteurs pour le moment.',
        actionLabel: 'Réessayer',
        onAction: () => ref.invalidate(secteursChoisisProvider),
      ),
      data: (List<Secteur> secteurs) {
        if (secteurs.isEmpty) {
          return Container(
            width: double.infinity,
            padding: EdgeInsets.all(20.w(context)),
            decoration: BoxDecoration(
              color: context.background,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: context.borderColor),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.explore_outlined,
                  size: 34,
                  color: context.primary,
                ),
                SizedBox(height: 10.h(context)),
                Text(
                  'Aucun secteur sélectionné',
                  textAlign: TextAlign.center,
                  style: context.titleTextStyle.copyWith(
                    fontSize: 15.sp(context),
                  ),
                ),
                SizedBox(height: 6.h(context)),
                Text(
                  'Vous pouvez toujours explorer tous les projets, '
                  'quel que soit leur secteur.',
                  textAlign: TextAlign.center,
                  style: context.normalTextStyle.copyWith(
                    fontSize: 13.sp(context),
                    color: context.textMuted,
                  ),
                ),
              ],
            ),
          );
        }

        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: secteurs.map((secteur) {
            return Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: context.primarySoft,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: context.borderColor),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 17,
                    color: context.primary,
                  ),
                  const SizedBox(width: 7),
                  Text(
                    secteur.nom,
                    style: context.normalTextStyle.copyWith(
                      fontSize: 13.sp(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _messageCentral({
    required IconData icon,
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w(context)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 42, color: context.textMuted),
            SizedBox(height: 12.h(context)),
            Text(
              message,
              textAlign: TextAlign.center,
              style: context.normalTextStyle.copyWith(
                color: context.textMuted,
                fontSize: 14.sp(context),
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              SizedBox(height: 12.h(context)),
              TextButton(
                onPressed: onAction,
                child: Text(actionLabel),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
