import 'package:flutter/material.dart';

// ==================== LIGHT MODE COLORS ====================
class _AppColorsLight {
  static const background = Color(0xFFFAFAFA);
  static const primary = Color(0xFF2C3E50);
  static const accent = Color(0xFF2C3E50);
  static const card = Color(0xFFFFFFFF);
  static const border = Color(0xFFEDEFF3);
  static const textMuted = Color(0xFF94A3B8);
  static const shadow = Color(0x0A000000); // black 4%
}

// ==================== DARK MODE COLORS ====================
// ==================== DARK MODE (Lighter / Friendly) ====================
class _AppColorsDark {
  static const background = Color(0xFF222C3B);
  static const card = Color(0xFF2D3A4D);
  static const border = Color(0xFF425671);

  static const primary = Color(0xFFF7FAFF);
  static const textMuted = Color(0xFFD0DAEC);

  static const accent = Color(0xFF9ABEFF);
  static const shadow = Color(0x16000000);
}

class AppColors {
  // ==================== Dialog Tokens (Stone / Enterprise) ====================
  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  /// Dialog surface/card
  static Color getDialogCard(BuildContext context) =>
      isDark(context) ? _AppColorsDark.card : _AppColorsLight.card;

  /// Border around dialog
  static Color getDialogBorder(BuildContext context) =>
      isDark(context) ? _AppColorsDark.border : _AppColorsLight.border;

  /// Dialog title/body text
  static Color getDialogTitleText(BuildContext context) =>
      isDark(context) ? _AppColorsDark.primary : _AppColorsLight.primary;

  static Color getDialogBodyText(BuildContext context) => isDark(context)
      ? _AppColorsDark.textMuted
      : const Color(0xFF475569); // slate-ish

  static Color getDialogMutedText(BuildContext context) =>
      isDark(context) ? const Color(0xFFAAB6CC) : _AppColorsLight.textMuted;

  /// Background inside dialog content area (message box / inner area)
  static Color getDialogBodyBg(BuildContext context) =>
      isDark(context) ? const Color(0xFF273244) : const Color(0xFFF3F4F6);

  /// Barrier (overlay behind dialog)
  static Color getDialogBarrier(BuildContext context) =>
      isDark(context) ? const Color(0xB3000000) : const Color(0x80000000);

  /// Accent used inside dialog (buttons/links)
  static Color getDialogAccent(BuildContext context) =>
      isDark(context) ? _AppColorsDark.accent : _AppColorsLight.accent;

  static Color getDialogAccentOn(BuildContext context) =>
      isDark(context) ? const Color(0xFF0F172A) : Colors.white;
  static Color getTextTitle(BuildContext context) =>
      isDark(context) ? AppColors.white : AppColors.black;

  /// Soft severity colors (not neon)
  /// Soft severity colors (not neon)
  static Color getDialogDanger(BuildContext context) =>
      isDark(context) ? AppColors.danger600 : AppColors.danger;

  static Color getDialogWarning(BuildContext context) =>
      isDark(context) ? AppColors.warning300 : AppColors.warning;

