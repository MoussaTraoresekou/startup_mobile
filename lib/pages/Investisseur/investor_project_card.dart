import 'package:flutter/material.dart';
import 'package:startup_mobile/cor/theme/app_theme.dart';
import 'package:startup_mobile/cor/utils/size_config.dart';
import 'package:startup_mobile/models/ProjetModel .dart';
import 'package:startup_mobile/pages/Investisseur/pitch_utils.dart';

class InvestorProjectCard extends StatelessWidget {
  const InvestorProjectCard({
    super.key,
    required this.project,
    required this.onTap,
    required this.isLiked,
    required this.onLikePressed,
  });

  final ProjetModel project;
  final VoidCallback onTap;
  final bool isLiked;
  final VoidCallback onLikePressed;

  @override
  Widget build(BuildContext context) {
    final estVideo = pitchTypeOf(project.pithUrl) == PitchType.video;

    return Material(
      color: context.background,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: context.primarySoft,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      estVideo
                          ? Icons.play_circle_outline_rounded
                          : Icons.picture_as_pdf_outlined,
                      color: context.primary,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          project.titre,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.titleTextStyle.copyWith(
                            fontSize: 16.sp(context),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${project.secteur} • ${project.porteurNomComplet}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.normalTextStyle.copyWith(
                            fontSize: 12.sp(context),
                            color: context.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: onLikePressed,
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
                    ),
                    icon: Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      color: isLiked ? context.badgeRed : context.textMuted,
                      size: 22,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
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
              Divider(height: 1, color: context.borderColor),
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
            ],
          ),
        ),
      ),
    );
  }
}