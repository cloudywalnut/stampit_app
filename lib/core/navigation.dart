import 'package:flutter/widgets.dart';

/// Root navigator key — lets non-widget code (AuthController's forced
/// sign-out on an expired/invalid token) pop back to the root route
/// (AuthGate) so the login screen becomes visible immediately, even when
/// the 401 happened on a screen pushed on top of it (Scan/Redeem).
final navigatorKey = GlobalKey<NavigatorState>();

/// Shared "return to Home/AuthGate" action — used both after a successful
/// sign-in (LoginView/StaffLoginView) and after a forced sign-out
/// (AuthController). Goes through navigatorKey rather than a local
/// BuildContext so it works the same from both a widget's onPressed and
/// from plain Dart code with no context at all.
void popToRoot() => navigatorKey.currentState?.popUntil((route) => route.isFirst);
