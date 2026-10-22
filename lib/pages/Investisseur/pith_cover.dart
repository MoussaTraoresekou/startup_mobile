import 'package:flutter/material.dart';
import 'package:startup_mobile/cor/theme/app_theme.dart';
import 'package:startup_mobile/pages/Investisseur/pitch_utils.dart';

/// Visuel d'un pitch. Remplit l'espace que lui donne le parent
/// (entourez-le d'un AspectRatio).
///
/// - Avec [thumbnailUrl] : affiche l'image, puis le bouton lecture si vidéo.
/// - Sans miniature : affiche un visuel dessiné (écran sombre pour une vidéo,
///   feuille de document pour un PDF), qui reste propre dans tous les cas.
class PitchCover extends StatelessWidget {
  const PitchCover({
    super.key,
    required this.type,
    this.thumbnailUrl,
    this.showPlay = true,
    this.showTag = true,
    this.child,
  });

  final PitchType type;
  final String? thumbnailUrl;

  /// Bouton lecture au centre (vidéos uniquement).
  final bool showPlay;

  /// Étiquette « Vidéo » / « PDF » en bas à gauche.
  final bool showTag;

  /// Éléments posés par-dessus (cœur, bouton, indicateur de chargement...).
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final url = thumbnailUrl?.trim() ?? '';
    final aUneMiniature = url.isNotEmpty;

    return Stack(
      fit: StackFit.expand,
      children: [
        if (aUneMiniature)
          Image.network(
            url,
            fit: BoxFit.cover,
            loadingBuilder: (context, enfant, progression) =>
                progression == null ? enfant : _fond(context),
            errorBuilder: (context, erreur, trace) => _fond(context),
          )
        else
          _fond(context),
        if (aUneMiniature)
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black26],
              ),
            ),
          ),
        if (type == PitchType.video && showPlay)
          Center(child: _boutonLecture()),
        if (showTag && type != PitchType.none)
          Positioned(left: 10, bottom: 10, child: _etiquette()),
        if (child != null) child!,
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // FONDS (quand il n'y a pas de miniature)
  // ---------------------------------------------------------------------------

  Widget _fond(BuildContext context) {
    switch (type) {
      case PitchType.video:
        return const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF374151), Color(0xFF111827)],
            ),
          ),
        );

      case PitchType.pdf:
        return Container(
          color: context.primarySoft,
          child: LayoutBuilder(
            builder: (context, box) => Center(
              child: _feuille(context, box.maxHeight * 0.62),
            ),
          ),
        );

      case PitchType.none:
        return Container(
          color: context.primarySoft,
          alignment: Alignment.center,
          child: Icon(
            Icons.slideshow_rounded,
            size: 40,
            color: context.primary.withValues(alpha: 0.6),
          ),
        );
    }
  }

  /// Petite feuille de document dessinée (titre + lignes de texte).
  Widget _feuille(BuildContext context, double hauteur) {
    final largeur = hauteur * 0.74;
    final marge = hauteur * 0.08;
    final largeurUtile = largeur - 2 * marge;
    final trait = context.textMuted.withValues(alpha: 0.28);

    return Container(
      width: largeur,
      height: hauteur,
      padding: EdgeInsets.all(marge),
      decoration: BoxDecoration(
        color: context.background,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: context.shadowColor,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: largeurUtile * 0.5,
            height: hauteur * 0.06,
            decoration: BoxDecoration(
              color: context.primary,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          SizedBox(height: hauteur * 0.07),
          for (final facteur in const [1.0, 0.9, 1.0, 0.7]) ...[
            Container(
              width: largeurUtile * facteur,
              height: hauteur * 0.035,
              decoration: BoxDecoration(
                color: trait,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: hauteur * 0.045),
          ],
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // ÉLÉMENTS PAR-DESSUS
  // ---------------------------------------------------------------------------

  Widget _boutonLecture() {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        shape: BoxShape.circle,
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: const Icon(
        Icons.play_arrow_rounded,
        size: 34,
        color: Color(0xFF1F2937),
      ),
    );
  }

  Widget _etiquette() {
    final estVideo = type == PitchType.video;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            estVideo ? Icons.videocam_rounded : Icons.picture_as_pdf_rounded,
            size: 13,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            estVideo ? 'Vidéo' : 'PDF',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}