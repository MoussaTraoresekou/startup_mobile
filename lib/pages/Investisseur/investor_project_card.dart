import 'package:flutter/material.dart';
import 'package:startup_mobile/cor/theme/app_theme.dart';
import 'package:startup_mobile/cor/utils/size_config.dart';
import 'package:startup_mobile/models/ProjetModel .dart';
import 'package:startup_mobile/pages/Investisseur/pitch_utils.dart';
import 'package:startup_mobile/pages/Investisseur/pith_cover.dart';

class InvestorProjectCard extends StatelessWidget {
  const InvestorProjectCard({
    super.key,
    required this.project,
    required this.onTap,
    required this.isLiked,
    required this.onLikePressed,
    this.nombreLikes,
  });

  final ProjetModel project;
  final VoidCallback onTap;
  final bool isLiked;
  final VoidCallback onLikePressed;

  /// Nombre de likes actualisé transmis par la page parente.
  /// Si aucune valeur n'est fournie, on utilise celle du modèle.
  final int? nombreLikes;

  @override
  Widget build(BuildContext context) {
    final type = pitchTypeOf(project.pithUrl);
    final radius = BorderRadius.circular(14);

    final totalLikes = nombreLikes ?? project.nombreLikes;

    return Container(
      decoration: BoxDecoration(
        color: context.background,
        borderRadius: radius,
        border: Border.all(color: context.borderColor),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: PitchCover(
                  type: type,
                  child: Positioned(
                    top: 8,
                    right: 8,
                    child: _boutonCoeur(context),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.titre,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.titleTextStyle.copyWith(
                        fontSize: 17.sp(context),
                        fontWeight: FontWeight.bold,
                        height: 1.25,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      '${project.secteur} • ${project.porteurNomComplet}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.normalTextStyle.copyWith(
                        fontSize: 12.sp(context),
                        color: context.textMuted,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      project.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.normalTextStyle.copyWith(
                        fontSize: 13.sp(context),
                        height: 1.4,
                        color: context.textMuted,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Divider(
                      height: 1,
                      color: context.borderColor,
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Text(
                          'Quota proposé',
                          style: context.normalTextStyle.copyWith(
                            fontSize: 12.sp(context),
                            color: context.textMuted,
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: Text(
                            project.quotaPropose,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.end,
                            style: context.normalTextStyle.copyWith(
                              fontSize: 13.sp(context),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Icon(
                          Icons.favorite,
                          size: 16,
                          color: context.badgeRed,
                        ),

                        const SizedBox(width: 6),

                        Text(
                          '$totalLikes '
                          '${totalLikes > 1 ? 'likes' : 'like'}',
                          style: context.normalTextStyle.copyWith(
                            fontSize: 12.sp(context),
                            color: context.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _boutonCoeur(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.92),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onLikePressed,
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(
            isLiked ? Icons.favorite : Icons.favorite_border,
            size: 20,
            color: isLiked
                ? context.badgeRed
                : const Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }
}
