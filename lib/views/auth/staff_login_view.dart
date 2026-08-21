import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stampit_app/controllers/auth_controller.dart';
import 'package:stampit_app/views/auth/auth_screen_scaffold.dart';
import 'package:stampit_app/widgets/form_error_banner.dart';
import 'package:stampit_app/widgets/password_field.dart';
import 'package:stampit_app/widgets/primary_button.dart';

/// Staff sign-in — mirrors app/staff-login/page.tsx, but talks to
/// POST /api/staff-login instead of the cookie-setting Server Action,
/// since this app has no shared cookie jar with the website.
class StaffLoginView extends StatefulWidget {
  const StaffLoginView({super.key});

  @override
  State<StaffLoginView> createState() => _StaffLoginViewState();
}

class _StaffLoginViewState extends State<StaffLoginView> {
  final _username = TextEditingController();
  final _password = TextEditingController();

  Future<void> _submit(AuthController auth) async {
    final ok = await auth.signInStaff(_username.text, _password.text);
    if (ok && mounted) Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthController>(
      builder: (context, auth, _) {
        return AuthScreenScaffold(
          title: 'Staff sign in',
          subtitle: "Use the username and password your manager gave you.",
          children: [
            if (auth.error != null) FormErrorBanner(message: auth.error!),
            TextFormField(
              controller: _username,
              textCapitalization: TextCapitalization.none,
              decoration: const InputDecoration(labelText: 'Username', prefixIcon: Icon(Icons.person_outline_rounded)),
            ),
            const SizedBox(height: 16),
            PasswordField(controller: _password, prefixIcon: Icons.lock_outline_rounded),
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'Sign in',
              pendingLabel: 'Signing in…',
              loading: auth.isSubmitting,
              onPressed: () => _submit(auth),
            ),
          ],
        );
      },
    );
  }
}
