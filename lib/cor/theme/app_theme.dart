import 'package:flutter/material.dart';

extension AppStyles on BuildContext {
  bool get _isDark => Theme.of(this).brightness == Brightness.dark;

  // --background (#FFFBF5) & --dark (#1F2937)
  Color get bgColor =>
      _isDark ? const Color(0xFF1F2937) : const Color(0xFFFFFBF5);
      
  // --surface (#FFFFFF)
  Color get background =>
      _isDark ? const Color(0xFF111827) : const Color(0xFFFFFFFF);

  // --text-primary (#1F2937)
  Color get textDark =>
      _isDark ? const Color(0xFFF9FAFB) : const Color(0xFF1F2937);
      
  // --text-secondary (#6B7280)
  Color get textMuted =>
      _isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);
      
  Color get textInverse => _isDark ? const Color(0xFF1F2937) : Colors.white;

  // --primary (#059669) & --primary-dark (#047857)
  Color get primary =>
      _isDark ? const Color(0xFF34D399) : const Color(0xFF059669);
      
  // --primary-light (#D1FAE5)
  Color get primarySoft =>
      _isDark ? const Color(0xFF064E3B) : const Color(0xFFD1FAE5);
      
  Color get navbarColor =>
      _isDark ? const Color(0xFF064E3B) : const Color(0xFF059669);

  // --secondary (#E67E22)
  Color get primaryOrange => const Color(0xFFE67E22);
  Color get accentBlue => const Color(0xFF0066CC);
  
  // --error (red)
  Color get badgeRed => Colors.red;

  Color get boxSurfaceLight =>
      _isDark ? const Color(0xFF374151) : const Color(0xFFD1FAE5);
      
  // --secondary-light (#FEF0CD) & --secondary-dark (#92610A)
  Color get cardMenuYellow =>
      _isDark ? const Color(0xFF92610A) : const Color(0xFFFEF0CD);
      
  Color get avatarOrangeBg =>
      _isDark ? const Color(0xFF92610A) : const Color(0xFFFEF0CD);

  // --success (#059669)
  Color get successGreen => const Color(0xFF059669);

  Color get iconColor =>
      _isDark ? const Color(0xFF9CA3AF) : const Color(0xFF047857);

  // --border (#E7DFCE)
  Color get borderColor =>
      _isDark ? const Color(0xFF4B5563) : const Color(0xFFE7DFCE);
      
  Color get borderSelected =>
      _isDark ? const Color(0xFF34D399) : const Color(0xFF059669);

  Color get shadowColor => _isDark
      ? Colors.white.withValues(alpha: 0.05)
      : Colors.black.withValues(alpha: 0.12);

  TextStyle get headingTextStyle => TextStyle(
    fontSize: 20,
    color: textDark,
    fontWeight: FontWeight.bold,
    fontFamily: 'Inter', // Aligné sur votre CSS global
  );

  TextStyle get titleTextStyle => TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    fontFamily: 'Inter',
    color: textDark,
  );

  TextStyle get normalTextStyle => TextStyle(
    fontSize: 18,
    color: textDark,
    fontWeight: FontWeight.w400,
    fontFamily: 'Inter',
  );
}
