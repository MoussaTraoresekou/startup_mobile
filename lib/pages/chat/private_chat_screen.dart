import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:startup_mobile/controller/messageri/messagerie_controller.dart';
import 'package:startup_mobile/cor/theme/app_theme.dart';
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
            _erreur =
                'La réception des messages a rencontré un problème.';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgColor,
      appBar: AppBar(
        backgroundColor: context.background,
        foregroundColor: context.textDark,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.interlocuteurNom,
              style: context.titleTextStyle,
            ),
            Text(
              widget.projetTitre,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.normalTextStyle.copyWith(
                color: context.textMuted,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          if (_erreur != null)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.primarySoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _erreur!,
                style: context.normalTextStyle.copyWith(
                  color: context.textDark,
                ),
              ),
            ),
          Expanded(
            child: _chargement
                ? const Center(
                    child: CircularProgressIndicator(),
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

  Widget _etatVide() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 48,
              color: context.textMuted,
            ),
            const SizedBox(height: 12),
            Text(
              'Aucun message pour le moment',
              textAlign: TextAlign.center,
              style: context.titleTextStyle,
            ),
            const SizedBox(height: 8),
            Text(
              'Envoyez un message pour commencer la conversation.',
              textAlign: TextAlign.center,
              style: context.normalTextStyle.copyWith(
                color: context.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _listeMessages() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];

        // Identification fiable par l'identifiant de l'expéditeur.
        final estMoi =
            message.expediteurId == widget.utilisateurConnecteId;

        return _construireBulle(message, estMoi);
      },
    );
  }

  Widget _construireBulle(
    MessageResponseModel message,
    bool estMoi,
  ) {
    final couleurFond = estMoi
        ? context.primary
        : context.background;

    final couleurTexte = estMoi
        ? context.textInverse
        : context.textDark;

    return Align(
      alignment: estMoi
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: couleurFond,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(estMoi ? 16 : 4),
            bottomRight: Radius.circular(estMoi ? 4 : 16),
          ),
          border: estMoi
              ? null
              : Border.all(color: context.borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              message.contenu,
              style: context.normalTextStyle.copyWith(
                color: couleurTexte,
              ),
            ),
            if (message.dateEnvoi != null) ...[
              const SizedBox(height: 4),
              Text(
                _formaterHeure(message.dateEnvoi!),
                style: context.normalTextStyle.copyWith(
                  color: estMoi
                      ? couleurTexte.withValues(alpha: 0.75)
                      : context.textMuted,
                  fontSize: 11,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _construireZoneSaisie() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: context.background,
        border: Border(
          top: BorderSide(color: context.borderColor),
        ),
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
                  color: context.textDark,
                ),
                decoration: InputDecoration(
                  hintText: 'Écrire un message...',
                  hintStyle: context.normalTextStyle.copyWith(
                    color: context.textMuted,
                  ),
                  filled: true,
                  fillColor: context.bgColor,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(
                      color: context.borderColor,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(
                      color: context.borderColor,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(
                      color: context.borderSelected,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed:
                  _peutEnvoyer && !_envoiEnCours ? _envoyer : null,
              style: IconButton.styleFrom(
                backgroundColor: context.primary,
                foregroundColor: context.textInverse,
                disabledBackgroundColor: context.primarySoft,
              ),
              icon: _envoiEnCours
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.send_rounded),
            ),
          ],
        ),
      ),
    );
  }

  String _formaterHeure(DateTime date) {
    final locale = date.toLocal();

    final heures = locale.hour.toString().padLeft(2, '0');
    final minutes = locale.minute.toString().padLeft(2, '0');

    return '$heures:$minutes';
  }
}

