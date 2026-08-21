import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stampit_app/controllers/auth_controller.dart';
import 'package:stampit_app/views/home/home_view.dart';
import 'package:stampit_app/views/welcome_view.dart';

/// Root switch: shows a loader while bootstrap() resolves whichever
/// session (if any) is already stored, then routes to Welcome or Home.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthController>(
      builder: (context, auth, _) {
        switch (auth.status) {
          case AuthStatus.bootstrapping:
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          case AuthStatus.signedOut:
            return const WelcomeView();
          case AuthStatus.signedIn:
            return const HomeView();
        }
      },
    );
  }
}
