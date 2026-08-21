import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:stampit_app/controllers/auth_controller.dart';
import 'package:stampit_app/controllers/scan_controller.dart';
import 'package:stampit_app/widgets/toast_banner.dart';

/// Native camera scan — mirrors ScanClient.tsx: point-and-scan a customer's
/// Wallet QR, or fall back to a 6-char manual code, with a stamp multiplier.
class ScanView extends StatefulWidget {
  const ScanView({super.key});

  @override
  State<ScanView> createState() => _ScanViewState();
}

class _ScanViewState extends State<ScanView> {
  final _codeController = TextEditingController();
  final _cameraController = MobileScannerController(facing: CameraFacing.back);

  void _handleDetect(BarcodeCapture capture, ScanController scan, String token) {
    final value = capture.barcodes.isNotEmpty ? capture.barcodes.first.rawValue : null;
    if (value == null || scan.processing) return;
    scan.submitObjectId(token, value);
  }

  void _handleManualSubmit(ScanController scan, String token) {
    final code = _codeController.text.trim();
    if (code.isEmpty) return;
    scan.submitCode(token, code);
    _codeController.clear();
  }

  @override
  void dispose() {
    _codeController.dispose();
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final token = context.read<AuthController>().session!.token;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Consumer<ScanController>(
        builder: (context, scan, _) {
          return Stack(
            fit: StackFit.expand,
            children: [
              MobileScanner(controller: _cameraController, onDetect: (c) => _handleDetect(c, scan, token)),

              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          IconButton(
                            style: IconButton.styleFrom(backgroundColor: Colors.black54, foregroundColor: Colors.white),
                            icon: const Icon(Icons.arrow_back),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          const Spacer(),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _InstructionPill(),
                      const SizedBox(height: 12),
                      _ManualEntryBar(
                        controller: _codeController,
                        multiplier: scan.multiplier,
                        onIncrement: scan.incrementMultiplier,
                        onDecrement: scan.decrementMultiplier,
                        onSubmit: () => _handleManualSubmit(scan, token),
                      ),
                    ],
                  ),
                ),
              ),

              if (scan.toast != null)
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: 32,
                  child: _buildToast(scan.toast!),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildToast(ScanToast toast) {
    if (toast is ScanErrorToast) {
      return ToastBanner(isError: true, child: Text(toast.message));
    }

    final result = (toast as ScanSuccessToast).result;
    if (result.couponEarned) {
      return ToastBanner(
        isError: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(result.coupons.length > 1 ? '${result.coupons.length} coupons earned!' : 'Coupon earned!'),
            const SizedBox(height: 4),
            Text('${result.stamps} stamps total'),
            const SizedBox(height: 4),
            ...result.coupons.map(
              (coupon) => Text(
                coupon.description.isEmpty ? coupon.code : '${coupon.code} — ${coupon.description}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      );
    }

    return ToastBanner(
      isError: false,
      child: Text('+${result.addedStamps} stamp${result.addedStamps == 1 ? '' : 's'} — ${result.stamps} total'),
    );
  }
}

class _InstructionPill extends StatelessWidget {
  const _InstructionPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(999)),
      child: const Text(
        "Point the camera at a customer's wallet QR",
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _ManualEntryBar extends StatelessWidget {
  const _ManualEntryBar({
    required this.controller,
    required this.multiplier,
    required this.onIncrement,
    required this.onDecrement,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final int multiplier;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(999)),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              maxLength: 6,
              textCapitalization: TextCapitalization.characters,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, letterSpacing: 2),
              decoration: const InputDecoration(
                filled: false,
                border: InputBorder.none,
                counterText: '',
                hintText: 'No QR? — Enter code',
                hintStyle: TextStyle(color: Colors.white54, fontWeight: FontWeight.w500, letterSpacing: 0),
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
              ),
              onSubmitted: (_) => onSubmit(),
            ),
          ),
          const SizedBox(width: 8),
          _MultiplierStepper(value: multiplier, onIncrement: onIncrement, onDecrement: onDecrement),
          const SizedBox(width: 8),
          IconButton(
            style: IconButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
            icon: const Icon(Icons.check),
            onPressed: onSubmit,
          ),
        ],
      ),
    );
  }
}

class _MultiplierStepper extends StatelessWidget {
  const _MultiplierStepper({required this.value, required this.onIncrement, required this.onDecrement});

  final int value;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.remove, color: Colors.white, size: 18),
            onPressed: onDecrement,
          ),
          SizedBox(
            width: 22,
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.add, color: Colors.white, size: 18),
            onPressed: onIncrement,
          ),
        ],
      ),
    );
  }
}
