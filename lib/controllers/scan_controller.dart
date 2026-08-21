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
/// machine (paused-while-processing, multiplier stepper, toast-then-clear)
/// so the native scan flow feels identical to the web one.
class ScanController extends ChangeNotifier {
  ScanController(this._scanService);

  final ScanService _scanService;

  int multiplier = 1;
  bool processing = false;
  bool cameraPaused = false;
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

  Future<void> submitCode(String token, String code) =>
      _submit(token, (t) => _scanService.stamp(token: t, code: code, multiplier: multiplier));

  Future<void> _submit(String token, Future<ScanResult> Function(String) call) async {
    if (processing) return;
    processing = true;
    cameraPaused = true;
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

    _toastTimer?.cancel();
    _toastTimer = Timer(const Duration(milliseconds: 2800), () {
      toast = null;
      processing = false;
      cameraPaused = false;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _toastTimer?.cancel();
    super.dispose();
  }
}
