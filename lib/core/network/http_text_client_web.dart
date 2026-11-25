import 'dart:async';
import 'dart:js_interop';

@JS('fetch')
external JSPromise<_JSResponse> _jsFetch(JSString url, _JSRequestInit init);

extension type _JSRequestInit._(JSObject _) implements JSObject {
  external factory _JSRequestInit({
    JSString method,
    JSObject headers,
    JSString? body,
  });
}

extension type _JSResponse._(JSObject _) implements JSObject {
  external bool get ok;
  external int get status;
  external JSPromise<JSString> text();
}

@JS('Object.fromEntries')
external JSObject _jsObjectFromEntries(JSArray<JSArray<JSString>> entries);

/// Web (`dart:js_interop`) browser `fetch()` GET implementation.
Future<String?> platformHttpGetText(
  Uri uri, {
  Map<String, String> headers = const <String, String>{},
  Duration timeout = const Duration(seconds: 5),
}) async {
  try {
    final headerPairs = <JSArray<JSString>>[];
    for (final entry in headers.entries) {
      final lower = entry.key.toLowerCase();
      if (lower == 'user-agent') continue;
      headerPairs.add(
        <JSString>[entry.key.toJS, entry.value.toJS].toJS,
      );
    }

    final init = _JSRequestInit(
      method: 'GET'.toJS,
      headers: _jsObjectFromEntries(headerPairs.toJS),
    );

    final response =
        await _jsFetch(uri.toString().toJS, init).toDart.timeout(timeout);
    if (response.ok && response.status >= 200 && response.status < 300) {
      final jsText = await response.text().toDart.timeout(timeout);
      return jsText.toDart;
    }
  } catch (_) {
    // CORS or offline error — return null so caller falls back cleanly.
  }
  return null;
}

/// Web (`dart:js_interop`) browser `fetch()` POST JSON implementation.
Future<String?> platformHttpPostJson(
  Uri uri, {
  required String jsonBody,
  Map<String, String> headers = const <String, String>{},
  Duration timeout = const Duration(seconds: 6),
}) async {
  try {
    final headerPairs = <JSArray<JSString>>[
      <JSString>['Content-Type'.toJS, 'application/json'.toJS].toJS,
    ];
    for (final entry in headers.entries) {
      final lower = entry.key.toLowerCase();
      if (lower == 'user-agent' || lower == 'content-type') continue;
      headerPairs.add(
        <JSString>[entry.key.toJS, entry.value.toJS].toJS,
      );
    }

    final init = _JSRequestInit(
      method: 'POST'.toJS,
      headers: _jsObjectFromEntries(headerPairs.toJS),
      body: jsonBody.toJS,
    );

    final response =
        await _jsFetch(uri.toString().toJS, init).toDart.timeout(timeout);
    if (response.ok && response.status >= 200 && response.status < 300) {
      final jsText = await response.text().toDart.timeout(timeout);
      return jsText.toDart;
    }
  } catch (_) {
    // CORS or offline error — return null.
  }
  return null;
}
