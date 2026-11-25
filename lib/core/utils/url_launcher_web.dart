import 'dart:js_interop';

@JS('window.open')
external JSAny? _windowOpen(String url, String target, String features);

@JS('window.location.assign')
external void _locationAssign(String url);

/// Launches [rawUrl] on Web synchronously inside the user click gesture so
/// popup blockers allow `_blank` navigation.
Future<bool> launchExternalUrl(String rawUrl, Uri uri) async {
  try {
    final scheme = uri.scheme.toLowerCase();
    if (scheme == 'mailto' || scheme == 'tel') {
      _locationAssign(rawUrl);
      return true;
    }
    _windowOpen(rawUrl, '_blank', 'noopener,noreferrer');
    return true;
  } catch (_) {
    return false;
  }
}
