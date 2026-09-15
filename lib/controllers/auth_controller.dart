import 'package:flutter/foundation.dart';
import 'package:stampit_app/core/navigation.dart';
import 'package:stampit_app/models/session.dart';
import 'package:stampit_app/services/api_client.dart';
import 'package:stampit_app/services/api_exception.dart';
import 'package:stampit_app/services/auth_service.dart';

enum AuthStatus { bootstrapping, signedOut, signedIn }

/// The "Controller" for sign-in/sign-out — the single source of truth for
/// which actor (if any) is currently signed in, shared across every View
/// via Provider. Views only read state and call methods here; all
/// auth-service/API orchestration lives in this class.
class AuthController extends ChangeNotifier {
  AuthController(this._authService) {
    // A 401 from anywhere (Scan, Redeem, ...) mid-session means the token
    // expired or was revoked — sign out and surface the login screen right
    // away instead of leaving whatever screen was open stuck on a raw
    // "Not signed in." error.
    ApiClient.onUnauthorized = _handleSessionExpired;
  }

  final AuthService _authService;

  AuthStatus status = AuthStatus.bootstrapping;
  AppSession? session;
  String? error;
  bool isSubmitting = false;

  /// Called once at app start: prefers a live Supabase retailer session
  /// (supabase_flutter persists this itself), falling back to a stored
  /// staff token. Either token is validated against /api/me — a stale
  /// or revoked one just drops back to signed-out.
  Future<void> bootstrap() async {
    final retailerToken = _authService.retailerAccessToken;
    final staffToken = await _authService.readStaffToken();
    final token = retailerToken ?? staffToken;

    if (token == null) {
      status = AuthStatus.signedOut;
      notifyListeners();
      return;
    }

    try {
      session = await _authService.fetchSession(token);
      status = AuthStatus.signedIn;
    } catch (_) {
      if (retailerToken == null) await _authService.clearStaffToken();
      status = AuthStatus.signedOut;
    }
    notifyListeners();
  }

  Future<bool> signInRetailer(String email, String password) => _submit(() async {
    await _authService.signInRetailer(email.trim(), password);
    final token = _authService.retailerAccessToken;
    if (token == null) throw const ApiException('Sign-in failed.', 401);
    session = await _authService.fetchSession(token);
  });

  Future<bool> signInStaff(String username, String password) => _submit(() async {
    final token = await _authService.signInStaff(username.trim(), password);
    session = await _authService.fetchSession(token);
  });

  Future<bool> _submit(Future<void> Function() action) async {
    isSubmitting = true;
    error = null;
    notifyListeners();

    try {
      await action();
      status = AuthStatus.signedIn;
      return true;
    } on ApiException catch (e) {
      error = e.message;
      return false;
    } catch (_) {
      error = 'Something went wrong. Try again.';
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    if (session?.type == ActorType.retailer) {
      await _authService.signOutRetailer();
    } else {
      await _authService.clearStaffToken();
    }
    session = null;
    status = AuthStatus.signedOut;
    notifyListeners();
  }

  /// Guarded to signedIn-only so this never interferes with a bootstrap()
  /// or sign-in attempt's own 401 handling (neither has a session to expire
  /// yet). Pops any pushed route (Scan/Redeem) so the login screen — which
  /// AuthGate now renders once status flips — is what the user actually sees.
  Future<void> _handleSessionExpired() async {
    if (status != AuthStatus.signedIn) return;
    await signOut();
    popToRoot();
  }
}
