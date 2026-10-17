import 'package:flutter/material.dart';
import 'package:startup_mobile/cor/theme/app_theme.dart';

class CommonContainer extends StatelessWidget {
  const CommonContainer({
    super.key, 
    required this.onTap, 
    required this.text,
  });

  final VoidCallback onTap;
  final String text;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10), // Arrondi de 10 conforme à votre Figma
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        width: double.infinity, // Prend toute la largeur disponible de manière responsive
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: context.borderColor, // Bordure douce calibrée sur votre charte CSS
            width: 1,
            style: BorderStyle.solid,
          ),
        ),
        child: Text(
          text,
          style: context.normalTextStyle.copyWith(
            color: context.textDark,
            fontWeight: FontWeight.w500,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}
