import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:stampit_app/controllers/auth_controller.dart';
import 'package:stampit_app/core/constants.dart';
import 'package:stampit_app/core/navigation.dart';
import 'package:stampit_app/core/theme.dart';
import 'package:stampit_app/views/auth/auth_screen_scaffold.dart';
import 'package:stampit_app/widgets/create_card_link.dart';
import 'package:stampit_app/widgets/form_error_banner.dart';
import 'package:stampit_app/widgets/password_field.dart';
import 'package:stampit_app/widgets/primary_button.dart';

/// Retailer sign-in — mirrors app/login/page.tsx + actions.ts (Supabase
/// Auth email/password, handled by AuthController.signInRetailer).
class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _submit(AuthController auth) async {
    final ok = await auth.signInRetailer(_emailController.text, _passwordController.text);
    if (ok) popToRoot();
  }

  Future<void> _openForgotPassword() =>
      launchUrl(Uri.parse(AppConfig.forgotPasswordUrl), mode: LaunchMode.externalApplication);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Consumer<AuthController>(
      builder: (context, auth, _) {
        return AuthScreenScaffold(
          title: 'Welcome back 👋',
          subtitle: 'Scan customer cards, and redeem customer dicount coupons on the go.',
          children: [
            if (auth.error != null) FormErrorBanner(message: auth.error!),
            TextFormField(
              controller: _emailController,
              enabled: !auth.isSubmitting,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.mail_outline_rounded)),
            ),
            const SizedBox(height: 16),
            PasswordField(
              controller: _passwordController,
              enabled: !auth.isSubmitting,
              prefixIcon: Icons.lock_outline_rounded,
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _openForgotPassword,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text('Forgot password?', style: TextStyle(fontWeight: FontWeight.w700, color: c.accent)),
              ),
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              label: 'Log in',
              pendingLabel: 'Logging in…',
              loading: auth.isSubmitting,
              icon: Icons.login_rounded,
              onPressed: () => _submit(auth),
            ),
            const SizedBox(height: 20),
            const CreateCardLink(),
          ],
        );
      },
    );
  }
}
