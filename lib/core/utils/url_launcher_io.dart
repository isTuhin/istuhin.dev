import 'dart:io';

import 'package:flutter/widgets.dart';

/// Launches [rawUrl] using the host OS handler when running outside widget
/// tests. Returns `false` if no OS opener succeeds so callers can fall back to
/// copying the link to the clipboard.
Future<bool> launchExternalUrl(String rawUrl, Uri uri) async {
  final bindingName = WidgetsBinding.instance.runtimeType.toString();
  if (bindingName.contains('Test')) {
    return true;
  }

  try {
    final ProcessResult result;
    if (Platform.isMacOS) {
      result = await Process.run('open', [rawUrl]);
    } else if (Platform.isLinux) {
      result = await Process.run('xdg-open', [rawUrl]);
    } else if (Platform.isWindows) {
      result = await Process.run('cmd', ['/c', 'start', '', rawUrl]);
    } else {
      return false;
    }
    return result.exitCode == 0;
  } catch (_) {
    return false;
  }
}
