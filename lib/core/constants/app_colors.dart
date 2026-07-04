import 'package:flutter/material.dart';

/// Pastel color palette for the noted! app.
/// Card text MUST use the dark variant of the same hue — never Color(0xFF000000).
class AppColors {
  AppColors._();

  // ── App background ──────────────────────────────────────────────────────────
  static const Color background = Color(0xFFF5F3EE); // warm off-white
  
  // ── Primary Theme Colors ────────────────────────────────────────────────────
  static const Color primary = Color(0xFFE4A038);
  static const Color primaryLight = Color(0xFFF1E2A7);

  // ── Card backgrounds ─────────────────────────────────────────────────────────
  static const Color cardBlue  = Color(0xFFC8D8E8);
  static const Color cardGreen = Color(0xFFD4E8C2);
  static const Color cardAmber = Color(0xFFE8D8C0);
  static const Color cardMauve = Color(0xFFE0C8D8);
  static const Color cardCream = Color(0xFFE8E0C0);

  // ── Text on each card — always dark variant of same hue, NEVER black ─────────
  static const Color textBlue  = Color(0xFF2A4A60);
  static const Color textGreen = Color(0xFF2A4A20);
  static const Color textAmber = Color(0xFF5A3A10);
  static const Color textMauve = Color(0xFF5A2040);
  static const Color textCream = Color(0xFF5A4010);

  // ── FAB / button on card — mid-tone of same hue ───────────────────────────
  static const Color fabBlue  = Color(0xFFA8C0D4);
  static const Color fabGreen = Color(0xFFB8D4A0);
  static const Color fabAmber = Color(0xFFD4C0A0);
  static const Color fabMauve = Color(0xFFCCACC0);
  static const Color fabCream = Color(0xFFD4CC9C);

  // ── General UI ────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF2A2A2A);
  static const Color textMuted   = Color(0xFF999999);
  static const Color divider     = Color(0xFFDDDDDD);

  // ── Dark mode card backgrounds (~30% darker, same hue) ────────────────────
  static const Color cardBlueDark  = Color(0xFF8FA8BC);
  static const Color cardGreenDark = Color(0xFF9AB487);
  static const Color cardAmberDark = Color(0xFFB4A484);
  static const Color cardMauveDark = Color(0xFFA88EA0);
  static const Color cardCreamDark = Color(0xFFB4AC84);

  // ── Dark mode text (same as light mode — they're already dark enough) ─────
  static const Color darkBackground = Color(0xFF1E1C18);
  static const Color darkSurface    = Color(0xFF2A2820);

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Returns the card background color for a given color key.
  static Color cardBgFromKey(String key, {bool dark = false}) {
    if (dark) {
      switch (key) {
        case 'blue':  return cardBlueDark;
        case 'green': return cardGreenDark;
        case 'amber': return cardAmberDark;
        case 'mauve': return cardMauveDark;
        case 'cream': return cardCreamDark;
        default:      return cardBlueDark;
      }
    }
    switch (key) {
      case 'blue':  return cardBlue;
      case 'green': return cardGreen;
      case 'amber': return cardAmber;
      case 'mauve': return cardMauve;
      case 'cream': return cardCream;
      default:      return cardBlue;
    }
  }

  /// Returns the card text color for a given color key.
  static Color cardTextFromKey(String key) {
    switch (key) {
      case 'blue':  return textBlue;
      case 'green': return textGreen;
      case 'amber': return textAmber;
      case 'mauve': return textMauve;
      case 'cream': return textCream;
      default:      return textBlue;
    }
  }

  /// Returns the FAB/button color for a given color key.
  static Color fabColorFromKey(String key) {
    switch (key) {
      case 'blue':  return fabBlue;
      case 'green': return fabGreen;
      case 'amber': return fabAmber;
      case 'mauve': return fabMauve;
      case 'cream': return fabCream;
      default:      return fabBlue;
    }
  }

  /// Returns all available card color keys.
  static const List<String> colorKeys = ['blue', 'green', 'amber', 'mauve', 'cream'];

  /// Returns a human-readable label for a color key.
  static String colorLabel(String key) {
    switch (key) {
      case 'blue':  return 'Blue';
      case 'green': return 'Green';
      case 'amber': return 'Amber';
      case 'mauve': return 'Mauve';
      case 'cream': return 'Cream';
      default:      return 'Blue';
    }
  }
}
