import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:stampit_app/models/session.dart';
import 'package:stampit_app/services/api_client.dart';

/// Wraps the app's two unrelated sign-in paths (mirrors lib/actor.ts's
/// split on the web backend):
/// - Retailer: real Supabase Auth, handled entirely client-side by
///   supabase_flutter (which persists its own session in SharedPreferences).
/// - Staff: not a Supabase user at all — POST /api/staff-login returns a
///   signed JWT that this app stores itself (also in SharedPreferences, same
///   as the retailer session) and sends as a Bearer token.
class AuthService {
  static const _staffTokenKey = 'stampit_staff_token';
  SupabaseClient get _supabase => Supabase.instance.client;

  Future<void> signInRetailer(String email, String password) {
    return _supabase.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOutRetailer() => _supabase.auth.signOut();

  String? get retailerAccessToken => _supabase.auth.currentSession?.accessToken;

  Future<String> signInStaff(String username, String password) async {
    final json = await ApiClient.post(
      '/api/staff-login',
      body: {'username': username, 'password': password},
    );
    final token = json['token'] as String;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_staffTokenKey, token);
    return token;
  }

  Future<String?> readStaffToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_staffTokenKey);
  }

  Future<void> clearStaffToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_staffTokenKey);
  }

  Future<AppSession> fetchSession(String token) async {
    final json = await ApiClient.get('/api/me', token: token);
    return AppSession.fromJson(json, token: token);
  }
}
