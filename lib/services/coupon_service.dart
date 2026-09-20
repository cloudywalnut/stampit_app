import 'package:stampit_app/models/coupon.dart';
import 'package:stampit_app/models/redeem_result.dart';
import 'package:stampit_app/services/api_client.dart';

/// Wraps the coupon REST routes — the counterparts to the web dashboard's
/// Coupons page: POST /api/coupons/redeem (lib/redeemCoupon.ts on the
/// backend, shared with the redeemCoupon Server Action) and GET /api/coupons
/// (lib/listCoupons.ts, shared with the page itself).
class CouponService {
  Future<RedeemResult> redeem({required String token, required String code}) async {
    final json = await ApiClient.post('/api/coupons/redeem', token: token, body: {'code': code});
    return RedeemResult.fromJson(json);
  }

  Future<List<Coupon>> list({required String token}) async {
    final json = await ApiClient.get('/api/coupons', token: token);
    return (json['coupons'] as List).map((e) => Coupon.fromJson(e as Map<String, dynamic>)).toList();
  }
}
