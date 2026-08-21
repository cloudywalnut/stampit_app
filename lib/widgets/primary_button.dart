import 'package:flutter/material.dart';
import 'package:stampit_app/core/theme.dart';

/// Big pill CTA — the Flutter equivalent of the web's SubmitButton.tsx,
/// including its signature flat drop-shadow
/// (`shadow-[0_5px_0_0_color-mix(in_srgb,var(--color-accent)_60%,black)]`):
/// a hard, unblurred offset beneath the pill rather than a soft Material
/// elevation, which is why this is a custom Material+InkWell instead of a
/// themed ElevatedButton.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.pendingLabel,
    this.icon,
  });

  final String label;
  final String? pendingLabel;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final disabled = loading || onPressed == null;
    final shadowColor = Color.lerp(Colors.black, c.accent, 0.6)!;

    return Opacity(
      opacity: disabled ? 0.6 : 1,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          boxShadow: [BoxShadow(color: shadowColor, offset: const Offset(0, 5))],
        ),
        child: Material(
          color: c.accent,
          borderRadius: BorderRadius.circular(999),
          child: InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: disabled ? null : onPressed,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 18),
              child: Center(
                child: loading
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2.4, color: c.accentInk),
                          ),
                          const SizedBox(width: 12),
                          Text(pendingLabel ?? label, style: _labelStyle(c)),
                        ],
                      )
                    : icon == null
                    ? Text(label, style: _labelStyle(c))
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(icon, size: 20, color: c.accentInk),
                          const SizedBox(width: 10),
                          Text(label, style: _labelStyle(c)),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  TextStyle _labelStyle(AppColors c) => TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: c.accentInk);
}
