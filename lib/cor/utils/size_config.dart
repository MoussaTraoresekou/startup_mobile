import 'package:flutter/material.dart';

/// 1. La classe qui contient la logique de calcul basée sur Figma (375x812)
class SizeConfig {
  static const double _figmaHeight = 812.0;
  static const double _figmaWidth = 375.0;

  static double h(double inputHeight, BuildContext context) {
    double screenHeight = MediaQuery.sizeOf(context).height;
    return (inputHeight / _figmaHeight) * screenHeight;
  }

  static double w(double inputWidth, BuildContext context) {
    double screenWidth = MediaQuery.sizeOf(context).width;
    return (inputWidth / _figmaWidth) * screenWidth;
  }
}

/// 2. L'extension magique pour écrire votre code plus rapidement
extension SizeConfigExtension on num {
  /// Raccourci pour la hauteur responsive. Exemple : `20.h(context)`
  double h(BuildContext context) => SizeConfig.h(this.toDouble(), context);

  /// Raccourci pour la largeur responsive. Exemple : `15.w(context)`
  double w(BuildContext context) => SizeConfig.w(this.toDouble(), context);
}
extension SpExtension on num {
  /// Taille de texte responsive, limitée à ±20 % pour éviter
  /// un texte trop petit ou trop grand selon l'écran.
  /// Exemple : `14.sp(context)`
  double sp(BuildContext context) => SizeConfig.w(toDouble(), context)
      .clamp(toDouble() * 0.9, toDouble() * 1.2)
      .toDouble();
}
