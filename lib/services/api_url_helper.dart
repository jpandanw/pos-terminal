import 'package:flutter/foundation.dart';
import 'api_url_helper_stub.dart'
    if (dart.library.js_interop) 'api_url_helper_web.dart';

String getWebMetaApiUrl() {
  return getPlatformMetaApiUrl();
}
