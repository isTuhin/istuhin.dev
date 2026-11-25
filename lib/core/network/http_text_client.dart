import 'http_text_client_web.dart'
    if (dart.library.io) 'http_text_client_io.dart';

/// Cross-platform HTTP GET and POST utility supporting both Native (`dart:io` `HttpClient`)
/// and Web (`Chrome` browser `fetch` via `dart:js_interop`).
abstract final class HttpTextClient {
  static Future<String?> getText(
    Uri uri, {
    Map<String, String> headers = const <String, String>{},
    Duration timeout = const Duration(seconds: 5),
  }) {
    return platformHttpGetText(
      uri,
      headers: headers,
      timeout: timeout,
    );
  }

  static Future<String?> postJson(
    Uri uri, {
    required String jsonBody,
    Map<String, String> headers = const <String, String>{},
    Duration timeout = const Duration(seconds: 6),
  }) {
    return platformHttpPostJson(
      uri,
      jsonBody: jsonBody,
      headers: headers,
      timeout: timeout,
    );
  }
}
