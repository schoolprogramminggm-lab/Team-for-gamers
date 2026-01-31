import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors - Stitch design neon theme
  static const Color primary = Color(0xFF9d4edd); // Neon purple
  static const Color neonCyan = Color(0xFF00d9ff); // Neon cyan
  static const Color secondary = Color(0xFF00B894); // Success green
  
  // Background Colors - Dark theme from Stitch
  static const Color backgroundLight = Color(0xFFF5F6FA);
  static const Color backgroundDark = Color(0xFF1a1a2e); // Updated to Stitch dark
  
  // Surface Colors
  static const Color surfaceDark = Color(0xFF1A1A2E);
  static const Color surfaceLight = Colors.white;
  
  // Glassmorphism Colors
  static const Color glassBackground = Color(0x1AFFFFFF); // 10% white
  static const Color glassBorder = Color(0x33FFFFFF); // 20% white
  
  // Gradient Colors
  static const Color gradientPurple = Color(0xFF9d4edd);
  static const Color gradientCyan = Color(0xFF00d9ff);
  
  // Accent Colors
  static const Color accent = Color(0xFFFF6B9D); // Pink accent
  static const Color warning = Color(0xFFFDCB6E); // Yellow warning
  static const Color error = Color(0xFFFF6B6B); // Red error
  
  // Game Specific Colors
  static const Color dota2 = Color(0xFFB91E22);
  static const Color cs2 = Color(0xFFF39C12);
  static const Color valorant = Color(0xFFFF4655);
  
  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF); // White for dark theme
  static const Color textSecondary = Color(0xFFa0a0a0); // Gray secondary
  static const Color textLight = Color(0xFFB2BAC2);
  
  // Gradient definitions
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [gradientPurple, gradientCyan],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
