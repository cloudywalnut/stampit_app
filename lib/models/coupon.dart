/// Mirrors one row of GET /api/coupons (the web Coupons page's query).
class Coupon {
  final String id;
  final String code;
  final bool redeemed;
  final String discountType;
  final num? discountValue;
  final String description;
  final DateTime createdAt;
  final DateTime? redeemedAt;
  final String? customerName;

  const Coupon({
    required this.id,
    required this.code,
    required this.redeemed,
    required this.discountType,
    required this.discountValue,
    required this.description,
    required this.createdAt,
    required this.redeemedAt,
    required this.customerName,
  });

  factory Coupon.fromJson(Map<String, dynamic> json) => Coupon(
    id: json['id'] as String,
    code: json['code'] as String,
    redeemed: json['status'] == 'redeemed',
    discountType: json['discount_type'] as String,
    discountValue: json['discount_value'] as num?,
    description: json['description'] as String? ?? '',
    createdAt: DateTime.parse(json['created_at'] as String),
    redeemedAt: json['redeemed_at'] == null ? null : DateTime.parse(json['redeemed_at'] as String),
    customerName: (json['customer_cards'] as Map<String, dynamic>?)?['name'] as String?,
  );
}
