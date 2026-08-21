import 'package:flutter/material.dart';
import 'package:stampit_app/core/theme.dart';

/// Inline form error — mirrors the web's `bg-accent/15 text-accent` banner
/// used on /login, /staff-login, etc.
class FormErrorBanner extends StatelessWidget {
  const FormErrorBanner({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(color: c.accent.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(18)),
      child: Text(message, style: TextStyle(color: c.accent, fontWeight: FontWeight.w700)),
    );
  }
}
