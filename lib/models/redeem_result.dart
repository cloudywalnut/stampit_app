/// Mirrors the JSON shape POST /api/coupons/redeem returns on success.
class RedeemResult {
  final String discountType;
  final num? discountValue;
  final String description;

  const RedeemResult({required this.discountType, required this.discountValue, required this.description});

  factory RedeemResult.fromJson(Map<String, dynamic> json) => RedeemResult(
    discountType: json['discountType'] as String,
    discountValue: json['discountValue'] as num?,
    description: json['description'] as String? ?? '',
  );
}
