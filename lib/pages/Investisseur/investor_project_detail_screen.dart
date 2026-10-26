
import 'package:chewie/chewie.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:startup_mobile/controller/messageri/messagerie_controller.dart';
import 'package:startup_mobile/controller/conversation/conversation_controller.dart';
import 'package:startup_mobile/cor/config/ApiConfig.dart';
import 'package:startup_mobile/cor/reseau/dio_provider.dart';
import 'package:startup_mobile/cor/theme/app_theme.dart';
import 'package:startup_mobile/cor/utils/size_config.dart';
import 'package:startup_mobile/models/ProjetModel .dart';
import 'package:startup_mobile/pages/Investisseur/pith_cover.dart';
import 'package:startup_mobile/pages/Investisseur/pitch_utils.dart';

import 'package:startup_mobile/pages/pith_thumnail/pitch_video_url_stub.dart'
    if (dart.library.js_interop)
        'package:startup_mobile/pages/Investisseur/pitch_video_url_web.dart'
    as video_url;

import 'package:startup_mobile/pages/pith_thumnail/pitch_pdf_open_stub.dart'
    if (dart.library.io)
        'package:startup_mobile/pages/pith_thumnail/pitch_pdf_open_io.dart'
    as pdf_open;


import 'package:startup_mobile/pages/pith_thumnail/pitch_pdf_open_web.dart'
    if (dart.library.js_interop)
        'package:startup_mobile/pages/pith_thumnail/pitch_pdf_open_web.dart'
    as pdf_web;

