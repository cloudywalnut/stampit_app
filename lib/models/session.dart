enum ActorType { retailer, staff }

/// The signed-in actor, mirroring lib/actor.ts's Actor union on the web
/// backend — the same "retailer vs staff" split, just as a client-side model.
/// Named AppSession (not Session) to avoid colliding with supabase_flutter's
/// own Session type, which auth_service.dart also imports.
class AppSession {
  final ActorType type;
  final String? staffName;
  final String businessName;
  final String currency;

  /// Bearer token sent on every API call: a Supabase access token for a
  /// retailer, or the signed staff JWT for staff.
  final String token;

  const AppSession({
    required this.type,
    required this.businessName,
    required this.currency,
    required this.token,
    this.staffName,
  });

  String get displayName {
    if (type == ActorType.staff) return staffName ?? 'Staff';
    return businessName.isNotEmpty ? businessName : 'Your account';
  }
}
