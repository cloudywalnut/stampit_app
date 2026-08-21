import 'package:flutter/material.dart';
import 'package:stampit_app/core/theme.dart';

/// Bottom toast card — mirrors the web's error (accent bg) / success
/// (brand bg) toast styling used in ScanClient.tsx and RedeemForm.tsx.
class ToastBanner extends StatelessWidget {
  const ToastBanner({super.key, required this.child, required this.isError});

  final Widget child;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: isError ? c.accent : c.brand,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, 8))],
      ),
      child: DefaultTextStyle(
        style: TextStyle(color: isError ? c.accentInk : c.brandInk, fontWeight: FontWeight.w800, fontSize: 16),
        textAlign: TextAlign.center,
        child: child,
      ),
    );
  }
}
