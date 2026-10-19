
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

import 'package:startup_mobile/cor/theme/app_theme.dart';
import 'package:startup_mobile/cor/utils/size_config.dart';
import 'package:startup_mobile/models/ProjetModel .dart';

class InvestorProjectDetailScreen extends ConsumerStatefulWidget {
  final ProjetModel projet;
  final bool isLiked;
  final VoidCallback? onLikePressed;
  final VoidCallback? onContactPressed;
  final Future<void> Function(String commentaire)? onSubmitAvis;

  const InvestorProjectDetailScreen({
    super.key,
    required this.projet,
    this.isLiked = false,
    this.onLikePressed,
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

  bool _isLiked = false;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.isLiked;
    _initialiserVideo();
  }

  @override
  void didUpdateWidget(covariant InvestorProjectDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.isLiked != widget.isLiked) {
      _isLiked = widget.isLiked;
    }

    if (oldWidget.projet.pithUrl != widget.projet.pithUrl) {
      _libererVideo();
      _initialiserVideo();
    }
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

  bool get _estUneVideo {
    final uri = Uri.tryParse(_pitchUrl);
    return (uri?.path ?? _pitchUrl).toLowerCase().endsWith('.mp4');
  }

  bool get _estUnPdf {
    final uri = Uri.tryParse(_pitchUrl);
    return (uri?.path ?? _pitchUrl).toLowerCase().endsWith('.pdf');
  }

  Future<void> _initialiserVideo() async {
    if (_pitchUrl.isEmpty || !_estUneVideo) return;

    VideoPlayerController? controller;

    try {
      controller = VideoPlayerController.networkUrl(
        Uri.parse(_pitchUrl),
      );

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
        allowFullScreen: true,
        allowMuting: true,
        showControls: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: context.primary,
          handleColor: context.primaryOrange,
          backgroundColor: Colors.grey.shade300,
          bufferedColor: Colors.grey.shade500,
        ),
      );

      if (!mounted || _videoController != controller) {
        chewie.dispose();
        return;
      }

      setState(() => _chewieController = chewie);
    } catch (e) {
      debugPrint('Erreur de chargement du pitch : $e');
    }
  }

  void _libererVideo() {
    _chewieController?.dispose();
    _chewieController = null;

    _videoController?.dispose();
    _videoController = null;
  }

  Future<void> _ouvrirPdf() async {
    if (_pitchUrl.isEmpty) {
      _afficherMessage('Le pitch du projet n’est pas disponible.');
      return;
    }

    final uri = Uri.tryParse(_pitchUrl);

    if (uri == null || !uri.hasScheme) {
      _afficherMessage('Le lien du pitch est invalide.');
      return;
    }

    try {
      final ouvert = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!ouvert && mounted) {
        _afficherMessage('Impossible d’ouvrir le document PDF.');
      }
    } catch (e) {
      if (mounted) {
        _afficherMessage('Erreur lors de l’ouverture du PDF.');
      }
    }
  }

  // ---------------------------------------------------------------------------
  // LIKE
  // ---------------------------------------------------------------------------

  void _basculerLike() {
    setState(() => _isLiked = !_isLiked);
    widget.onLikePressed?.call();
  }

  // ---------------------------------------------------------------------------
  // CONTACT
  // ---------------------------------------------------------------------------

  void _contacterPorteur() {
    if (widget.onContactPressed != null) {
      widget.onContactPressed!.call();
    } else {
      _afficherMessage(
        'La messagerie doit être reliée à l’écran de conversation.',
      );
    }
  }

  // ---------------------------------------------------------------------------
  // AVIS : OUVERTURE DU FORMULAIRE DANS UNE FENÊTRE
  // ---------------------------------------------------------------------------

  Future<void> _ouvrirFormulaireAvis() async {
    final controller = TextEditingController();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        bool envoiEnCours = false;

        return StatefulBuilder(
          builder: (context, setModalState) {
            final clavier = MediaQuery.of(context).viewInsets.bottom;

            return Padding(
              padding: EdgeInsets.only(bottom: clavier),
              child: Container(
                decoration: BoxDecoration(
                  color: context.background,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(26),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    22.w(context),
                    12.h(context),
                    22.w(context),
                    24.h(context),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Center(
                        child: Container(
                          width: 42,
                          height: 4,
                          decoration: BoxDecoration(
                            color: context.borderColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),

                      SizedBox(height: 24.h(context)),

                      Row(
                        children: [
                          Container(
                            width: 48.w(context),
                            height: 48.w(context),
                            decoration: BoxDecoration(
                              color: context.primary.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Icon(
                              Icons.rate_review_outlined,
                              color: context.primary,
                              size: 25,
                            ),
                          ),
                          SizedBox(width: 13.w(context)),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Votre avis',
                                  style: context.headingTextStyle.copyWith(
                                    fontSize: 21,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                SizedBox(height: 4.h(context)),
                                Text(
                                  'Partagez votre opinion sur ce projet.',
                                  style: context.normalTextStyle.copyWith(
                                    color: context.textMuted,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: envoiEnCours
                                ? null
                                : () => Navigator.of(sheetContext).pop(),
                            icon: const Icon(Icons.close_rounded),
                            color: context.textMuted,
                          ),
                        ],
                      ),

                      SizedBox(height: 24.h(context)),

                      Text(
                        widget.projet.titre,
                        style: context.titleTextStyle.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      SizedBox(height: 16.h(context)),

                      Text(
                        'Votre commentaire',
                        style: context.normalTextStyle.copyWith(
                          fontWeight: FontWeight.w700,
                          color: context.textDark,
                        ),
                      ),

                      SizedBox(height: 9.h(context)),

                      TextField(
                        controller: controller,
                        autofocus: true,
                        minLines: 5,
                        maxLines: 8,
                        maxLength: 1500,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          hintText:
                              'Donnez votre avis, posez une question ou proposez une amélioration...',
                          hintStyle: context.normalTextStyle.copyWith(
                            color: context.textMuted,
                            fontSize: 13,
                            height: 1.5,
                          ),
                          filled: true,
                          fillColor: context.bgColor,
                          contentPadding: EdgeInsets.all(16.w(context)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(
                              color: context.borderColor,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(
                              color: context.borderColor,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(
                              color: context.primary,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 16.h(context)),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: envoiEnCours
                              ? null
                              : () async {
                                  final commentaire =
                                      controller.text.trim();

                                  if (commentaire.isEmpty) {
                                    _afficherMessage(
                                      'Veuillez rédiger votre avis.',
                                    );
                                    return;
                                  }

                                  final callback = widget.onSubmitAvis;

                                  if (callback == null) {
                                    _afficherMessage(
                                      'L’enregistrement des avis doit être '
                                      'relié au backend.',
                                    );
                                    return;
                                  }

                                  setModalState(() {
                                    envoiEnCours = true;
                                  });

                                  try {
                                    await callback(commentaire);

                                    if (!sheetContext.mounted) return;

                                    Navigator.of(sheetContext).pop();

                                    _afficherMessage(
                                      'Votre avis a été envoyé.',
                                    );
                                  } catch (e) {
                                    if (!sheetContext.mounted) return;

                                    setModalState(() {
                                      envoiEnCours = false;
                                    });

                                    _afficherMessage(
                                      'Impossible d’envoyer votre avis.',
                                    );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: context.primary,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor:
                                context.primary.withValues(alpha: 0.5),
                            padding: EdgeInsets.symmetric(
                              vertical: 16.h(context),
                            ),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          icon: envoiEnCours
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.send_rounded, size: 18),
                          label: Text(
                            envoiEnCours
                                ? 'Envoi en cours...'
                                : 'Envoyer mon avis',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 8.h(context)),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    controller.dispose();
  }

  void _afficherMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  // ---------------------------------------------------------------------------
  // PAGE PRINCIPALE
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        20.w(context),
                        12.h(context),
                        20.w(context),
                        24.h(context),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _construireNavigation(),
                          SizedBox(height: 18.h(context)),
                          _construirePitch(),
                          SizedBox(height: 24.h(context)),
                          _construireInformationsProjet(),
                          SizedBox(height: 24.h(context)),
                          _construireDescription(),
                          SizedBox(height: 22.h(context)),
                          _construireQuota(),
                          SizedBox(height: 26.h(context)),
                          _construireSectionAvis(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _construireBarreContact(),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // NAVIGATION DISCRÈTE
  // ---------------------------------------------------------------------------

  Widget _construireNavigation() {
    return Row(
      children: [
        _HeaderButton(
          icon: Icons.arrow_back_rounded,
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        const Spacer(),
        Text(
          'Détail du projet',
          style: context.normalTextStyle.copyWith(
            color: context.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // PITCH
  // ---------------------------------------------------------------------------

  Widget _construirePitch() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(
          title: 'Pitch du projet',
          subtitle: 'Découvrez la vision du porteur',
        ),
        SizedBox(height: 14.h(context)),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              width: double.infinity,
              color: context.background,
              child: _construireContenuPitch(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _construireContenuPitch() {
    if (_pitchUrl.isEmpty) {
      return _pitchIndisponible(
        'Aucun pitch disponible pour ce projet.',
      );
    }

    if (_estUneVideo) {
      if (_chewieController != null &&
          _videoController != null &&
          _videoController!.value.isInitialized) {
        return Chewie(controller: _chewieController!);
      }

      if (_videoController?.value.hasError == true) {
        return _pitchIndisponible('Impossible de charger la vidéo.');
      }

      return Center(
        child: CircularProgressIndicator(color: context.primary),
      );
    }

    if (_estUnPdf) {
      return InkWell(
        onTap: _ouvrirPdf,
        child: Padding(
          padding: EdgeInsets.all(20.w(context)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 64.w(context),
                height: 64.w(context),
                decoration: BoxDecoration(
                  color: context.primaryOrange.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  Icons.picture_as_pdf_rounded,
                  color: context.primaryOrange,
                  size: 34,
                ),
              ),
              SizedBox(height: 14.h(context)),
              Text(
                'Présentation du projet',
                textAlign: TextAlign.center,
                style: context.titleTextStyle.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 6.h(context)),
              Text(
                'Appuyez pour consulter le document PDF',
                textAlign: TextAlign.center,
                style: context.normalTextStyle.copyWith(
                  color: context.textMuted,
                  fontSize: 12,
                ),
              ),
              SizedBox(height: 12.h(context)),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 16.w(context),
                  vertical: 9.h(context),
                ),
                decoration: BoxDecoration(
                  color: context.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.open_in_new_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Ouvrir le PDF',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
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

    return _pitchIndisponible(
      'Format de pitch non pris en charge.',
    );
  }

  Widget _pitchIndisponible(String message) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20.w(context)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.ondemand_video_rounded,
              size: 42,
              color: context.textMuted,
            ),
            SizedBox(height: 10.h(context)),
            Text(
              message,
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

  // ---------------------------------------------------------------------------
  // TITRE, PORTEUR, SECTEUR ET LIKE
  // ---------------------------------------------------------------------------

  Widget _construireInformationsProjet() {
    final projet = widget.projet;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                projet.titre,
                style: context.headingTextStyle.copyWith(
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                  height: 1.25,
                ),
              ),
            ),
            SizedBox(width: 12.w(context)),
            _construireCoeur(),
          ],
        ),
        SizedBox(height: 14.h(context)),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _InfoBadge(
              icon: Icons.category_outlined,
              label: projet.secteur.isNotEmpty
                  ? projet.secteur
                  : 'Secteur non précisé',
              color: context.primary,
            ),
            _InfoBadge(
              icon: Icons.person_outline_rounded,
              label: projet.porteurNomComplet.isNotEmpty
                  ? projet.porteurNomComplet
                  : 'Porteur du projet',
              color: context.primaryOrange,
            ),
          ],
        ),
      ],
    );
  }

  Widget _construireCoeur() {
    return Material(
      color: _isLiked
          ? Colors.red.withValues(alpha: 0.10)
          : context.background,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: _basculerLike,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          width: 50.w(context),
          height: 50.w(context),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: _isLiked
                  ? Colors.red.withValues(alpha: 0.25)
                  : context.borderColor,
            ),
          ),
          child: Icon(
            _isLiked
                ? Icons.favorite_rounded
                : Icons.favorite_border_rounded,
            color: _isLiked ? Colors.red : context.textMuted,
            size: 25,
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // DESCRIPTION
  // ---------------------------------------------------------------------------

  Widget _construireDescription() {
    final description = widget.projet.description.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(
          title: 'À propos du projet',
          subtitle: 'Comprendre la solution proposée',
        ),
        SizedBox(height: 12.h(context)),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(18.w(context)),
          decoration: BoxDecoration(
            color: context.background,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: context.borderColor),
          ),
          child: Text(
            description.isNotEmpty
                ? description
                : 'Aucune description disponible pour le moment.',
            style: context.normalTextStyle.copyWith(
              color: description.isNotEmpty
                  ? context.textDark
                  : context.textMuted,
              height: 1.7,
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // QUOTA : CARTE SOBRE, SANS GRAND DÉGRADÉ
  // ---------------------------------------------------------------------------

  Widget _construireQuota() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w(context)),
      decoration: BoxDecoration(
        color: context.background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.borderColor),
        boxShadow: [
          BoxShadow(
            color: context.shadowColor.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50.w(context),
            height: 50.w(context),
            decoration: BoxDecoration(
              color: context.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              Icons.trending_up_rounded,
              color: context.primary,
              size: 26,
            ),
          ),
          SizedBox(width: 14.w(context)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quota proposé',
                  style: context.titleTextStyle.copyWith(
                    color: context.textMuted,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                SizedBox(height: 5.h(context)),
                Text(
                  widget.projet.quotaPropose.toString(),
                  style: context.titleTextStyle.copyWith(
                    color: context.textDark,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.account_balance_wallet_outlined,
            color: context.textMuted,
            size: 23,
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SECTION AVIS : UN SEUL BOUTON POUR OUVRIR LE FORMULAIRE
  // ---------------------------------------------------------------------------

  Widget _construireSectionAvis() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w(context)),
      decoration: BoxDecoration(
        color: context.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.borderColor),
        boxShadow: [
          BoxShadow(
            color: context.shadowColor.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48.w(context),
            height: 48.w(context),
            decoration: BoxDecoration(
              color: context.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              Icons.rate_review_outlined,
              color: context.primary,
              size: 24,
            ),
          ),
          SizedBox(width: 14.w(context)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Votre avis',
                  style: context.titleTextStyle.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                SizedBox(height: 5.h(context)),
                Text(
                  'Une remarque ou une suggestion sur ce projet ?',
                  style: context.normalTextStyle.copyWith(
                    color: context.textMuted,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 13.h(context)),
                
                OutlinedButton.icon(
                  onPressed: _ouvrirFormulaireAvis,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: context.primary,
                    side: BorderSide(color: context.primary),
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w(context),
                      vertical: 11.h(context),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(
                    Icons.edit_outlined,
                    size: 17,
                  ),
                  label: const Text(
                    'Rédiger votre avis',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // UN SEUL BOUTON DE CONTACT, FIXÉ EN BAS
  // ---------------------------------------------------------------------------

  Widget _construireBarreContact() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20.w(context),
        12.h(context),
        20.w(context),
        12.h(context),
      ),
      decoration: BoxDecoration(
        color: context.background,
        border: Border(
          top: BorderSide(color: context.borderColor),
        ),
        boxShadow: [
          BoxShadow(
            color: context.shadowColor.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _contacterPorteur,
            style: ElevatedButton.styleFrom(
              backgroundColor: context.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: EdgeInsets.symmetric(
                vertical: 16.h(context),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            icon: const Icon(Icons.chat_rounded, size: 19),
            label: const Text(
              'Contacter le porteur',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// WIDGETS RÉUTILISABLES
// =============================================================================

class _HeaderButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _HeaderButton({
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.background,
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(13),
        child: Container(
          width: 44.w(context),
          height: 44.w(context),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: context.borderColor),
          ),
          child: Icon(
            icon,
            color: context.textDark,
            size: 21,
          ),
        ),
      ),
    );
  }
}

class _InfoBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoBadge({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 11.w(context),
        vertical: 8.h(context),
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          SizedBox(width: 6.w(context)),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 190.w(context)),
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: context.normalTextStyle.copyWith(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String? subtitle;

  const _SectionTitle({
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: context.titleTextStyle.copyWith(
            color: context.textDark,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        if (subtitle != null) ...[
          SizedBox(height: 5.h(context)),
          Text(
            subtitle!,
            style: context.normalTextStyle.copyWith(
              color: context.textMuted,
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ],
      ],
    );
  }
}
