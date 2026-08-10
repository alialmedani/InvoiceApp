import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// App design system for the shadcn_ui redesign: a clean, compact "neutral +
/// single accent" look. Neutral grays for surfaces/borders, one brand accent
/// (teal) for primary actions, focus rings, and highlights.
const Color kShadAccent = Color(0xFF0D9488); // teal-600
const Color kShadAccentForeground = Color(0xFFFFFFFF);

ShadThemeData buildAppShadTheme(Brightness brightness) {
  final scheme = brightness == Brightness.dark
      ? ShadNeutralColorScheme.dark(
          primary: kShadAccent,
          primaryForeground: kShadAccentForeground,
          ring: kShadAccent,
        )
      : ShadNeutralColorScheme.light(
          primary: kShadAccent,
          primaryForeground: kShadAccentForeground,
          ring: kShadAccent,
        );

  return ShadThemeData(
    brightness: brightness,
    colorScheme: scheme,
  );
}
