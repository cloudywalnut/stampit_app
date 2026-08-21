import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stampit_app/controllers/auth_controller.dart';
import 'package:stampit_app/controllers/redeem_controller.dart';
import 'package:stampit_app/core/currency.dart';
import 'package:stampit_app/core/theme.dart';
import 'package:stampit_app/widgets/primary_button.dart';
import 'package:stampit_app/widgets/toast_banner.dart';

/// Redeem a coupon code — mirrors RedeemForm.tsx, over POST
/// /api/coupons/redeem instead of the redeemCoupon Server Action.
class RedeemView extends StatefulWidget {
  const RedeemView({super.key});

  @override
  State<RedeemView> createState() => _RedeemViewState();
}

class _RedeemViewState extends State<RedeemView> {
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = context.read<AuthController>().session!;
    final c = context.colors;

    return Scaffold(
      appBar: AppBar(title: const Text('Redeem')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Consumer<RedeemController>(
            builder: (context, redeem, _) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Enter the customer\'s coupon code',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: c.ink),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _codeController,
                    maxLength: 6,
                    textCapitalization: TextCapitalization.characters,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: 4),
                    decoration: const InputDecoration(labelText: 'e.g. 8FEC69', counterText: ''),
                  ),
                  const SizedBox(height: 12),
                  PrimaryButton(
                    label: 'Redeem',
                    pendingLabel: 'Checking…',
                    loading: redeem.submitting,
                    onPressed: () => redeem.redeem(session.token, _codeController.text),
                  ),
                  const Spacer(),
                  if (redeem.toast != null) _buildToast(redeem.toast!, session.currency),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildToast(RedeemToast toast, String currency) {
    if (toast is RedeemErrorToast) {
      return ToastBanner(isError: true, child: Text(toast.message));
    }

    final result = (toast as RedeemSuccessToast).result;
    return ToastBanner(
      isError: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Coupon redeemed!'),
          const SizedBox(height: 4),
          Text(formatDiscount(result.discountType, result.discountValue, currency)),
          if (result.description.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(result.description, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
          const SizedBox(height: 8),
          const Text('Give this to the customer', style: TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
