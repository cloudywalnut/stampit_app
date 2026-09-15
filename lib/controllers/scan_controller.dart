import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:stampit_app/models/scan_result.dart';
import 'package:stampit_app/services/api_exception.dart';
import 'package:stampit_app/services/scan_service.dart';

sealed class ScanToast {}

class ScanSuccessToast extends ScanToast {
  final ScanResult result;
  ScanSuccessToast(this.result);
}

class ScanErrorToast extends ScanToast {
  final String message;
  ScanErrorToast(this.message);
}

/// The "Controller" behind the Scan screen — mirrors ScanClient.tsx's state
/// machine (multiplier stepper, submit-while-processing, toast-then-clear)
/// so the native scan flow feels identical to the web one.
class ScanController extends ChangeNotifier {
  ScanController(this._scanService);

  final ScanService _scanService;

  int multiplier = 1;
  bool processing = false;
  ScanToast? toast;

  Timer? _toastTimer;

  void incrementMultiplier() {
    multiplier += 1;
    notifyListeners();
  }

  void decrementMultiplier() {
    if (multiplier > 1) multiplier -= 1;
    notifyListeners();
  }

  Future<void> submitObjectId(String token, String objectId) => _submit(
    token,
    (t) => _scanService.stamp(token: t, objectId: objectId, multiplier: multiplier),
  );

  Future<void> submitCode(String token, String code) {
    final trimmed = code.trim();
    if (trimmed.isEmpty) return Future.value();
    return _submit(token, (t) => _scanService.stamp(token: t, code: trimmed, multiplier: multiplier));
  }

  Future<void> _submit(String token, Future<ScanResult> Function(String) call) async {
    if (processing) return;
    processing = true;
    notifyListeners();

    try {
      final result = await call(token);
      toast = ScanSuccessToast(result);
    } on ApiException catch (e) {
      toast = ScanErrorToast(e.message);
    } catch (_) {
      toast = ScanErrorToast('Network error. Try again.');
    }
    notifyListeners();

    // Unlike Redeem's submitting flag, processing stays true through the
    // whole toast window rather than clearing right after the response:
    // onDetect keeps firing continuously from the live camera feed, and the
    // just-scanned QR typically stays in frame for a beat afterward — this
    // is a deliberate cooldown so that doesn't re-trigger extra stamps for
    // what was physically one scan. Redeem/Login have no such continuous
    // re-trigger source (a single manual tap), so they don't need this.
    _toastTimer?.cancel();
    _toastTimer = Timer(const Duration(milliseconds: 2800), () {
      toast = null;
      processing = false;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _toastTimer?.cancel();
    super.dispose();
  }
}
