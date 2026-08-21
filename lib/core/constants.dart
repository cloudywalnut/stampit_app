/// Same Supabase project the web app (stampit/) uses — this anon key is
/// already public (it ships in the web app's client JS bundle); RLS is
/// what actually scopes access, not key secrecy.
class AppConfig {
  static const supabaseUrl = 'https://vkqgksndytajiwedqidx.supabase.co';
  static const supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZrcWdrc25keXRhaml3ZWRxaWR4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODUzNzc1MzQsImV4cCI6MjEwMDk1MzUzNH0._hiXa8CtJFTbsOEnHb-3qlzBb29gg1sPvrDGLfHucbY';

  /// The web app — also where the REST API routes this app calls
  /// (/api/scan, /api/staff-login, /api/coupons/redeem, /api/me) live.
  /// Pointed at the laptop's LAN IP (not localhost) so a physical phone on
  /// the same WiFi can reach the local Next.js dev server — swap back to
  /// https://stampit.digital before shipping.
  static const webBaseUrl = 'http://192.168.68.8:3000';

  static const registerUrl = '$webBaseUrl/signup';
  static const dashboardUrl = '$webBaseUrl/dashboard';
  static const forgotPasswordUrl = '$webBaseUrl/forgot-password';
  static const analyticsUrl = '$webBaseUrl/dashboard/customers/analytics';
}
