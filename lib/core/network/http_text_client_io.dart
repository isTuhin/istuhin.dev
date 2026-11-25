import 'dart:convert';
import 'dart:io';

/// Native (`dart:io`) HTTP GET text fetcher with connection timeout and redirect handling.
Future<String?> platformHttpGetText(
  Uri uri, {
  Map<String, String> headers = const <String, String>{},
  Duration timeout = const Duration(seconds: 5),
}) async {
  final client = HttpClient()..connectionTimeout = timeout;
  try {
    final req = await client.getUrl(uri).timeout(timeout);
    req.followRedirects = true;
    req.maxRedirects = 5;
    req.headers.set(
      HttpHeaders.userAgentHeader,
      'isTuhinDev-Flutter-Portfolio',
    );
    for (final entry in headers.entries) {
      req.headers.set(entry.key, entry.value);
    }
    final res = await req.close().timeout(timeout);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return await res.transform(utf8.decoder).join().timeout(timeout);
    }
  } catch (_) {
    // Return null on network error or offline state.
  } finally {
    client.close();
  }
  return null;
}

/// Native (`dart:io`) HTTP POST JSON utility.
Future<String?> platformHttpPostJson(
  Uri uri, {
  required String jsonBody,
  Map<String, String> headers = const <String, String>{},
  Duration timeout = const Duration(seconds: 6),
}) async {
  final client = HttpClient()..connectionTimeout = timeout;
  try {
    final req = await client.postUrl(uri).timeout(timeout);
    req.followRedirects = true;
    req.headers.set(
      HttpHeaders.userAgentHeader,
      'isTuhinDev-Flutter-Portfolio',
    );
    req.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
    for (final entry in headers.entries) {
      req.headers.set(entry.key, entry.value);
    }
    final encoded = utf8.encode(jsonBody);
    req.contentLength = encoded.length;
    req.add(encoded);
    final res = await req.close().timeout(timeout);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return await res.transform(utf8.decoder).join().timeout(timeout);
    }
  } catch (_) {
    // Return null on network error or offline state.
  } finally {
    client.close();
  }
  return null;
}
