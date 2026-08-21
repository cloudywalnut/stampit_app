class EarnedCoupon {
  final String code;
  final String description;

  const EarnedCoupon({required this.code, required this.description});

  factory EarnedCoupon.fromJson(Map<String, dynamic> json) =>
      EarnedCoupon(code: json['code'] as String, description: json['description'] as String? ?? '');
}

/// Mirrors the JSON shape POST /api/scan returns on success.
class ScanResult {
  final int stamps;
  final int addedStamps;
  final bool couponEarned;
  final List<EarnedCoupon> coupons;

  const ScanResult({
    required this.stamps,
    required this.addedStamps,
    required this.couponEarned,
    required this.coupons,
  });

  factory ScanResult.fromJson(Map<String, dynamic> json) => ScanResult(
    stamps: json['stamps'] as int,
    addedStamps: json['addedStamps'] as int? ?? 1,
    couponEarned: json['couponEarned'] as bool? ?? false,
    coupons: (json['coupons'] as List<dynamic>? ?? [])
        .map((e) => EarnedCoupon.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}
