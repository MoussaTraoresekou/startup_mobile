import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:startup_mobile/controller/messageri/messagerie_controller.dart';
import 'package:startup_mobile/repository/like/like_repository.dart';
import 'package:startup_mobile/controller/conversation/conversation_controller.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

import 'package:startup_mobile/cor/theme/app_theme.dart';
import 'package:startup_mobile/cor/utils/size_config.dart';
import 'package:startup_mobile/models/ProjetModel .dart';
import 'package:startup_mobile/pages/Investisseur/pitch_utils.dart';

class InvestorProjectDetailScreen extends ConsumerStatefulWidget {
  final ProjetModel projet;
  final VoidCallback? onContactPressed;
  final Future<void> Function(String commentaire)? onSubmitAvis;

  const InvestorProjectDetailScreen({
    super.key,
    required this.projet,
    this.onContactPressed,
    this.onSubmitAvis,
  });

  @override
  ConsumerState<InvestorProjectDetailScreen> createState() =>
      _InvestorProjectDetailScreenState();
}

class _InvestorProjectDetailScreenState
    extends ConsumerState<InvestorProjectDetailScreen> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _contactEnCours = false;

  @override
  void initState() {
    super.initState();
    _initialiserVideo();
  }

  @override
  void dispose() {
    _libererVideo();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // PITCH
  // ---------------------------------------------------------------------------

  String get _pitchUrl => widget.projet.pithUrl.trim();
  PitchType get _type => pitchTypeOf(_pitchUrl);

  Future<void> _initialiserVideo() async {
    if (_type != PitchType.video) return;

    try {
      final controller = VideoPlayerController.networkUrl(Uri.parse(_pitchUrl));
      _videoController = controller;
      await controller.initialize();

      if (!mounted || _videoController != controller) {
        await controller.dispose();
        return;
      }

      final chewie = ChewieController(
        videoPlayerController: controller,
        autoPlay: false,
        looping: false,
        aspectRatio: controller.value.aspectRatio,
        materialProgressColors: ChewieProgressColors(
          playedColor: context.primary,
          handleColor: context.primary,
          backgroundColor: Colors.white24,
          bufferedColor: Colors.white54,
        ),
      );

      setState(() => _chewieController = chewie);
    } catch (e) {
      debugPrint('Erreur de chargement du pitch : $e');
      if (mounted) setState(() {});
    }
  }

  void _libererVideo() {
    _chewieController?.dispose();
    _chewieController = null;
    _videoController?.dispose();
    _videoController = null;
  }

  Future<void> _ouvrirPdf() async {
    final uri = Uri.tryParse(_pitchUrl);

    if (uri == null || !uri.hasScheme) {
      _afficherMessage('Le lien du pitch est invalide.');
      return;
    }

    try {
      final ouvert = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ouvert) _afficherMessage('Impossible d’ouvrir le document PDF.');
    } catch (_) {
      _afficherMessage('Erreur lors de l’ouverture du PDF.');
    }
  }

  // ---------------------------------------------------------------------------
  // ACTIONS
  // ---------------------------------------------------------------------------

  Future<void> _basculerLike() async {
    try {
      await ref.read(likesProvider.notifier).basculer(widget.projet.id);
    } catch (_) {
      _afficherMessage('Impossible de mettre à jour le like.');
    }
  }


