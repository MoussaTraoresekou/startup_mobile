import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:startup_mobile/controller/messageri/messagerie_controller.dart';
import 'package:startup_mobile/cor/theme/app_theme.dart';
import 'package:startup_mobile/cor/utils/size_config.dart';
import 'package:startup_mobile/models/message_response_model.dart';
import 'package:startup_mobile/repository/message/message_repository.dart';

class PrivateChatScreen extends ConsumerStatefulWidget {
  const PrivateChatScreen({
    super.key,
    required this.conversationId,
    required this.interlocuteurNom,
    required this.projetTitre,
    required this.utilisateurConnecteId,
  });

  final int conversationId;
  final String interlocuteurNom;
  final String projetTitre;
  final int utilisateurConnecteId;

  @override
  ConsumerState<PrivateChatScreen> createState() =>
      _PrivateChatScreenState();
}

class _PrivateChatScreenState extends ConsumerState<PrivateChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<MessageResponseModel> _messages = [];

  StreamSubscription<MessageResponseModel>? _messagesSubscription;

  bool _peutEnvoyer = false;
  bool _chargement = true;
  bool _envoiEnCours = false;
  String? _erreur;

  // ===========================================================================
  // LOGIQUE (inchangée)
  // ===========================================================================

  @override
  void initState() {
    super.initState();

    _controller.addListener(_actualiserBoutonEnvoi);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialiserConversation();
    });
  }

  // Actualise l'état du bouton d'envoi selon le contenu du champ.
  void _actualiserBoutonEnvoi() {
    final peutEnvoyer = _controller.text.trim().isNotEmpty;

    if (peutEnvoyer != _peutEnvoyer && mounted) {
      setState(() {
        _peutEnvoyer = peutEnvoyer;
      });
    }
  }

  // Initialise la connexion, l'écoute des messages et l'historique.
  Future<void> _initialiserConversation() async {
    try {
      // 1. S'abonner au flux avant de connecter le WebSocket.
      final flux = ref.read(messageRepositoryProvider).messages;

      _messagesSubscription = flux.listen(
        (message) {
          if (!mounted) return;

          // Ignorer les messages d'une autre conversation.
          if (message.conversationId != widget.conversationId) {
            return;
          }

          // Éviter les doublons.
          final existe = _messages.any((m) => m.id == message.id);
          if (existe) return;

          setState(() {
            _messages.add(message);
            _messages.sort(_comparerMessages);
          });

          _defilerVersBas();
        },
        onError: (Object error) {
          debugPrint('ERREUR FLUX MESSAGES : $error');

          if (!mounted) return;

          setState(() {
            _erreur = 'La réception des messages a rencontré un problème.';
          });
        },
      );

      // 2. Établir la connexion WebSocket.
      final connecte = await ref
          .read(messagerieControllerProvider.notifier)
          .connecter(widget.conversationId);

      if (!mounted) return;

      if (!connecte) {
        setState(() {
          _chargement = false;
          _erreur = 'Impossible de connecter la messagerie.';
        });
        return;
      }

      // 3. Charger l'historique après la connexion.
      final historique = await ref.read(
        historiqueMessagesProvider(widget.conversationId).future,
      );

      if (!mounted) return;

      // 4. Fusionner l'historique avec les messages déjà reçus.
      setState(() {
        for (final message in historique) {
          final existe = _messages.any((m) => m.id == message.id);

          if (!existe) {
            _messages.add(message);
          }
        }

        _messages.sort(_comparerMessages);
        _chargement = false;
        _erreur = null;
      });

      _defilerVersBas();
    } catch (e, stackTrace) {
      debugPrint('ERREUR INITIALISATION MESSAGERIE : $e');
      debugPrint('$stackTrace');

      if (!mounted) return;

      setState(() {
        _chargement = false;
        _erreur = 'Impossible d’initialiser la messagerie.';
      });
    }
  }

  // Trie les messages du plus ancien au plus récent.
  int _comparerMessages(
    MessageResponseModel a,
    MessageResponseModel b,
  ) {
    final dateA = a.dateEnvoi;
    final dateB = b.dateEnvoi;

    if (dateA == null && dateB == null) {
      return a.id.compareTo(b.id);
    }

    if (dateA == null) return -1;
    if (dateB == null) return 1;

    final comparaison = dateA.compareTo(dateB);

    // En cas de dates identiques, utiliser l'identifiant.
    if (comparaison == 0) {
      return a.id.compareTo(b.id);
    }

    return comparaison;
  }

  // Fait défiler la liste jusqu'au dernier message.
  void _defilerVersBas() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  // Envoie un message via le contrôleur Riverpod.
  Future<void> _envoyer() async {
    final contenu = _controller.text.trim();

    if (contenu.isEmpty || _envoiEnCours) return;

    setState(() {
      _envoiEnCours = true;
      _erreur = null;
    });

    try {
      final succes = await ref
          .read(messagerieControllerProvider.notifier)
          .envoyer(
            conversationId: widget.conversationId,
            contenu: contenu,
          );

      if (!mounted) return;

      if (succes) {
        _controller.clear();
      } else {
        setState(() {
          _erreur = 'Impossible d’envoyer le message. Réessayez.';
        });
      }
    } catch (e, stackTrace) {
      debugPrint('ERREUR ENVOI MESSAGE : $e');
      debugPrint('$stackTrace');

      if (!mounted) return;

      setState(() {
        _erreur = 'Une erreur est survenue pendant l’envoi.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _envoiEnCours = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _messagesSubscription?.cancel();
    _controller.removeListener(_actualiserBoutonEnvoi);
    _controller.dispose();
    _scrollController.dispose();

    // Le repository est partagé : on ne ferme pas ici
    // la connexion WebSocket globale.
    super.dispose();
  }

  // ===========================================================================
  // OUTILS D'AFFICHAGE
  // ===========================================================================

  String _initiales(String nom) {
    final parties = nom
        .trim()
        .split(RegExp(r'\s+'))
        .where((partie) => partie.isNotEmpty)
        .toList();

    if (parties.isEmpty) return '?';
    if (parties.length == 1) return parties.first[0].toUpperCase();

    return '${parties.first[0]}${parties.last[0]}'.toUpperCase();
  }

  String _deux(int n) => n.toString().padLeft(2, '0');

  String _formaterHeure(DateTime date) {
    final locale = date.toLocal();
    return '${_deux(locale.hour)}:${_deux(locale.minute)}';
  }

  bool _memeJour(DateTime a, DateTime b) {
    final x = a.toLocal();
    final y = b.toLocal();
    return x.year == y.year && x.month == y.month && x.day == y.day;
  }

  String _libelleJour(DateTime date) {
    final locale = date.toLocal();
    final maintenant = DateTime.now();

    if (_memeJour(locale, maintenant)) return 'Aujourd’hui';
    if (_memeJour(locale, maintenant.subtract(const Duration(days: 1)))) {
      return 'Hier';
    }

    return '${_deux(locale.day)}/${_deux(locale.month)}/${locale.year}';
  }

  // ===========================================================================
  // PAGE
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgColor,
      appBar: AppBar(
        backgroundColor: context.background,
        foregroundColor: context.textDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 0,
        shape: Border(bottom: BorderSide(color: context.borderColor)),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: context.primarySoft,
              child: Text(
                _initiales(widget.interlocuteurNom),
                style: context.normalTextStyle.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: context.primary,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.interlocuteurNom,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.titleTextStyle.copyWith(
                      fontSize: 16.sp(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    widget.projetTitre,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.normalTextStyle.copyWith(
                      fontSize: 12.sp(context),
                      color: context.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          if (_erreur != null) _bandeauErreur(),
          Expanded(
            child: _chargement
                ? Center(
                    child: CircularProgressIndicator(color: context.primary),
                  )
                : _messages.isEmpty
                    ? _etatVide()
                    : _listeMessages(),
          ),
          _construireZoneSaisie(),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // BANDEAU D'ERREUR
  // ---------------------------------------------------------------------------

  Widget _bandeauErreur() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: context.badgeRed.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: context.badgeRed.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, size: 18, color: context.badgeRed),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _erreur!,
              style: context.normalTextStyle.copyWith(
                fontSize: 13.sp(context),
                color: context.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // ÉTAT VIDE
  // ---------------------------------------------------------------------------

  Widget _etatVide() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.chat_bubble_outline_rounded,
              size: 44,
              color: context.textMuted,
            ),
            const SizedBox(height: 12),
            Text(
              'Aucun message pour le moment',
              textAlign: TextAlign.center,
              style: context.titleTextStyle.copyWith(
                fontSize: 16.sp(context),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Envoyez un message pour commencer la conversation.',
              textAlign: TextAlign.center,
              style: context.normalTextStyle.copyWith(
                fontSize: 13.sp(context),
                height: 1.4,
                color: context.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // LISTE DES MESSAGES
  // ---------------------------------------------------------------------------

  Widget _listeMessages() {
    return ListView.builder(
      controller: _scrollController,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        final precedent = index > 0 ? _messages[index - 1] : null;
        final suivant =
            index < _messages.length - 1 ? _messages[index + 1] : null;

        // Identification fiable par l'identifiant de l'expéditeur.
        final estMoi = message.expediteurId == widget.utilisateurConnecteId;

        // Séparateur de jour quand la date change.
        final date = message.dateEnvoi;
        final afficherJour = date != null &&
            (precedent?.dateEnvoi == null ||
                !_memeJour(precedent!.dateEnvoi!, date));

        // Les messages consécutifs d'une même personne sont regroupés.
        final finDeGroupe =
            suivant == null || suivant.expediteurId != message.expediteurId;

        return Column(
          children: [
            if (afficherJour) _separateurJour(date),
            _construireBulle(message, estMoi, finDeGroupe),
          ],
        );
      },
    );
  }

  Widget _separateurJour(DateTime date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: context.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: context.borderColor),
        ),
        child: Text(
          _libelleJour(date),
          style: context.normalTextStyle.copyWith(
            fontSize: 12.sp(context),
            color: context.textMuted,
          ),
        ),
      ),
    );
  }

  Widget _construireBulle(
    MessageResponseModel message,
    bool estMoi,
    bool finDeGroupe,
  ) {
    final couleurFond = estMoi ? context.primary : context.background;
    final couleurTexte = estMoi ? context.textInverse : context.textDark;

    return Align(
      alignment: estMoi ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.78,
        ),
        margin: EdgeInsets.only(bottom: finDeGroupe ? 10 : 3),
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
        decoration: BoxDecoration(
          color: couleurFond,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(14),
            topRight: const Radius.circular(14),
            // Le petit coin « queue » n'apparaît que sur le dernier message
            // d'une série.
            bottomLeft: Radius.circular(estMoi || !finDeGroupe ? 14 : 4),
            bottomRight: Radius.circular(!estMoi || !finDeGroupe ? 14 : 4),
          ),
          border: estMoi ? null : Border.all(color: context.borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                message.contenu,
                style: context.normalTextStyle.copyWith(
                  fontSize: 15.sp(context),
                  height: 1.35,
                  color: couleurTexte,
                ),
              ),
            ),
            if (message.dateEnvoi != null) ...[
              const SizedBox(height: 3),
              Text(
                _formaterHeure(message.dateEnvoi!),
                style: context.normalTextStyle.copyWith(
                  fontSize: 10.sp(context),
                  color: estMoi
                      ? couleurTexte.withValues(alpha: 0.75)
                      : context.textMuted,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // ZONE DE SAISIE
  // ---------------------------------------------------------------------------

  Widget _construireZoneSaisie() {
    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(color: color, width: width),
        );

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      decoration: BoxDecoration(
        color: context.background,
        border: Border(top: BorderSide(color: context.borderColor)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                minLines: 1,
                maxLines: 5,
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) => _envoyer(),
                style: context.normalTextStyle.copyWith(
                  fontSize: 15.sp(context),
                  color: context.textDark,
                ),
                decoration: InputDecoration(
                  hintText: 'Écrire un message...',
                  hintStyle: context.normalTextStyle.copyWith(
                    fontSize: 14.sp(context),
                    color: context.textMuted,
                  ),
                  filled: true,
                  fillColor: context.bgColor,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: border(context.borderColor),
                  enabledBorder: border(context.borderColor),
                  focusedBorder: border(context.borderSelected, 1.5),
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 46,
              height: 46,
              child: IconButton(
                onPressed: _peutEnvoyer && !_envoiEnCours ? _envoyer : null,
                padding: EdgeInsets.zero,
                style: IconButton.styleFrom(
                  backgroundColor: context.primaryOrange,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor:
                      context.primaryOrange.withValues(alpha: 0.4),
                  disabledForegroundColor: Colors.white,
                ),
                icon: _envoiEnCours
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send_rounded, size: 21),
              ),
            ),
          ],
        ),
      ),
    );
  }
}