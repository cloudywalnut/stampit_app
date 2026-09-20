import 'package:flutter/foundation.dart';
import 'package:stampit_app/models/coupon.dart';
import 'package:stampit_app/services/api_exception.dart';
import 'package:stampit_app/services/coupon_service.dart';

/// The "Controller" behind the coupon list on the Redeem screen — mirrors
/// CouponsList.tsx: both statuses are fetched once and the Redeemed/Available
/// tabs plus the search just filter that list client-side.
class CouponsController extends ChangeNotifier {
  CouponsController(this._couponService);

  final CouponService _couponService;

  List<Coupon> _coupons = [];
  bool loading = false;
  String? error;

  // Defaults to redeemed, like the web tab.
  bool showRedeemed = true;
  String query = '';

  /// [refresh] re-fetches in place (e.g. after a redeem) instead of resetting
  /// the list, tab and search — a fresh open starts clean so a previously
  /// signed-in account's coupons are never shown.
  Future<void> load(String token, {bool refresh = false}) async {
    if (!refresh) {
      _coupons = [];
      showRedeemed = true;
      query = '';
    }
    loading = !refresh;
    error = null;
    notifyListeners();

    try {
      _coupons = await _couponService.list(token: token);
    } on ApiException catch (e) {
      error = e.message;
    } catch (_) {
      error = 'Network error. Try again.';
    }
    loading = false;
    notifyListeners();
  }

  void setShowRedeemed(bool value) {
    showRedeemed = value;
    notifyListeners();
  }

  void setQuery(String value) {
    query = value;
    notifyListeners();
  }

  /// Redeemed sorts by when it was redeemed, Available by when it was earned —
  /// same per-tab date rule as CouponsList.tsx.
  DateTime dateFor(Coupon coupon) => showRedeemed ? (coupon.redeemedAt ?? coupon.createdAt) : coupon.createdAt;

  List<Coupon> get filtered {
    final q = query.trim().toLowerCase();
    return _coupons
        .where((c) => c.redeemed == showRedeemed)
        .where((c) => q.isEmpty || c.code.toLowerCase().contains(q) || (c.customerName ?? '').toLowerCase().contains(q))
        .toList()
      ..sort((a, b) => dateFor(b).compareTo(dateFor(a)));
  }
}
