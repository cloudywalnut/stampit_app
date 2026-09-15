import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:stampit_app/controllers/auth_controller.dart';
import 'package:stampit_app/core/constants.dart';
import 'package:stampit_app/core/theme.dart';
import 'package:stampit_app/views/redeem/redeem_view.dart';
import 'package:stampit_app/views/scan/scan_view.dart';

/// Home — deliberately just the two things staff actually use day to day
/// (Scan, Redeem) plus links out to the full web dashboard for everything
/// else (Customers, Rewards, Class, etc.), per the app's scope.
class HomeView extends StatelessWidget {
  const HomeView({super.key});

  Future<void> _openDashboard() =>
      launchUrl(Uri.parse(AppConfig.dashboardUrl), mode: LaunchMode.externalApplication);

  Future<void> _openAnalytics() =>
      launchUrl(Uri.parse(AppConfig.analyticsUrl), mode: LaunchMode.externalApplication);

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Consumer<AuthController>(
      builder: (context, auth, _) {
        final session = auth.session!;
        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text.rich(
                              TextSpan(
                                style: GoogleFonts.bricolageGrotesque(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: c.ink,
                                ),
                                children: [
                                  const TextSpan(text: 'Stamp'),
                                  TextSpan(text: 'It', style: TextStyle(color: c.brand)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Loyalty made simple. Rewards made better.',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: c.inkSoft),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.logout_rounded),
                        tooltip: 'Sign out',
                        onPressed: () => auth.signOut(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Welcome back,',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: c.inkSoft),
                  ),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          session.displayName,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.bricolageGrotesque(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: c.ink,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text('👋', style: TextStyle(fontSize: 22)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: c.surface, borderRadius: BorderRadius.circular(20)),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.card_giftcard_rounded, color: c.brand, size: 32),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text.rich(
                                TextSpan(
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: c.ink),
                                  children: [
                                    const TextSpan(text: 'Give stamps, keep them '),
                                    TextSpan(text: 'coming.', style: TextStyle(color: c.accent)),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Scan a customer's Wallet QR to add a stamp instantly.",
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: c.inkSoft,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: _DashboardTile(
                            icon: Icons.qr_code_scanner_rounded,
                            label: 'Scan',
                            description: "Add a stamp to a customer's card",
                            color: c.accent,
                            onColor: c.accentInk,
                            onTap: () =>
                                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ScanView())),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _DashboardTile(
                            icon: Icons.confirmation_number_rounded,
                            label: 'Redeem',
                            description: "Redeem the coupon",
                            color: c.brand,
                            onColor: c.brandInk,
                            onTap: () =>
                                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RedeemView())),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _LinkRow(
                    icon: Icons.trending_up_rounded,
                    title: 'Track your progress',
                    subtitle: 'View your customer activity',
                    onTap: _openAnalytics,
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _openDashboard,
                    icon: const Icon(Icons.open_in_new, size: 18),
                    label: const Text('View full dashboard'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DashboardTile extends StatelessWidget {
  const _DashboardTile({
    required this.icon,
    required this.label,
    required this.description,
    required this.color,
    required this.onColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String description;
  final Color color;
  final Color onColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final shadowColor = Color.lerp(Colors.black, color, 0.6)!;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: shadowColor, offset: const Offset(0, 5))],
      ),
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(28),
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: onColor.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, size: 30, color: onColor),
                ),
                const SizedBox(height: 16),
                Text(label, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: onColor)),
                const SizedBox(height: 4),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: onColor.withValues(alpha: 0.75)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LinkRow extends StatelessWidget {
  const _LinkRow({required this.icon, required this.title, required this.subtitle, required this.onTap});

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Material(
      color: c.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: c.accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: c.accent, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: c.ink)),
                    Text(subtitle, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: c.inkSoft)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: c.inkSoft),
            ],
          ),
        ),
      ),
    );
  }
}
