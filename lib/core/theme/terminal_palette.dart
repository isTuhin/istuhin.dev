import 'package:material_ui/material_ui.dart';

/// Color tokens for the macOS `-zsh` terminal shell and traffic-light chrome
/// featured on `isTuhin.dev`.
abstract final class TerminalPalette {
  static const trafficClose = Color(0xFFFF5F56);
  static const trafficMinimize = Color(0xFFFFBD2E);
  static const trafficZoom = Color(0xFF27C93F);

  static const promptArrow = Color(0xFF69D17A);
  static const directoryCyan = Color(0xFF5AC8FA);
  static const commandAmber = Color(0xFFFFD60A);
  static const accentPurple = Color(0xFFBF5AF2);
  static const errorCoral = Color(0xFFFF6961);

  static Color terminalSurface(bool isDark) =>
      isDark ? const Color(0xD90A0D12) : const Color(0xF212161F);

  static Color terminalHeaderSurface(bool isDark) =>
      isDark ? const Color(0xF0141922) : const Color(0xFA1C222E);

  static Color terminalBorder(bool isDark) =>
      isDark ? const Color(0x33FFFFFF) : const Color(0x26000000);
}
