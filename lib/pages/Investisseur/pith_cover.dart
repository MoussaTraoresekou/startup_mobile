
import 'package:flutter/material.dart';
import 'package:startup_mobile/cor/theme/app_theme.dart';
import 'package:startup_mobile/cor/utils/size_config.dart';
import 'package:startup_mobile/pages/Investisseur/pitch_utils.dart';
import 'package:startup_mobile/pages/pith_thumnail/pitch_thumbnail.dart';

/// Visuel d'un pitch.
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
  final bool showPlay;
  final bool showTag;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final url = thumbnailUrl?.trim() ?? '';
    final aUneMiniature = url.isNotEmpty;

    return Stack(
      fit: StackFit.expand,
      children: [
        if (aUneMiniature)
          PitchThumbnail(
            thumbnailUrl: url,
            fallback: _fond(context),
          )
        else
          _fond(context),

        if (aUneMiniature)
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black26,
                ],
              ),
            ),
          ),

        if (type == PitchType.video && showPlay)
          Center(child: _boutonLecture(context)),

        if (showTag && type != PitchType.none)
          Positioned(
            left: 10.w(context),
            bottom: 10.h(context),
            child: _etiquette(context),
          ),

        if (child != null) child!,
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // FONDS DE REMPLACEMENT
  // ---------------------------------------------------------------------------

  Widget _fond(BuildContext context) {
    switch (type) {
      case PitchType.video:
        return const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF374151),
                Color(0xFF111827),
              ],
            ),
          ),
        );

      case PitchType.pdf:
        return Container(
          color: context.primarySoft,
          child: LayoutBuilder(
            builder: (context, box) {
              return Center(
                child: _feuille(
                  context,
                  box.maxHeight * 0.62,
                ),
              );
            },
          ),
        );

      case PitchType.none:
        return Container(
          color: context.primarySoft,
          alignment: Alignment.center,
          child: Icon(
            Icons.slideshow_rounded,
            size: 40.w(context),
            color: context.primary.withValues(alpha: 0.6),
          ),
        );
    }
  }

  /// Petite feuille de document dessinée.
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
        borderRadius: BorderRadius.circular(6.w(context)),
        boxShadow: [
          BoxShadow(
            color: context.shadowColor,
            blurRadius: 10.w(context),
            offset: Offset(0, 4.h(context)),
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
              borderRadius: BorderRadius.circular(3.w(context)),
            ),
          ),
          SizedBox(height: hauteur * 0.07),
          for (final facteur in const [1.0, 0.9, 1.0, 0.7]) ...[
            Container(
              width: largeurUtile * facteur,
              height: hauteur * 0.035,
              decoration: BoxDecoration(
                color: trait,
                borderRadius: BorderRadius.circular(2.w(context)),
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

  Widget _boutonLecture(BuildContext context) {
    return Container(
      width: 54.w(context),
      height: 54.h(context),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10.w(context),
            offset: Offset(0, 3.h(context)),
          ),
        ],
      ),
      child: Icon(
        Icons.play_arrow_rounded,
        size: 34.w(context),
        color: const Color(0xFF1F2937),
      ),
    );
  }

  Widget _etiquette(BuildContext context) {
    final estVideo = type == PitchType.video;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 8.w(context),
        vertical: 4.h(context),
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(6.w(context)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            estVideo
                ? Icons.videocam_rounded
                : Icons.picture_as_pdf_rounded,
            size: 13.w(context),
            color: Colors.white,
          ),
          SizedBox(width: 4.w(context)),
          Text(
            estVideo ? 'Vidéo' : 'PDF',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11.sp(context),
              fontWeight: FontWeight.w700,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }
}
