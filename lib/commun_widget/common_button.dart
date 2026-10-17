import 'package:flutter/material.dart';
import 'package:startup_mobile/cor/theme/app_theme.dart';
import 'package:startup_mobile/cor/utils/size_config.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.onTap,
    required this.title,
    required this.isLoading,
  });

  final VoidCallback onTap;
  final String title;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isLoading ? null : onTap,
      borderRadius: BorderRadius.circular(10), // Coins arrondis conformes au Figma
      child: Container(
        alignment: Alignment.center,
        height: 48.h(context), // Hauteur proportionnelle et responsive de 48px
        width: double.infinity,
        decoration: BoxDecoration(
          color: isLoading
              ? context.primaryOrange.withValues(alpha: 0.7)
              : context.primaryOrange,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: context.shadowColor,
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: context.textInverse,
                  strokeWidth: 2,
                ),
              )
            : Text(
                title,
                style: context.titleTextStyle.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
      ),
    );
  }
}
