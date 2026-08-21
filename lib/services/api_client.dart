import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:stampit_app/core/constants.dart';
import 'package:stampit_app/services/api_exception.dart';

/// Thin JSON/REST wrapper around the stampit web app's API routes
/// (app/api/**/route.ts) — every call carries the signed-in actor's token
/// as a Bearer header, which lib/actor.ts on the server resolves the same
/// way it resolves the website's own cookie session.
class ApiClient {
  static Uri _uri(String path) => Uri.parse('${AppConfig.webBaseUrl}$path');

  static Map<String, String> _headers(String? token) => {
    'Content-Type': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };

  static Future<Map<String, dynamic>> get(String path, {String? token}) async {
    final res = await http.get(_uri(path), headers: _headers(token));
    return _decode(res);
  }

  static Future<Map<String, dynamic>> post(String path, {String? token, Map<String, dynamic>? body}) async {
    final res = await http.post(_uri(path), headers: _headers(token), body: jsonEncode(body ?? {}));
    return _decode(res);
  }

  static Map<String, dynamic> _decode(http.Response res) {
    Map<String, dynamic> json;
    try {
      json = res.body.isEmpty ? {} : jsonDecode(res.body) as Map<String, dynamic>;
    } catch (_) {
      throw ApiException('Unexpected response from server.', res.statusCode);
    }

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw ApiException(json['error'] as String? ?? 'Something went wrong.', res.statusCode);
    }

    return json;
  }
}
