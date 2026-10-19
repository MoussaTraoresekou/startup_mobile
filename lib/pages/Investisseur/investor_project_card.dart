
import 'package:flutter/material.dart';
import 'package:startup_mobile/cor/theme/app_theme.dart';
import 'package:startup_mobile/cor/utils/size_config.dart';
import 'package:startup_mobile/models/ProjetModel .dart';

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

  bool get _estVideo {
    final url = project.pithUrl.toLowerCase().split('?').first;
    return url.endsWith('.mp4');
  }

  @override
  Widget build(BuildContext context) {
    final estVideo = _estVideo;

    return Material(
      color: context.background,
      borderRadius: BorderRadius.circular(16.w(context)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.w(context)),
        child: Container(
          height: 164.h(context),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.w(context)),
            border: Border.all(color: context.borderColor),
            boxShadow: [
              BoxShadow(
                color: context.shadowColor.withValues(alpha: 0.06),
                blurRadius: 8.w(context),
                offset: Offset(0, 3.h(context)),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 105.w(context),
                decoration: BoxDecoration(
                  color: context.primarySoft,
                  borderRadius: BorderRadius.horizontal(
                    left: Radius.circular(15.w(context)),
                  ),
                ),
                child: Center(
                  child: Container(
                    width: 58.w(context),
                    height: 58.w(context),
                    decoration: BoxDecoration(
                      color: context.background,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: context.shadowColor.withValues(alpha: 0.08),
                          blurRadius: 10.w(context),
                          offset: Offset(0, 3.h(context)),
                        ),
                      ],
                    ),
                    child: Icon(
                      estVideo
                          ? Icons.play_circle_fill_rounded
                          : Icons.picture_as_pdf_rounded,
                      size: 36.w(context),
                      color: context.primary,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    12.w(context),
                    10.h(context),
                    8.w(context),
                    10.h(context),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              project.titre,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.titleTextStyle.copyWith(
                                fontSize: 15.w(context),
                                fontWeight: FontWeight.bold,
                                color: context.textDark,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 32.w(context),
                            height: 32.h(context),
                            child: IconButton(
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                              onPressed: onLikePressed,
                              icon: Icon(
                                isLiked
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                size: 21.w(context),
                                color: isLiked
                                    ? Colors.red
                                    : context.textMuted,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 2.h(context)),
                      Text(
                        '${project.secteur} • ${project.porteurNomComplet}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.normalTextStyle.copyWith(
                          fontSize: 11.w(context),
                          color: context.textMuted,
                        ),
                      ),
                      SizedBox(height: 7.h(context)),
                      Expanded(
                        child: Text(
                          project.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: context.normalTextStyle.copyWith(
                            fontSize: 12.w(context),
                            height: 1.35,
                            color: context.textMuted,
                          ),
                        ),
                      ),
                      SizedBox(height: 5.h(context)),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              project.quotaPropose,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.normalTextStyle.copyWith(
                                fontSize: 12.w(context),
                                fontWeight: FontWeight.bold,
                                color: context.primaryOrange,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 13.w(context),
                            color: context.primary,
                          ),
                        ],
                      ),
                    ],
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