import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:stampit_app/core/constants.dart';
import 'package:stampit_app/core/theme.dart';

/// "New to StampIt? Create your loyalty card" — links out to the public
/// signup page, shown on both the welcome and login screens.
class CreateCardLink extends StatelessWidget {
  const CreateCardLink({super.key});

  Future<void> _open() => launchUrl(Uri.parse(AppConfig.registerUrl), mode: LaunchMode.externalApplication);

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Center(
      child: TextButton(
        onPressed: _open,
        child: Text.rich(
          TextSpan(
            style: TextStyle(fontWeight: FontWeight.w600, color: c.inkSoft),
            children: [
              const TextSpan(text: 'New to StampIt? '),
              TextSpan(text: 'Create your loyalty card', style: TextStyle(fontWeight: FontWeight.w800, color: c.accent)),
            ],
          ),
        ),
      ),
    );
  }
}
