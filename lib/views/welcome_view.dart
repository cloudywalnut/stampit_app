import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stampit_app/core/theme.dart';
import 'package:stampit_app/views/auth/login_view.dart';
import 'package:stampit_app/views/auth/staff_login_view.dart';
import 'package:stampit_app/widgets/create_card_link.dart';
import 'package:stampit_app/widgets/primary_button.dart';

class WelcomeView extends StatelessWidget {
  const WelcomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 3),
              Center(
                child: ClipOval(
                  child: Image.asset('assets/icon/icon.png', height: 96, width: 96, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 20),
              Text.rich(
                TextSpan(
                  style: GoogleFonts.bricolageGrotesque(fontSize: 36, fontWeight: FontWeight.w800, color: c.ink),
                  children: [const TextSpan(text: 'Stamp'), TextSpan(text: 'It', style: TextStyle(color: c.brand))],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text.rich(
                TextSpan(
                  style: GoogleFonts.bricolageGrotesque(fontSize: 24, fontWeight: FontWeight.w800, color: c.ink, height: 1.3),
                  children: [
                    const TextSpan(text: 'Loyalty made '),
                    TextSpan(text: 'simple.', style: TextStyle(color: c.brand)),
                    const TextSpan(text: '\nRewards made '),
                    TextSpan(text: 'better.', style: TextStyle(color: c.accent)),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Text(
                    "The checkout companion for StampIt loyalty cards. Scan a customer's "
                    'Wallet pass to add a stamp, redeem a coupon they\'ve earned, or jump '
                    'into the full dashboard for everything else, all from the counter.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: c.inkSoft, height: 1.45),
                  ),
                ),
              ),
              const Spacer(flex: 4),
              PrimaryButton(
                label: 'Sign In',
                icon: Icons.login_rounded,
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LoginView())),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                style: OutlinedButton.styleFrom(side: BorderSide(color: c.brand, width: 2)),
                onPressed: () =>
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const StaffLoginView())),
                child: const Text('Sign in as staff'),
              ),
              const SizedBox(height: 24),
              const CreateCardLink(),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
