import 'package:flutter/material.dart';
import 'package:startup_mobile/cor/theme/app_theme.dart';
import 'package:startup_mobile/cor/utils/size_config.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: context.primaryOrange,
          foregroundColor: context.textInverse,
          disabledBackgroundColor: context.primaryOrange.withValues(alpha: 0.6),
          padding: EdgeInsets.symmetric(
            vertical: 16.h(context), // Remplace le getProportionateHeight obsolète
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Aligné sur le --radius-md de votre CSS
          ),
          elevation: 0,
        ),
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: context.textInverse,
                  strokeWidth: 2,
                ),
              )
            : Text(
                label,
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
