import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pos_terminal/services/api_url_helper.dart';

const DEFAULT_LOCAL_API_URL = "http://localhost:5173/api";

String _apiUrl = DEFAULT_LOCAL_API_URL;

String get API_URL => _apiUrl;

set API_URL(String value) {
  _apiUrl = value;
}

Future<void> initApiUrl() async {
  final prefs = await SharedPreferences.getInstance();
  final savedUrl = prefs.getString("api_url");
  if (savedUrl != null && savedUrl.trim().isNotEmpty) {
    _apiUrl = savedUrl.trim();
  } else {
    if (kIsWeb) {
      // First try to check meta tag in index.html
      final metaUrl = getWebMetaApiUrl();
      if (metaUrl.isNotEmpty) {
        _apiUrl = metaUrl;
      } else {
        try {
          _apiUrl = "${Uri.base.origin}/api";
        } catch (_) {
          _apiUrl = DEFAULT_LOCAL_API_URL;
        }
      }
    } else {
      _apiUrl = DEFAULT_LOCAL_API_URL;
    }
  }
}
