import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:startup_mobile/cor/theme/app_theme.dart';

/// Première page vue par l'investisseur après sa connexion : le fil des
/// pitchs de startups, avec recherche et filtre par secteur.
class InvestorDashboardScreen extends StatefulWidget {
  const InvestorDashboardScreen({super.key});

  @override
  State<InvestorDashboardScreen> createState() =>
      _InvestorDashboardScreenState();
}

// ─────────────────────────────────────────────────────────────
// Données d'exemple (fictives) : à remplacer par l'appel à l'API
// Spring Boot qui renverra les vrais pitchs.
// ─────────────────────────────────────────────────────────────

class _Pitch {
  const _Pitch({
    required this.id,
    required this.name,
    required this.sector,
    required this.city,
    required this.summary,
    required this.amountFcfa,
    required this.likes,
    required this.comments,
  });

  final int id;
  final String name;
  final String sector;
  final String city;
  final String summary;
  final int amountFcfa;
  final int likes;
  final int comments;
}

const List<String> _sectors = [
  'Tous',
  'Agriculture',
  'Énergie solaire',
  'Fintech',
  'Commerce',
  'Santé',
  'Éducation',
  'Numérique',
];

const List<_Pitch> _pitches = [
  _Pitch(
    id: 1,
    name: 'AgroTransform',
    sector: 'Agriculture',
    city: 'Sikasso',
    summary:
        'Transformation de mangues en jus et fruits séchés, avec une première '
        'commande à l\'export vers l\'Afrique de l\'Ouest.',
    amountFcfa: 40000000,
    likes: 48,
    comments: 12,
  ),
  _Pitch(
    id: 2,
    name: 'SolaFoyer',
    sector: 'Énergie solaire',
    city: 'Bamako',
    summary:
        'Kits solaires pour les ménages hors réseau, payables par petites '
        'mensualités via mobile money.',
    amountFcfa: 25000000,
    likes: 73,
    comments: 21,
  ),
  _Pitch(
    id: 3,
    name: 'PayMarché',
    sector: 'Fintech',
    city: 'Bamako',
    summary:
        'Application de paiement et de suivi de ventes pensée pour les '
        'petits commerçants des marchés.',
    amountFcfa: 60000000,
    likes: 95,
    comments: 34,
  ),
  _Pitch(
    id: 4,
    name: 'Karité Nature',
    sector: 'Agriculture',
    city: 'Koutiala',
    summary:
        'Coopérative de 200 productrices : beurre de karité bio vendu en '
        'ligne et à des revendeurs en Europe.',
    amountFcfa: 15000000,
    likes: 39,
    comments: 8,
  ),
  _Pitch(
    id: 5,
    name: 'SantéProche',
    sector: 'Santé',
    city: 'Ségou',
    summary:
        'Consultations à distance et livraison de médicaments dans les zones '
        'rurales mal desservies.',
    amountFcfa: 35000000,
    likes: 61,
    comments: 17,
  ),
  _Pitch(
    id: 6,
    name: 'EduClasse',
    sector: 'Éducation',
    city: 'Bamako',
    summary:
        'Cours de soutien en ligne pour le collège et le lycée, en français '
        'et en bambara.',
    amountFcfa: 12000000,
    likes: 27,
    comments: 5,
  ),
];

IconData _sectorIcon(String sector) {
  switch (sector) {
    case 'Agriculture':
      return Icons.agriculture;
    case 'Énergie solaire':
      return Icons.wb_sunny_outlined;
    case 'Fintech':
      return Icons.account_balance_wallet_outlined;
    case 'Commerce':
      return Icons.storefront_outlined;
    case 'Santé':
      return Icons.health_and_safety_outlined;
    case 'Éducation':
      return Icons.school_outlined;
    case 'Numérique':
      return Icons.devices;
    default:
      return Icons.rocket_launch_outlined;
  }
}