  // Get colors based on brightness
  static Color getBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? _AppColorsDark.background
        : _AppColorsLight.background;
  }

  static Color getPrimary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? _AppColorsDark.primary
        : _AppColorsLight.primary;
  }

  static Color getAccent(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? _AppColorsDark.accent
        : _AppColorsLight.accent;
  }

  static Color getCard(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? _AppColorsDark.card
        : _AppColorsLight.card;
  }

  static Color getBorder(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? _AppColorsDark.border
        : _AppColorsLight.border;
  }

  static Color getTextMuted(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? _AppColorsDark.textMuted
        : _AppColorsLight.textMuted;
  }

  static Color getShadow(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? _AppColorsDark.shadow
        : _AppColorsLight.shadow;
  }

  /// ✅ for SVG logo tint
  static ColorFilter? logoColorFilter(BuildContext context) {
    if (Theme.of(context).brightness != Brightness.dark) return null;
    return const ColorFilter.mode(
      Color(0xFFF7F9FF),
      BlendMode.srcIn,
    ); // white-ish
  }

  /// ✅ simple lighten/darken helper (amount: -1..1)
  static Color tint(Color c, double amount) {
    final hsl = HSLColor.fromColor(c);
    final l = (hsl.lightness + amount).clamp(0.0, 1.0);
    return hsl.withLightness(l).toColor();
  }

  // Static references for static contexts (no BuildContext available)
  static const background = Color(0xFFFAFAFA);
  static const primary = Color(0xFF2C3E50);
  static const accent = Color(0xFFE67E22);
  static const card = Color(0xFFFFFFFF);
  static const border = Color(0xFFEDEFF3);
  static const textMuted = Color(0xFF94A3B8);
  static Color shadow = Colors.black.withValues(alpha: 0.04);

  // Main Aman App Colors - Blue theme
  // static const Color primary = Color(0xFF2196F3); // Main blue
  static const Color secondary = Color(0xFF1976D2); // Darker blue for secondary
  static const Color secoundPrimary = Color(0xFF1976D2); // Darker blue
  // static const Color accent = Color(0xFF64B5F6); // Light blue
  static const Color appBackground = Color(
    0xFFE3F2FD,
  ); // Very light blue background

  // Neutral colors
  static const Color neutral = Color(0xff808080);
  static const Color appWhite = Color(0xFFFFFFFF);
  static const Color appBlack = Color(0xFF000000);
  static const Color grey = Color(0xFF9E9E9E);
  static const Color lightGrey = Color(0xFFE0E0E0);

  // Status colors
  static const Color success = Color(0xff28A745);
  static const Color danger = Color(0xFFD32F2F);
  static const Color warning = Color(0xffFFCC65);
  static const Color info = Color(0xff42A5F5);

  // Card colors inspired by FIB app
  static const Color cardBlue = Color(0xFF2196F3);
  static const Color cardOrange = Color(0xffFFCC65);
  static const Color cardPurple = Color(0xFF9C27B0);
  static const Color cardGreen = Color(0xFF4CAF50);
  static const Color cardRed = Color(0xFFE91E63);

  // Blue scale for primary
  static const Color primary25 = Color(0xFFE3F2FD);
  static const Color primary50 = Color(0xFFBBDEFB);
  static const Color primary100 = Color(0xFF90CAF9);
  static const Color primary200 = Color(0xFF64B5F6);
  static const Color primary300 = Color(0xFF42A5F5);
  static const Color primary400 = Color(0xFF2196F3);
  static const Color primary500 = Color(0xFF2196F3);
  static const Color primary600 = Color(0xFF1E88E5);
  static const Color primary700 = Color(0xFF1976D2);
  static const Color primary800 = Color(0xFF1565C0);
  static const Color primary900 = Color(0xFF0D47A1);

  static const Color neutral25 = Color(0xffFAFAFA);
  static const Color neutral50 = Color(0xffF2F2F2);
  static const Color neutral100 = Color(0xffE8E8E8);
  static const Color neutral200 = Color(0xffD9D9D9);
  static const Color neutral300 = Color(0xffC2C2C2);
  static const Color neutral400 = Color(0xffA3A3A3);
  static const Color neutral600 = Color(0xff666666);
  static const Color neutral700 = Color(0xff4D4D4D);
  static const Color neutral800 = Color(0xff333333);
  static const Color neutral900 = Color(0xff1A1A1A);

  static const Color success25 = Color(0xffF7FBF8);
  static const Color success50 = Color(0xffEAF4EE);
  static const Color success100 = Color(0xffD0F1D4);
  static const Color success200 = Color(0xffC1ECC0);
  static const Color success300 = Color(0xff9CE7AD);
  static const Color success400 = Color(0xff88DC95);
  static const Color success600 = Color(0xff20A45B);
  static const Color success700 = Color(0xff1B8532);
  static const Color success800 = Color(0xff0C731A);
  static const Color success900 = Color(0xff095109);

  static const Color danger25 = Color(0xffFDF7F7);
  static const Color danger50 = Color(0xffFBEAEA);
  static const Color danger100 = Color(0xffF6D0D0);
  static const Color danger200 = Color(0xffF2C4C4);
  static const Color danger300 = Color(0xffF1A5A8);
  static const Color danger400 = Color(0xffDF7577);
  static const Color danger600 = Color(0xffB02727);
  static const Color danger700 = Color(0xff971C1C);
  static const Color danger800 = Color(0xff630D0D);
  static const Color danger900 = Color(0xff3F0004);

  static const Color warning25 = Color(0xffFFF9F2);
  static const Color warning50 = Color(0xffFFF3E0);
  static const Color warning100 = Color(0xffFFE8BD);
  static const Color warning200 = Color(0xffFFD892);
  static const Color warning300 = Color(0xffFFCC65);
  static const Color warning400 = Color(0xffFFB547);
  static const Color warning600 = Color(0xffBA6700);
  static const Color warning700 = Color(0xff7A4600);
  static const Color warning800 = Color(0xff432400);
  static const Color warning900 = Color(0xff1A0F00);

  static const Color info25 = Color(0xffF5FAFF);
  static const Color info50 = Color(0xffF2F7FF);
  static const Color info100 = Color(0xffDDEFFD);
  static const Color info200 = Color(0xffBDDCFB);
  static const Color info300 = Color(0xffB3DCFB);
  static const Color info400 = Color(0xff84B8F7);
  static const Color info600 = Color(0xff0175CE);
  static const Color info700 = Color(0xff00437A);
  static const Color info800 = Color(0xff03223A);
  static const Color info900 = Color(0xff01111B);

  // light Theme Colors
  static Color lightPrimaryColor = const Color(0xffF2F1F6);
  static Color lightSecondaryColor = const Color(0xffFFFFFF);
  static Color lightAccentColor = const Color(0xff0277FA);
  static Color lightSubHeadingColor1 = const Color(0xff343F53);
  // static Color background = const Color(0xFFe8e8e8);
  static Color lighterBackground = const Color(0xFFF1F1F1);
  static Color evenLighterBackground = const Color(0xFFF8F8F8);
  // dark theme color
  static Color darkPrimaryColor = const Color(0xff1E1E2C);
  static Color darkSecondaryColor = const Color(0xff2A2C3E);
  static Color darkAccentColor = const Color(0xff56A4FB);
  static Color darkSubHeadingColor1 = const Color(0xDDF2F1F6);

  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black1c = Color(0xFF1C1C1C);
  static const Color black28 = Color(0xFF282828);
  static const Color black23 = Color(0xFF232323);
  static const Color black14 = Color(0xFF141414);
  static const Color grey9A = Color(0xFF9A9A9A);
  static const Color greyDD = Color(0xFFDDE2E4);
  static const Color grey7F = Color(0xFF7F7F7F);
  static const Color grey9D = Color(0xFFD9D9D9);
  static const Color greyA4 = Color(0xFFA4A4A4);
  static const Color blueFace = Color(0xFF3D5A98);
  static const Color grey89 = Color(0xFF898989);
  static const Color grey8E = Color(0xFF8E8E8E);
  static const Color yellow = Color(0xFFFFD500);
  static const Color grey3B = Color(0xFF3B3B3B);
  static const Color whiteF1 = Color(0xFFF1F1F1);
  static const Color whiteF0 = Color(0xFFF0F0F0);
  static const Color grey72 = Color(0xFF727272);
  static const Color orange = Color(0xFFEC8600);
  static const Color grey3C = Color(0xFF3C3C3C);
  static const Color lightPrimary = Color(0xFF58BA6A);
  static const Color lightOrange = Color(0xFFF4A738);
  static const Color lightRed = Color(0xFFD20808);
  static const Color greyE5 = Color(0xFFE5E5E5);
  static const Color whiteF3 = Color(0xFFF3F3F3);
  static const Color lightXPrimary = Color(0xFFE8FFD0);
  static const Color green = Color(0xFF00B207);
  static const Color lightGreen = Color(0xFF5DFF43);
  static const Color lightYellow = Color(0xFFFFF853);
  static const Color lightXOrange = Color(0xFFE55725);
  static const Color primary7F = Color(0xFF7FFF7C);
  static const Color greyC1 = Color(0xFFC1C1C1);
  static const Color red = Color(0xFFB22222);
  static const Color green32 = Color(0xFF32CD32);
  static const Color greyA9 = Color(0xFFA9A9A9);
  static const Color babyBlue = Color(0xFF87CEEB);
  static const Color greyAD = Color(0xFFADADB4);
}
