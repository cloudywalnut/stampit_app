import 'package:stampit_app/models/redeem_result.dart';
import 'package:stampit_app/services/api_client.dart';

/// Wraps POST /api/coupons/redeem — the REST counterpart to the web
/// dashboard's redeemCoupon Server Action (see lib/redeemCoupon.ts on the
/// backend, shared by both entry points).
class CouponService {
  Future<RedeemResult> redeem({required String token, required String code}) async {
    final json = await ApiClient.post('/api/coupons/redeem', token: token, body: {'code': code});
    return RedeemResult.fromJson(json);
  }
}