import 'package:startup_mobile/repository/like/like_repository.dart';
import 'package:video_player/video_player.dart';

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

  String? _urlVideoTemporaire;

  bool _contactEnCours = false;
  bool _lectureDemandee = false;
  bool _erreurVideo = false;
  bool _likeEnCours = false;
  bool _pdfEnCours = false;

  String get _pitchUrl => widget.projet.pithUrl.trim();

  String get _miniatureUrl =>
      widget.projet.pithThumbnailUrl?.trim() ?? '';

  PitchType get _type => pitchTypeOf(_pitchUrl);

  Uri _construireUriFichier(String nomFichier) {
    final baseUrl = ApiConfig.baseUrl.replaceFirst(RegExp(r'/$'), '');
    final nomEncode = Uri.encodeComponent(nomFichier);

    return Uri.parse('$baseUrl/api/fichiers/pitch/$nomEncode');
  }

  Future<void> _lancerVideo() async {
    if (_lectureDemandee || _type != PitchType.video) return;

    setState(() {
      _lectureDemandee = true;
      _erreurVideo = false;
    });

    await _initialiserVideo();
  }

  Future<void> _initialiserVideo() async {
    if (_type != PitchType.video || _pitchUrl.isEmpty) {
      if (mounted) {
        setState(() => _erreurVideo = true);
      }
      return;
    }

    VideoPlayerController? controller;

    try {
      final dio = ref.read(dioProvider);

      final response = await dio.get<List<int>>(
        _construireUriFichier(_pitchUrl).toString(),
        options: Options(
          responseType: ResponseType.bytes,
          headers: const {'Accept': 'video/mp4'},
        ),
      );

      final donnees = response.data;

      if (donnees == null || donnees.isEmpty) {
        throw Exception('Le fichier vidéo reçu est vide.');
      }

      final url = await video_url.creerUrlVideo(donnees);

      if (!mounted) {
        video_url.libererUrlVideo(url);
        return;
      }

      _urlVideoTemporaire = url;

      controller = VideoPlayerController.networkUrl(Uri.parse(url));
      _videoController = controller;

      await controller.initialize();

      if (!mounted || _videoController != controller) {
        await controller.dispose();
        return;
      }

      if (controller.value.hasError) {
        throw Exception('Le lecteur vidéo a signalé une erreur.');
      }

      final chewie = ChewieController(
        videoPlayerController: controller,
        autoPlay: true,
        looping: false,
        aspectRatio: controller.value.aspectRatio > 0
            ? controller.value.aspectRatio
            : 16 / 9,
        materialProgressColors: ChewieProgressColors(
          playedColor: context.primary,
          handleColor: context.primary,
          backgroundColor: Colors.white24,
          bufferedColor: Colors.white54,
        ),
      );

      setState(() {
        _chewieController = chewie;
      });
    } catch (e, stackTrace) {
      debugPrint('Erreur de chargement du pitch vidéo : $e');
      debugPrint('$stackTrace');

      if (controller != null) {
        await controller.dispose();

        if (_videoController == controller) {
          _videoController = null;
        }
      }

      _libererUrlTemporaire();

      if (mounted) {
        setState(() => _erreurVideo = true);
      }
    }
  }

  void _libererUrlTemporaire() {
    final url = _urlVideoTemporaire;
    _urlVideoTemporaire = null;

    if (url != null) {
      video_url.libererUrlVideo(url);
    }
  }

  void _libererVideo() {
    _chewieController?.dispose();
    _chewieController = null;

    _videoController?.dispose();
    _videoController = null;

    _libererUrlTemporaire();
  }

  Future<void> _ouvrirPdf() async {
    if (_pdfEnCours) return;

    if (_pitchUrl.isEmpty || _type != PitchType.pdf) {
      _afficherMessage('Le document PDF est indisponible.');
      return;
    }

    setState(() => _pdfEnCours = true);

    try {
      final dio = ref.read(dioProvider);

      final response = await dio.get<List<int>>(
        _construireUriFichier(_pitchUrl).toString(),
        options: Options(
          responseType: ResponseType.bytes,
          headers: const {'Accept': 'application/pdf'},
        ),
      );

      final donnees = response.data;

      if (donnees == null || donnees.isEmpty) {
        throw Exception('Le fichier PDF reçu est vide.');
      }

      if (kIsWeb) {
        await pdf_web.ouvrirPdfWeb(donnees);
      } else {
        await pdf_open.ouvrirPdfNatif(
          donnees,
          'pitch_${widget.projet.id}.pdf',
        );
      }
    } on DioException catch (e) {
      debugPrint('Erreur HTTP lors du téléchargement du PDF : $e');

      if (mounted) {
        final message = switch (e.response?.statusCode) {
          401 => 'Votre session a expiré. Veuillez vous reconnecter.',
          403 => 'Vous n’êtes pas autorisé à consulter ce document.',
          404 => 'Le fichier PDF est introuvable sur le serveur.',
          _ => 'Impossible de télécharger le PDF.',
        };

        _afficherMessage(message);
      }
    } catch (e, stackTrace) {
      debugPrint('Erreur lors de l’ouverture du PDF : $e');
      debugPrint('$stackTrace');

      if (mounted) {
        _afficherMessage('Erreur lors de l’ouverture du document PDF.');
      }
    } finally {
      if (mounted) {
        setState(() => _pdfEnCours = false);
      }
    }
  }

  Future<void> _basculerLike() async {
    if (_likeEnCours) return;

    setState(() => _likeEnCours = true);

    try {
      await ref.read(likesProvider.notifier).basculer(widget.projet.id);
    } catch (e) {
      debugPrint('Erreur de mise à jour du like : $e');

      if (mounted) {
        _afficherMessage('Impossible de mettre à jour le like.');
      }
    } finally {
      if (mounted) {
        setState(() => _likeEnCours = false);
      }
    }
  }

  Future<void> _contacterPorteur() async {
    if (widget.onContactPressed != null) {
      widget.onContactPressed!.call();
      return;
    }

    if (_contactEnCours) return;

    setState(() => _contactEnCours = true);

    try {
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

      final connecte = await ref
          .read(messagerieControllerProvider.notifier)
          .connecter(conversation.id);

      if (!mounted) return;

      if (!connecte) {
        _afficherMessage(
          'Impossible de connecter la messagerie. Réessayez.',
        );
        return;
      }

      debugPrint('CONNEXION MESSAGERIE RÉUSSIE');

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

    if (envoye == true && mounted) {
      _afficherMessage('Votre avis a été envoyé.');
    }
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

  @override
  void dispose() {
    _libererVideo();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final projet = widget.projet;
    final description = projet.description.trim();

    final likes = ref.watch(likesProvider).value ?? <int>{};
    final isLiked = likes.contains(projet.id);

    final compteursLikes = ref.watch(likeCountsProvider);
    final nombreLikes = compteursLikes[projet.id] ?? projet.nombreLikes;

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
          style: context.titleTextStyle.copyWith(
            fontSize: 17.sp(context),
          ),
        ),
        actions: [
          IconButton(
            onPressed: _likeEnCours ? null : _basculerLike,
            icon: _likeEnCours
                ? SizedBox(
                    width: 20.w(context),
                    height: 20.h(context),
                    child: CircularProgressIndicator(
                      strokeWidth: 2.w(context),
                      color: context.primary,
                    ),
                  )
                : Icon(
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
              padding: EdgeInsets.fromLTRB(
                16.w(context),
                8.h(context),
                16.w(context),
                24.h(context),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.w(context)),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: _construireContenuPitch(),
                    ),
                  ),
                  SizedBox(height: 18.h(context)),
                  Text(
                    projet.titre,
                    style: context.headingTextStyle.copyWith(
                      fontSize: 22.sp(context),
                    ),
                  ),
                  SizedBox(height: 14.h(context)),
                  _construireInfos(nombreLikes),
                  SizedBox(height: 22.h(context)),
                  Text(
                    'À propos du projet',
                    style: context.titleTextStyle.copyWith(
                      fontSize: 16.sp(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.h(context)),
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
                  SizedBox(height: 22.h(context)),
                  Text(
                    'Votre avis',
                    style: context.titleTextStyle.copyWith(
                      fontSize: 16.sp(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.h(context)),
                  Text(
                    'Une remarque ou une question sur ce projet ?',
                    style: context.normalTextStyle.copyWith(
                      fontSize: 13.sp(context),
                      color: context.textMuted,
                    ),
                  ),
                  SizedBox(height: 12.h(context)),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _ouvrirFormulaireAvis,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: context.primary,
                        side: BorderSide(color: context.primary),
                        padding: EdgeInsets.symmetric(
                          vertical: 14.h(context),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.w(context)),
                        ),
                      ),
                      icon: Icon(
                        Icons.edit_outlined,
                        size: 18.w(context),
                      ),
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

  Widget _construireContenuPitch() {
    switch (_type) {
      case PitchType.video:
        if (_erreurVideo || _videoController?.value.hasError == true) {
          return Stack(
            fit: StackFit.expand,
            children: [
              PitchCover(
                type: PitchType.video,
                thumbnailUrl: _miniatureUrl,
                showPlay: false,
              ),
              Container(
                color: Colors.black54,
                alignment: Alignment.center,
                padding: EdgeInsets.all(16.w(context)),
                child: Text(
                  'Impossible de charger la vidéo.',
                  textAlign: TextAlign.center,
                  style: context.normalTextStyle.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          );
        }

        if (_chewieController != null) {
          return Container(
            color: Colors.black,
            child: Chewie(controller: _chewieController!),
          );
        }

        if (_lectureDemandee) {
          return Stack(
            fit: StackFit.expand,
            children: [
              PitchCover(
                type: PitchType.video,
                thumbnailUrl: _miniatureUrl,
                showPlay: false,
                showTag: false,
              ),
              Container(
                color: Colors.black26,
                alignment: Alignment.center,
                child: CircularProgressIndicator(color: context.primary),
              ),
            ],
          );
        }

        return Stack(
          fit: StackFit.expand,
          children: [
            PitchCover(
              type: PitchType.video,
              thumbnailUrl: _miniatureUrl,
            ),
            Positioned.fill(
              child: Material(
                type: MaterialType.transparency,
                child: InkWell(onTap: _lancerVideo),
              ),
            ),
          ],
        );

      case PitchType.pdf:
        return Stack(
          fit: StackFit.expand,
          children: [
            PitchCover(
              type: PitchType.pdf,
              thumbnailUrl: _miniatureUrl,
            ),
            Positioned.fill(
              child: Material(
                type: MaterialType.transparency,
                child: InkWell(
                  onTap: _pdfEnCours ? null : _ouvrirPdf,
                ),
              ),
            ),
            Positioned(
              right: 12.w(context),
              bottom: 12.h(context),
              child: ElevatedButton.icon(
                onPressed: _pdfEnCours ? null : _ouvrirPdf,
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.primary,
                  foregroundColor: context.textInverse,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.w(context)),
                  ),
                ),
                icon: _pdfEnCours
                    ? SizedBox(
                        width: 18.w(context),
                        height: 18.h(context),
                        child: CircularProgressIndicator(
                          strokeWidth: 2.w(context),
                          color: context.textInverse,
                        ),
                      )
                    : Icon(
                        Icons.open_in_new_rounded,
                        size: 18.w(context),
                      ),
                label: Text(
                  _pdfEnCours ? 'Chargement...' : 'Ouvrir le PDF',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
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
        borderRadius: BorderRadius.circular(12.w(context)),
        border: Border.all(color: context.borderColor),
      ),
      alignment: Alignment.center,
      padding: EdgeInsets.all(16.w(context)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 40.w(context),
            color: action != null ? context.primary : context.textMuted,
          ),
          SizedBox(height: 8.h(context)),
          Text(
            message,
            textAlign: TextAlign.center,
            style: context.normalTextStyle.copyWith(
              fontSize: 14.sp(context),
              color: context.textMuted,
            ),
          ),
          if (action != null) ...[
            SizedBox(height: 12.h(context)),
            action,
          ],
        ],
      ),
    );
  }

  Widget _construireInfos(int nombreLikes) {
    final projet = widget.projet;

    return Container(
      decoration: BoxDecoration(
        color: context.background,
        borderRadius: BorderRadius.circular(12.w(context)),
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
          Divider(height: 1, color: context.borderColor),
          _ligneInfo(
            Icons.favorite_outline,
            'Nombre de likes',
            '$nombreLikes',
          ),
        ],
      ),
    );
  }

  Widget _ligneInfo(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 14.w(context),
        vertical: 13.h(context),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 19.w(context), color: context.primary),
          SizedBox(width: 10.w(context)),
          Text(
            label,
            style: context.normalTextStyle.copyWith(
              fontSize: 13.sp(context),
              color: context.textMuted,
            ),
          ),
          SizedBox(width: 12.w(context)),
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

  Widget _construireBarreContact() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16.w(context),
        12.h(context),
        16.w(context),
        12.h(context),
      ),
      decoration: BoxDecoration(
        color: context.background,
        border: Border(top: BorderSide(color: context.borderColor)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 48.h(context),
          child: ElevatedButton.icon(
            onPressed: _contactEnCours ? null : _contacterPorteur,
            style: ElevatedButton.styleFrom(
              backgroundColor: context.primaryOrange,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.w(context)),
              ),
            ),
            icon: Icon(Icons.chat_outlined, size: 20.w(context)),
            label: Text(
              'Contacter le porteur',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.sp(context),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AvisSheet extends StatefulWidget {
  const _AvisSheet({
    required this.titre,
    required this.onSubmit,
  });

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
    } catch (e) {
      debugPrint('Erreur d’envoi de l’avis : $e');

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
          borderRadius: BorderRadius.circular(10.w(context)),
          borderSide: BorderSide(color: color, width: width),
        );

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: context.background,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20.w(context)),
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            20.w(context),
            12.h(context),
            20.w(context),
            20.h(context),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.w(context),
                  height: 4.h(context),
                  decoration: BoxDecoration(
                    color: context.borderColor,
                    borderRadius: BorderRadius.circular(10.w(context)),
                  ),
                ),
              ),
              SizedBox(height: 16.h(context)),
              Text('Votre avis', style: context.headingTextStyle),
              SizedBox(height: 2.h(context)),
              Text(
                widget.titre,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.normalTextStyle.copyWith(
                  fontSize: 14.sp(context),
                  color: context.textMuted,
                ),
              ),
              SizedBox(height: 16.h(context)),
              TextField(
                controller: _controller,
                autofocus: true,
                enabled: !_envoiEnCours,
                minLines: 4,
                maxLines: 7,
                maxLength: 1500,
                textCapitalization: TextCapitalization.sentences,
                style: context.normalTextStyle.copyWith(
                  fontSize: 15.sp(context),
                ),
                onChanged: (_) {
                  if (_erreur != null) {
                    setState(() => _erreur = null);
                  }
                },
                decoration: InputDecoration(
                  hintText: 'Écrivez votre commentaire...',
                  hintStyle: context.normalTextStyle.copyWith(
                    fontSize: 14.sp(context),
                    color: context.textMuted,
                  ),
                  errorText: _erreur,
                  filled: true,
                  fillColor: context.bgColor,
                  contentPadding: EdgeInsets.all(14.w(context)),
                  border: border(context.borderColor),
                  enabledBorder: border(context.borderColor),
                  disabledBorder: border(context.borderColor),
                  focusedBorder: border(context.borderSelected, 1.5),
                  errorBorder: border(context.badgeRed),
                  focusedErrorBorder: border(context.badgeRed, 1.5),
                ),
              ),
              SizedBox(height: 12.h(context)),
              SizedBox(
                width: double.infinity,
                height: 48.h(context),
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
                      borderRadius: BorderRadius.circular(10.w(context)),
                    ),
                  ),
                  child: _envoiEnCours
                      ? SizedBox(
                          width: 20.w(context),
                          height: 20.h(context),
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Envoyer',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.sp(context),
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
