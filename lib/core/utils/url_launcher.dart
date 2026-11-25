import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../widgets/glass/glass_kit.dart';
import 'url_launcher_io.dart'
    if (dart.library.js_interop) 'url_launcher_web.dart' as platform;

/// Cross-platform, zero-dependency external URL and `mailto:` launcher.
///
/// - On Web: opens `http`/`https` in a new tab (`noopener,noreferrer`) and
///   assigns `mailto:`/`tel:` synchronously inside the user gesture handler.
/// - On Native (macOS/Linux/Windows/iOS simulator): invokes the OS opener,
///   with a hermetic guard for `flutter test` and clipboard fallback.
abstract final class UrlLauncher {
  static const Set<String> _allowedSchemes = {'https', 'http', 'mailto', 'tel'};

  /// Validates [rawUrl] and opens it in the system/browser handler.
  ///
  /// Returns `true` if the launch was dispatched successfully.
  static Future<bool> launch(BuildContext context, String rawUrl) async {
    final trimmed = rawUrl.trim();
    final uri = Uri.tryParse(trimmed);
    if (uri == null || !_allowedSchemes.contains(uri.scheme.toLowerCase())) {
      if (context.mounted) {
        AppGlassOverlays.showToast(
          context,
          message: 'Invalid link: $trimmed',
          type: GlassToastType.warning,
        );
      }
      return false;
    }

    final launched = await platform.launchExternalUrl(trimmed, uri);
    if (!launched && context.mounted) {
      await Clipboard.setData(ClipboardData(text: trimmed));
      if (context.mounted) {
        AppGlassOverlays.showToast(
          context,
          message: 'Copied link to clipboard: $trimmed',
        );
      }
    }
    return launched;
  }
}
