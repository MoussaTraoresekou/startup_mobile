import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:startup_mobile/cor/theme/app_theme.dart';
import 'package:startup_mobile/cor/utils/size_config.dart';
import 'package:startup_mobile/models/ConversationModel.dart';
import 'package:startup_mobile/repository/conversation/conversation_repository.dart';

class ConversationListScreen extends ConsumerStatefulWidget {
  const ConversationListScreen({super.key});

  @override
  ConsumerState<ConversationListScreen> createState() =>
      _ConversationListScreenState();
}

class _ConversationListScreenState
    extends ConsumerState<ConversationListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Filtre par nom ou titre de projet, puis trie du plus récent au plus ancien.
  List<ConversationModel> _filtrerEtTrier(List<ConversationModel> source) {
    final query = _query.trim().toLowerCase();

    final liste = source.where((c) {
      return query.isEmpty ||
          c.porteurNom.toLowerCase().contains(query) ||
          c.projetTitre.toLowerCase().contains(query);
    }).toList();

    liste.sort((a, b) {
      final dateA = a.dateDernierMessage ?? a.dateCreation;
      final dateB = b.dateDernierMessage ?? b.dateCreation;

      if (dateA == null && dateB == null) return 0;
      if (dateA == null) return 1;
      if (dateB == null) return -1;

      return dateB.compareTo(dateA);
    });

    return liste;
  }

  Future<void> _actualiser() async {
    ref.invalidate(mesConversationsProvider);
    try {
      await ref.read(mesConversationsProvider.future);
    } catch (_) {
      // L'erreur est déjà affichée par l'état du provider.
    }
  }

  @override
  Widget build(BuildContext context) {
    final conversationsAsync = ref.watch(mesConversationsProvider);

    return Scaffold(
      backgroundColor: context.background,
      appBar: AppBar(
        backgroundColor: context.background,
        foregroundColor: context.textDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        shape: Border(bottom: BorderSide(color: context.borderColor)),
        title: Text('Messages', style: context.headingTextStyle),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: _buildSearch(context),
            ),
            Expanded(
              child: conversationsAsync.when(
                loading: () => Center(
                  child: CircularProgressIndicator(color: context.primary),
                ),
                error: (error, stackTrace) => _Etat(
                  icon: Icons.cloud_off_outlined,
                  titre: 'Impossible de charger les conversations',
                  message: error.toString().replaceFirst('Exception: ', ''),
                  actionLabel: 'Réessayer',
                  onAction: () => ref.invalidate(mesConversationsProvider),
                ),
                data: (conversations) {
                  if (conversations.isEmpty) {
                    return const _Etat(
                      icon: Icons.forum_outlined,
                      titre: 'Aucune conversation',
                      message:
                          'Lorsque vous contacterez un porteur de projet, vos échanges apparaîtront ici.',
                    );
                  }

                  final liste = _filtrerEtTrier(conversations);

                  if (liste.isEmpty) {
                    return const _Etat(
                      icon: Icons.search_off_rounded,
                      titre: 'Aucun résultat',
                      message: 'Aucune conversation ne correspond à votre recherche.',
                    );
                  }

                  return RefreshIndicator(
                    color: context.primary,
                    onRefresh: _actualiser,
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: liste.length,
                      separatorBuilder: (_, __) => Divider(
                        height: 1,
                        indent: 76,
                        color: context.borderColor,
                      ),
                      itemBuilder: (context, index) {
                        final conversation = liste[index];

                        return _LigneConversation(
                          conversation: conversation,
                          onTap: () => context.push(
                            '/conversation',
                            extra: conversation,
                          ),
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
      style: context.normalTextStyle.copyWith(fontSize: 15.sp(context)),
      decoration: InputDecoration(
        hintText: 'Rechercher une conversation...',
        hintStyle: context.normalTextStyle.copyWith(
          fontSize: 14.sp(context),
          color: context.textMuted,
        ),
        prefixIcon: Icon(Icons.search, color: context.textMuted),
        suffixIcon: _query.isNotEmpty
            ? IconButton(
                onPressed: () {
                  _searchController.clear();
                  setState(() => _query = '');
                },
                icon: Icon(Icons.close, color: context.textMuted),
              )
            : null,
        filled: true,
        fillColor: context.bgColor,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        border: border(context.borderColor),
        enabledBorder: border(context.borderColor),
        focusedBorder: border(context.borderSelected, 1.5),
      ),
    );
  }
}

// =============================================================================
// LIGNE DE CONVERSATION
// =============================================================================

class _LigneConversation extends StatelessWidget {
  const _LigneConversation({
    required this.conversation,
    required this.onTap,
  });

  final ConversationModel conversation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final nom = conversation.porteurNom.trim().isNotEmpty
        ? conversation.porteurNom.trim()
        : 'Porteur de projet';

    final titre = conversation.projetTitre.trim().isNotEmpty
        ? conversation.projetTitre.trim()
        : 'Projet sans titre';

    final dernierMessage = conversation.dernierMessage.trim();
    final date = conversation.dateDernierMessage ?? conversation.dateCreation;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: context.primarySoft,
              child: Text(
                _initiales(nom),
                style: context.normalTextStyle.copyWith(
                  fontSize: 15.sp(context),
                  fontWeight: FontWeight.bold,
                  color: context.primary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          nom,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.titleTextStyle.copyWith(
                            fontSize: 16.sp(context),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (date != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          _formaterDate(date),
                          style: context.normalTextStyle.copyWith(
                            fontSize: 12.sp(context),
                            color: context.textMuted,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    titre,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.normalTextStyle.copyWith(
                      fontSize: 12.sp(context),
                      fontWeight: FontWeight.w600,
                      color: context.primary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    dernierMessage.isNotEmpty
                        ? dernierMessage
                        : 'Aucun message pour le moment',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.normalTextStyle.copyWith(
                      fontSize: 14.sp(context),
                      color: context.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _initiales(String nom) {
    final parties = nom
        .trim()
        .split(RegExp(r'\s+'))
        .where((partie) => partie.isNotEmpty)
        .toList();

    if (parties.isEmpty) return 'P';
    if (parties.length == 1) return parties.first[0].toUpperCase();

    return '${parties.first[0]}${parties.last[0]}'.toUpperCase();
  }

  String _formaterDate(DateTime date) {
    final maintenant = DateTime.now();
    final aujourdHui = DateTime(maintenant.year, maintenant.month, maintenant.day);
    final jourMessage = DateTime(date.year, date.month, date.day);

    if (jourMessage == aujourdHui) {
      final heure = date.hour.toString().padLeft(2, '0');
      final minute = date.minute.toString().padLeft(2, '0');
      return '$heure:$minute';
    }

    if (aujourdHui.difference(jourMessage).inDays == 1) return 'Hier';

    final jour = date.day.toString().padLeft(2, '0');
    final mois = date.month.toString().padLeft(2, '0');

    return date.year == maintenant.year ? '$jour/$mois' : '$jour/$mois/${date.year}';
  }
}

// =============================================================================
// ÉTAT VIDE / ERREUR
// =============================================================================

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