Future<void> _contacterPorteur() async {
  // Conserver le comportement existant si un callback externe est fourni.
  if (widget.onContactPressed != null) {
    widget.onContactPressed!.call();
    return;
  }

  if (_contactEnCours) return;

  setState(() => _contactEnCours = true);

  try {
    // 1. Ouvrir ou récupérer la conversation avec le porteur.
    final conversation = await ref
        .read(conversationControllerProvider.notifier)
        .ouvrirConversation(widget.projet.id);

    if (!mounted) return;

    if (conversation == null) {
      _afficherMessage(
        'Impossible de récupérer la conversation avec le porteur.',
      );
      return;
    }

    debugPrint('CONVERSATION REÇUE : ${conversation.id}');

    // 2. Établir la connexion WebSocket.
    final connecte = await ref
        .read(messagerieControllerProvider.notifier)
        .connecter(conversation.id);

    if (!mounted) return;

    // 3. Ne pas ouvrir l'écran si la connexion a échoué.
    if (!connecte) {
      _afficherMessage(
        'Impossible de connecter la messagerie. Réessayez.',
      );
      return;
    }

    debugPrint('CONNEXION MESSAGERIE RÉUSSIE');

    // 4. Ouvrir l'écran de discussion.
    await context.push('/conversation', extra: conversation);
  } catch (e, stackTrace) {
    debugPrint('ERREUR OUVERTURE MESSAGERIE : $e');
    debugPrint('DÉTAILS : $stackTrace');

    if (mounted) {
      _afficherMessage(
        'Une erreur est survenue lors de l’ouverture de la messagerie.',
      );
    }
  } finally {
    if (mounted) {
      setState(() => _contactEnCours = false);
    }
  }
}

  Future<void> _ouvrirFormulaireAvis() async {
    final envoye = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AvisSheet(
        titre: widget.projet.titre,
        onSubmit: widget.onSubmitAvis,
      ),
    );

    if (envoye == true) _afficherMessage('Votre avis a été envoyé.');
  }

  void _afficherMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
  }

  // ---------------------------------------------------------------------------
  // PAGE
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final projet = widget.projet;
    final description = projet.description.trim();
    final isLiked =
        ref.watch(likesProvider).value?.contains(projet.id) ?? false;

    return Scaffold(
      backgroundColor: context.bgColor,
      appBar: AppBar(
        backgroundColor: context.bgColor,
        foregroundColor: context.textDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text(
          'Détail du projet',
          style: context.titleTextStyle.copyWith(fontSize: 17.sp(context)),
        ),
        actions: [
          IconButton(
            onPressed: _basculerLike,
            icon: Icon(
              isLiked ? Icons.favorite : Icons.favorite_border,
              color: isLiked ? context.badgeRed : context.textDark,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: _construireContenuPitch(),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    projet.titre,
                    style: context.headingTextStyle.copyWith(
                      fontSize: 22.sp(context),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _construireInfos(),
                  const SizedBox(height: 22),
                  Text(
                    'À propos du projet',
                    style: context.titleTextStyle.copyWith(
                      fontSize: 16.sp(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description.isNotEmpty
                        ? description
                        : 'Aucune description disponible pour le moment.',
                    style: context.normalTextStyle.copyWith(
                      fontSize: 15.sp(context),
                      height: 1.6,
                      color: description.isNotEmpty
                          ? context.textDark
                          : context.textMuted,
                    ),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    'Votre avis',
                    style: context.titleTextStyle.copyWith(
                      fontSize: 16.sp(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Une remarque ou une question sur ce projet ?',
                    style: context.normalTextStyle.copyWith(
                      fontSize: 13.sp(context),
                      color: context.textMuted,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _ouvrirFormulaireAvis,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: context.primary,
                        side: BorderSide(color: context.primary),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: const Text('Donner mon avis'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          _construireBarreContact(),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // PITCH : vidéo, PDF ou indisponible
  // ---------------------------------------------------------------------------

  Widget _construireContenuPitch() {
    switch (_type) {
      case PitchType.video:
        if (_videoController?.value.hasError == true) {
          return _blocPitch(
            icon: Icons.videocam_off_outlined,
            message: 'Impossible de charger la vidéo.',
          );
        }

        if (_chewieController != null) {
          return Container(
            color: Colors.black,
            child: Chewie(controller: _chewieController!),
          );
        }

        return Container(
          color: Colors.black,
          child: const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        );

      case PitchType.pdf:
        return _blocPitch(
          icon: Icons.picture_as_pdf_outlined,
          message: 'Présentation du projet (PDF)',
          action: OutlinedButton.icon(
            onPressed: _ouvrirPdf,
            style: OutlinedButton.styleFrom(
              foregroundColor: context.primary,
              side: BorderSide(color: context.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            icon: const Icon(Icons.open_in_new_rounded, size: 18),
            label: const Text('Ouvrir le PDF'),
          ),
        );

      case PitchType.none:
        return _blocPitch(
          icon: Icons.videocam_off_outlined,
          message: _pitchUrl.isEmpty
              ? 'Aucun pitch disponible.'
              : 'Format de pitch non pris en charge.',
        );
    }
  }

  Widget _blocPitch({
    required IconData icon,
    required String message,
    Widget? action,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: context.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.borderColor),
      ),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 40,
            color: action != null ? context.primary : context.textMuted,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: context.normalTextStyle.copyWith(
              fontSize: 14.sp(context),
              color: context.textMuted,
            ),
          ),
          if (action != null) ...[
            const SizedBox(height: 12),
            action,
          ],
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // INFORMATIONS : secteur, porteur, quota
  // ---------------------------------------------------------------------------

  Widget _construireInfos() {
    final projet = widget.projet;

    return Container(
      decoration: BoxDecoration(
        color: context.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        children: [
          _ligneInfo(
            Icons.category_outlined,
            'Secteur',
            projet.secteur.isNotEmpty ? projet.secteur : 'Non précisé',
          ),
          Divider(height: 1, color: context.borderColor),
          _ligneInfo(
            Icons.person_outline_rounded,
            'Porteur',
            projet.porteurNomComplet.trim().isNotEmpty
                ? projet.porteurNomComplet.trim()
                : 'Non précisé',
          ),
          Divider(height: 1, color: context.borderColor),
          _ligneInfo(
            Icons.account_balance_wallet_outlined,
            'Quota proposé',
            projet.quotaPropose,
          ),
        ],
      ),
    );
  }

  Widget _ligneInfo(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 19, color: context.primary),
          const SizedBox(width: 10),
          Text(
            label,
            style: context.normalTextStyle.copyWith(
              fontSize: 13.sp(context),
              color: context.textMuted,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: context.normalTextStyle.copyWith(
                fontSize: 14.sp(context),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // BARRE DE CONTACT (seul bouton orange de l'écran)
  // ---------------------------------------------------------------------------

  Widget _construireBarreContact() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: context.background,
        border: Border(top: BorderSide(color: context.borderColor)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: _contactEnCours ? null : _contacterPorteur,
            style: ElevatedButton.styleFrom(
              backgroundColor: context.primaryOrange,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            icon: const Icon(Icons.chat_outlined, size: 20),
            label: const Text(
              'Contacter le porteur',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// FORMULAIRE D'AVIS (le contrôleur de texte est géré à l'intérieur)
// =============================================================================

class _AvisSheet extends StatefulWidget {
  const _AvisSheet({required this.titre, required this.onSubmit});

  final String titre;
  final Future<void> Function(String commentaire)? onSubmit;

  @override
  State<_AvisSheet> createState() => _AvisSheetState();
}

class _AvisSheetState extends State<_AvisSheet> {
  final TextEditingController _controller = TextEditingController();
  bool _envoiEnCours = false;
  String? _erreur;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _envoyer() async {
    final commentaire = _controller.text.trim();

    if (commentaire.isEmpty) {
      setState(() => _erreur = 'Veuillez rédiger votre avis.');
      return;
    }

    final callback = widget.onSubmit;
    if (callback == null) {
      setState(() => _erreur = 'L’envoi des avis n’est pas encore relié.');
      return;
    }

    setState(() {
      _envoiEnCours = true;
      _erreur = null;
    });

    try {
      await callback(commentaire);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _envoiEnCours = false;
        _erreur = 'Impossible d’envoyer votre avis. Réessayez.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: color, width: width),
        );

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: context.background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.borderColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Votre avis', style: context.headingTextStyle),
              const SizedBox(height: 2),
              Text(
                widget.titre,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.normalTextStyle.copyWith(
                  fontSize: 14,
                  color: context.textMuted,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _controller,
                autofocus: true,
                enabled: !_envoiEnCours,
                minLines: 4,
                maxLines: 7,
                maxLength: 1500,
                textCapitalization: TextCapitalization.sentences,
                style: context.normalTextStyle.copyWith(fontSize: 15),
                onChanged: (_) {
                  if (_erreur != null) setState(() => _erreur = null);
                },
                decoration: InputDecoration(
                  hintText: 'Écrivez votre commentaire...',
                  hintStyle: context.normalTextStyle.copyWith(
                    fontSize: 14,
                    color: context.textMuted,
                  ),
                  errorText: _erreur,
                  filled: true,
                  fillColor: context.bgColor,
                  contentPadding: const EdgeInsets.all(14),
                  border: border(context.borderColor),
                  enabledBorder: border(context.borderColor),
                  disabledBorder: border(context.borderColor),
                  focusedBorder: border(context.borderSelected, 1.5),
                  errorBorder: border(context.badgeRed),
                  focusedErrorBorder: border(context.badgeRed, 1.5),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _envoiEnCours ? null : _envoyer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.primaryOrange,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        context.primaryOrange.withValues(alpha: 0.6),
                    disabledForegroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _envoiEnCours
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Envoyer',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}