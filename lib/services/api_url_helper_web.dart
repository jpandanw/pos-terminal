import 'dart:js_interop';
import 'package:web/web.dart' as web;

String getPlatformMetaApiUrl() {
  try {
    final meta = web.document.querySelector('meta[name="api-url"]') as web.HTMLMetaElement?;
    if (meta != null && meta.content.isNotEmpty) {
      return meta.content;
    }
  } catch (_) {}
  return '';
}
