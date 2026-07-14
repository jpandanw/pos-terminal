import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pos_terminal/services/api_url_helper.dart';

// const DEFAULT_LOCAL_API_URL = "http://localhost:5173/api";

// Read from compile-time environment variable (e.g. via --dart-define=API_URL=...)
// const String envApiUrl = String.fromEnvironment('API_URL');

String _apiUrl = "http://xmserver:3000/api";

String get API_URL => "http://xmserver:3000/api";

set API_URL(String value) {
  _apiUrl = value;
}

// Future<void> initApiUrl() async {
//   // If an environment variable is defined, prioritize it
//   if (envApiUrl.isNotEmpty) {
//     _apiUrl = envApiUrl;
//     return;
//   }
//
//   final prefs = await SharedPreferences.getInstance();
//   final savedUrl = prefs.getString("api_url");
//   if (savedUrl != null && savedUrl.trim().isNotEmpty) {
//     _apiUrl = savedUrl.trim();
//   } else {
//     if (kIsWeb) {
//       // Check if a custom meta tag exists in index.html
//       final metaUrl = getWebMetaApiUrl();
//       if (metaUrl.isNotEmpty) {
//         _apiUrl = metaUrl;
//       } else {
//         try {
//           _apiUrl = "${Uri.base.origin}/api";
//         } catch (_) {
//           _apiUrl = DEFAULT_LOCAL_API_URL;
//         }
//       }
//     } else {
//       _apiUrl = DEFAULT_LOCAL_API_URL;
//     }
//   }
// }
