import 'package:flutter/material.dart';
import 'package:startup_mobile/cor/theme/app_theme.dart';

class CustomDropdown<T> extends StatelessWidget {
  const CustomDropdown({
    super.key,
    required this.label,
    required this.hintText,
    required this.value,
    required this.items,
    required this.onChanged,
    this.prefixIcon,
    this.prefixIconColor,
    this.validator,
  });

  final String label;
  final String hintText;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?)? onChanged;

  final IconData? prefixIcon;
  final Color? prefixIconColor;
  final String? Function(T?)? validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Libellé au-dessus du menu (mat-label)
        Text(
          label,
          style: context.normalTextStyle.copyWith(
            fontWeight: FontWeight.bold,
            color: context.textDark,
            fontSize: 14,
          ),
        ),

        const SizedBox(height: 6),

        DropdownButtonFormField<T>(
          value: value,
          items: items,
          onChanged: onChanged,
          validator: validator,
          isExpanded: true,
          style: context.normalTextStyle.copyWith(color: context.textDark, fontSize: 15),
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: context.iconColor),
          dropdownColor: context.background, // S'adapte au thème clair/sombre
          borderRadius: BorderRadius.circular(10),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: context.normalTextStyle.copyWith(
              color: context.textMuted,
              fontSize: 14,
            ),

            // Icône de préfixe facultative
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: prefixIconColor ?? context.iconColor)
                : null,

            filled: true,
            fillColor: context.background,

            contentPadding: const EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 16,
            ),

            // Bordure par défaut
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: context.borderColor, width: 1),
            ),

            // Bordure inactive
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: context.borderColor, width: 1),
            ),

            // Bordure active avec focus
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: context.borderSelected, width: 1.5),
            ),

            // Bordure en cas d'erreur de saisie
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