/// 25000000 -> « 25 000 000 FCFA »
String _fcfa(int amount) {
  final digits = amount.toString();
  final buffer = StringBuffer();
  for (int i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(' ');
    buffer.write(digits[i]);
  }
  return '$buffer FCFA';
}

class _InvestorDashboardScreenState extends State<InvestorDashboardScreen> {
  final _searchController = TextEditingController();

  int _tab = 0;
  String _sector = 'Tous';
  String _query = '';
  final Set<int> _liked = {};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_Pitch> get _filtered {
    final q = _query.trim().toLowerCase();
    return _pitches.where((p) {
      final matchSector = _sector == 'Tous' || p.sector == _sector;
      final matchQuery = q.isEmpty ||
          p.name.toLowerCase().contains(q) ||
          p.sector.toLowerCase().contains(q) ||
          p.city.toLowerCase().contains(q);
      return matchSector && matchQuery;
    }).toList();
  }

  void _soon(String what) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('$what : bientôt disponible'),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: (isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark)
          .copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: context.bgColor,
        body: SafeArea(
          bottom: false,
          child: IndexedStack(
            index: _tab,
            children: [
              _buildDiscover(context),
              _buildPlaceholder(context, 'Favoris', Icons.favorite_border),
              _buildPlaceholder(
                context,
                'Messages',
                Icons.chat_bubble_outline,
              ),
              _buildPlaceholder(context, 'Profil', Icons.person_outline),
            ],
          ),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _tab,
          onDestinationSelected: (i) => setState(() => _tab = i),
          backgroundColor: context.background,
          indicatorColor: context.primarySoft,
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.explore_outlined),
              selectedIcon: Icon(Icons.explore, color: context.primary),
              label: 'Découvrir',
            ),
            NavigationDestination(
              icon: const Icon(Icons.favorite_border),
              selectedIcon: Icon(Icons.favorite, color: context.primary),
              label: 'Favoris',
            ),
            NavigationDestination(
              icon: const Icon(Icons.chat_bubble_outline),
              selectedIcon: Icon(Icons.chat_bubble, color: context.primary),
              label: 'Messages',
            ),
            NavigationDestination(
              icon: const Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person, color: context.primary),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context, String title, IconData icon) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: context.textMuted),
          const SizedBox(height: 12),
          Text(title, style: context.titleTextStyle),
          const SizedBox(height: 4),
          Text(
            'Bientôt disponible',
            style: context.normalTextStyle.copyWith(
              fontSize: 14,
              color: context.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────── DÉCOUVRIR ─────────────────────────

  Widget _buildDiscover(BuildContext context) {
    final pitches = _filtered;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  'assets/images/onboarding/logo_startup.png',
                  width: 46,
                  height: 46,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: context.primarySoft,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.rocket_launch_outlined,
                      color: context.primary,
                      size: 26,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Découvrir',
                      style: context.headingTextStyle.copyWith(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Des projets qui cherchent des investisseurs',
                      style: context.normalTextStyle.copyWith(
                        fontSize: 14,
                        color: context.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              _buildBellButton(context),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _query = value),
            style: context.normalTextStyle.copyWith(fontSize: 15),
            decoration: InputDecoration(
              hintText: 'Rechercher une startup, un secteur, une ville',
              hintStyle: context.normalTextStyle.copyWith(
                fontSize: 14,
                color: context.textMuted,
              ),
              prefixIcon: Icon(Icons.search, color: context.iconColor),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      icon: Icon(Icons.close, color: context.iconColor),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _query = '');
                      },
                    ),
              filled: true,
              fillColor: context.background,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: context.borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: context.borderSelected, width: 1.5),
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 38,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _sectors.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) =>
                _buildSectorChip(context, _sectors[index]),
          ),
        ),
        const SizedBox(height: 14),
        Expanded(
          child: pitches.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      'Aucun projet ne correspond à votre recherche.',
                      textAlign: TextAlign.center,
                      style: context.normalTextStyle.copyWith(
                        fontSize: 15,
                        color: context.textMuted,
                      ),
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  itemCount: pitches.length,
                  itemBuilder: (context, index) =>
                      _buildPitchCard(context, pitches[index]),
                ),
        ),
      ],
    );
  }

  Widget _buildBellButton(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          color: context.background,
          shape: CircleBorder(side: BorderSide(color: context.borderColor)),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () => _soon('Notifications'),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Icon(
                Icons.notifications_none,
                color: context.textDark,
                size: 24,
              ),
            ),
          ),
        ),
        Positioned(
          right: 10,
          top: 10,
          child: Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(
              color: context.badgeRed,
              shape: BoxShape.circle,
              border: Border.all(color: context.background, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectorChip(BuildContext context, String sector) {
    final bool selected = sector == _sector;
    return ChoiceChip(
      label: Text(sector),
      selected: selected,
      showCheckmark: false,
      onSelected: (_) => setState(() => _sector = sector),
      selectedColor: context.primary,
      backgroundColor: context.background,
      side: BorderSide(
        color: selected ? context.primary : context.borderColor,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      labelStyle: context.normalTextStyle.copyWith(
        fontSize: 13.5,
        fontWeight: FontWeight.w600,
        color: selected ? context.textInverse : context.textDark,
      ),
    );
  }

  Widget _buildPitchCard(BuildContext context, _Pitch pitch) {
    final bool liked = _liked.contains(pitch.id);
    final int likes = pitch.likes + (liked ? 1 : 0);
    final bool warmTint = pitch.id.isOdd;
    final Color tint = warmTint ? context.primarySoft : context.cardMenuYellow;
    final Color iconColor = warmTint ? context.primary : context.primaryOrange;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: context.background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Zone visuelle du pitch (à remplacer par la miniature de la vidéo)
          InkWell(
            onTap: () => _soon('Détail du pitch'),
            child: Container(
              height: 150,
              color: tint,
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      _sectorIcon(pitch.sector),
                      size: 64,
                      color: iconColor.withValues(alpha: 0.35),
                    ),
                  ),
                  Positioned(
                    left: 12,
                    top: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: context.background,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        pitch.sector,
                        style: context.normalTextStyle.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: iconColor,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 12,
                    bottom: 12,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(8, 6, 12, 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Voir le pitch',
                            style: context.normalTextStyle.copyWith(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        pitch.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.titleTextStyle.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: context.textMuted,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      pitch.city,
                      style: context.normalTextStyle.copyWith(
                        fontSize: 13,
                        color: context.textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  pitch.summary,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: context.normalTextStyle.copyWith(
                    fontSize: 14,
                    height: 1.45,
                    color: context.textMuted,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Text(
                      'Recherche ',
                      style: context.normalTextStyle.copyWith(
                        fontSize: 13.5,
                        color: context.textMuted,
                      ),
                    ),
                    Text(
                      _fcfa(pitch.amountFcfa),
                      style: context.normalTextStyle.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: context.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Divider(height: 1, color: context.borderColor),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _ActionButton(
                      icon: liked ? Icons.favorite : Icons.favorite_border,
                      color: liked ? context.badgeRed : context.iconColor,
                      label: '$likes',
                      onTap: () => setState(() {
                        if (liked) {
                          _liked.remove(pitch.id);
                        } else {
                          _liked.add(pitch.id);
                        }
                      }),
                    ),
                    const SizedBox(width: 4),
                    _ActionButton(
                      icon: Icons.mode_comment_outlined,
                      color: context.iconColor,
                      label: '${pitch.comments}',
                      onTap: () => _soon('Commentaires'),
                    ),
                    const Spacer(),
                    FilledButton.icon(
                      onPressed: () => _soon('Contacter ${pitch.name}'),
                      icon: const Icon(Icons.chat_bubble_outline, size: 18),
                      label: const Text('Contacter'),
                      style: FilledButton.styleFrom(
                        backgroundColor: context.primary,
                        foregroundColor: context.textInverse,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: context.normalTextStyle.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}