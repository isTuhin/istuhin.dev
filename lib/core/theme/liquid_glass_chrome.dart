import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:material_ui/material_ui.dart' show Color;

/// Liquid-glass chrome recipes.
///
/// Light: milky iOS 27 glass.
/// Dark: frosted dark obsidian glass with optical blur & crisp specular rim
/// so underlying page chips/text never bleed unreadably through the floating
/// bottom navigation capsule.
abstract final class AppLiquidGlass {
  /// Platform-aware quality tier:
  /// - Native (iOS/macOS/Android Impeller): [GlassQuality.premium] (3D SDF).
  /// - Web (`kIsWeb`): [GlassQuality.standard] so `AnimatedGlassIndicator` and
  ///   `AdaptiveGlass` use calibrated 2D shader paths (`baseAlphaMultiplier = 0.0`
  ///   in dark mode, crisp hairline `0.35px` rim) rather than the thick `8px`
  ///   milky fallback ring triggered when `premium` falls back on Web.
  static GlassQuality get effectiveQuality =>
      kIsWeb ? GlassQuality.standard : GlassQuality.premium;

  /// Calibrated indicator lens settings matching iOS Simulator dark/light
  /// Liquid Glass (`ios27Indicator` paraxial optics with crisp hairline rim).
  static LiquidGlassSettings indicatorSettings({required bool isDark}) {
    if (kIsWeb && isDark) {
      return LiquidGlassSettings.ios27Indicator.copyWith(
        thickness: 22,
        glassColor: const Color(0x00000000),
        rimLight: 1.35,
        rimShade: 0.24,
        rimShadeEnds: 0.56,
        ambientRim: 0.28,
        edgeAbsorption: 0.16,
        lightIntensity: 0.95,
        lightAngle: 2.356194490192345, // 135 deg so top & bottom capsule arcs catch specular
        fresnelStrength: 0.90,
        ambientStrength: 0.0,
      );
    }
    return LiquidGlassSettings.ios27Indicator.copyWith(
      thickness: 18,
      glassColor: isDark ? const Color(0x00000000) : const Color(0x14FFFFFF),
      rimLight: isDark ? 0.48 : 0.42,
      rimShade: isDark ? 0.14 : 0.08,
      ambientRim: isDark ? 0.10 : 0.08,
      edgeAbsorption: isDark ? 0.12 : 0.08,
      lightIntensity: isDark ? 0.25 : 0.35,
    );
  }

  /// Frosted dark glass chrome with optical blur and subtle specular rim.
  static final LiquidGlassSettings darkChrome =
      LiquidGlassSettings.ios27Dark.copyWith(
    glassColor: kIsWeb ? const Color(0xBD06080C) : const Color(0xCC0D1016),
    frost: kIsWeb ? 0.08 : 0.20,
    frostOpacity: kIsWeb ? 0.08 : 0.20,
    frostWeight: kIsWeb ? 0.18 : 0.32,
    frostClamp: kIsWeb ? 0.14 : 0.26,
    blur: kIsWeb ? 10 : 18,
    blurWeight: 0.85,
    bodyShade: kIsWeb ? 0.06 : 0.20,
    thickness: 20,
    refractiveIndex: 1.15,
    rimShade: 0.12,
    rimShadeEnds: 1.0,
    rimLight: kIsWeb ? 0.56 : 0.38,
    fresnelStrength: kIsWeb ? 0.26 : 0.12,
    ambientStrength: kIsWeb ? 0.04 : 0.10,
    ambientRim: kIsWeb ? 0.24 : 0.42,
    lightIntensity: kIsWeb ? 0.22 : 0.14,
    lightAngle: 1.5707963267948966,
    edgeAbsorption: 0.12,
    saturation: 1.05,
    chromaticAberration: 0,
    shadowElevation: 0.18,
    backerColor: const Color(0xCC06080C),
  );

  static final GlassThemeData themeData = GlassThemeData(
    light: GlassThemeVariant.ios27Light,
    dark: GlassThemeVariant(
      settings: GlassThemeSettings.ios27Dark.copyWith(
        glassColor: darkChrome.glassColor,
        frost: darkChrome.frost,
        frostOpacity: darkChrome.frostOpacity,
        frostWeight: darkChrome.frostWeight,
        frostClamp: darkChrome.frostClamp,
        blur: darkChrome.blur,
        blurWeight: darkChrome.blurWeight,
        bodyShade: darkChrome.bodyShade,
        thickness: darkChrome.thickness,
        refractiveIndex: darkChrome.refractiveIndex,
        rimShade: darkChrome.rimShade,
        rimShadeEnds: darkChrome.rimShadeEnds,
        rimLight: darkChrome.rimLight,
        fresnelStrength: darkChrome.fresnelStrength,
        ambientStrength: darkChrome.ambientStrength,
        lightIntensity: darkChrome.lightIntensity,
        lightAngle: darkChrome.lightAngle,
        edgeAbsorption: darkChrome.edgeAbsorption,
        saturation: darkChrome.saturation,
        chromaticAberration: darkChrome.chromaticAberration,
        shadowElevation: darkChrome.shadowElevation,
      ),
    ),
  );
}
