import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stampit_app/core/theme.dart';

/// Shared shell for the two sign-in screens (retailer / staff) — same
/// icon/title/subtitle/back-button structure, just different form fields.
class AuthScreenScaffold extends StatelessWidget {
  const AuthScreenScaffold({super.key, required this.title, required this.subtitle, required this.children});

  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 50),
              Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: c.accent,
                    boxShadow: [BoxShadow(color: c.accent.withValues(alpha: 0.35), blurRadius: 44, spreadRadius: 6)],
                  ),
                  child: Icon(Icons.lock_outline_rounded, color: c.accentInk, size: 32),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.bricolageGrotesque(fontSize: 28, fontWeight: FontWeight.w800, color: c.ink),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: c.inkSoft, height: 1.4),
              ),
              const SizedBox(height: 28),
              ...children,
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
