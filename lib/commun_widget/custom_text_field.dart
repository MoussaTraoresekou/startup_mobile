import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:startup_mobile/cor/theme/app_theme.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    required this.label,
    required this.hintText,
    required this.controller,
    this.isPassword = false,
    this.prefixIcon,
    this.prefixIconColor,
    this.suffixIcon,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.maxLines = 1,
  });

  final String label;
  final String hintText;
  final TextEditingController controller;
  final bool isPassword;

  final IconData? prefixIcon;
  final Color? prefixIconColor;

  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Libellé au-dessus du champ (mat-label)
        Text(
          label,
          style: context.normalTextStyle.copyWith(
            fontWeight: FontWeight.bold,
            color: context.textDark,
            fontSize: 14,
          ),
        ),

        const SizedBox(height: 6),

        TextFormField(
          controller: controller,
          obscureText: isPassword,
          validator: validator,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          maxLines: isPassword ? 1 : maxLines,
          style: context.normalTextStyle.copyWith(color: context.textDark, fontSize: 15),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: context.normalTextStyle.copyWith(
              color: context.textMuted,
              fontSize: 14,
            ),

            // Icône de préfixe (matPrefix)
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: prefixIconColor ?? context.iconColor)
                : null,

            // Bouton de visibilité ou autre (matSuffix)
            suffixIcon: suffixIcon,

            filled: true,
            fillColor: context.background, // Blanc pur ou gris de surface

            contentPadding: const EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 16,
            ),

            // Bordure par défaut
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: context.borderColor, width: 1),
            ),

            // Bordure quand le champ est inactif
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: context.borderColor, width: 1),
            ),

            // Bordure quand le champ a le focus
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: context.borderSelected, width: 1.5),
            ),

            // Bordure en cas d'erreur de validation (mat-error)
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: context.badgeRed, width: 1),
            ),
            
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: context.badgeRed, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
