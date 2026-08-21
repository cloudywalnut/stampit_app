import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:stampit_app/models/redeem_result.dart';
import 'package:stampit_app/services/api_exception.dart';
import 'package:stampit_app/services/coupon_service.dart';

sealed class RedeemToast {}

class RedeemSuccessToast extends RedeemToast {
  final RedeemResult result;
  RedeemSuccessToast(this.result);
}

class RedeemErrorToast extends RedeemToast {
  final String message;
  RedeemErrorToast(this.message);
}

/// The "Controller" behind the Redeem screen — mirrors RedeemForm.tsx's
/// submit-then-toast-then-clear flow.
class RedeemController extends ChangeNotifier {
  RedeemController(this._couponService);

  final CouponService _couponService;

  bool submitting = false;
  RedeemToast? toast;
  Timer? _toastTimer;

  Future<void> redeem(String token, String code) async {
    if (submitting || code.trim().isEmpty) return;
    submitting = true;
    toast = null;
    notifyListeners();

    try {
      final result = await _couponService.redeem(token: token, code: code);
      toast = RedeemSuccessToast(result);
    } on ApiException catch (e) {
      toast = RedeemErrorToast(e.message);
    } catch (_) {
      toast = RedeemErrorToast('Network error. Try again.');
    }
    submitting = false;
    notifyListeners();

    _toastTimer?.cancel();
    _toastTimer = Timer(const Duration(milliseconds: 3600), () {
      toast = null;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _toastTimer?.cancel();
    super.dispose();
  }
}
