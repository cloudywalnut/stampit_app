import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stampit_app/controllers/auth_controller.dart';
import 'package:stampit_app/controllers/coupons_controller.dart';
import 'package:stampit_app/controllers/redeem_controller.dart';
import 'package:stampit_app/core/currency.dart';
import 'package:stampit_app/core/theme.dart';
import 'package:stampit_app/models/coupon.dart';
import 'package:stampit_app/widgets/primary_button.dart';
import 'package:stampit_app/widgets/toast_banner.dart';

/// Redeem a coupon code and browse the retailer's coupons — mirrors the web
/// Coupons page (RedeemForm.tsx + CouponsList.tsx), over POST
/// /api/coupons/redeem and GET /api/coupons instead of Server Actions.
class RedeemView extends StatefulWidget {
  const RedeemView({super.key});

  @override
  State<RedeemView> createState() => _RedeemViewState();
}

class _RedeemViewState extends State<RedeemView> {
  final _codeController = TextEditingController();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final token = context.read<AuthController>().session!.token;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<CouponsController>().load(token);
    });
  }

  @override
  void dispose() {
    _codeController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _redeem() async {
    final token = context.read<AuthController>().session!.token;
    final redeem = context.read<RedeemController>();
    final coupons = context.read<CouponsController>();

    await redeem.redeem(token, _codeController.text);
    // The redeemed coupon moves from Available to Redeemed, so re-fetch.
    if (redeem.toast is RedeemSuccessToast) coupons.load(token, refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    final session = context.read<AuthController>().session!;
    final c = context.colors;

    return Scaffold(
      appBar: AppBar(title: const Text('Redeem')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: Consumer<RedeemController>(
            builder: (context, redeem, _) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: CustomScrollView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      slivers: [
                        SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Enter the customer\'s coupon code',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: c.ink,
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: _codeController,
                                enabled: !redeem.submitting,
                                maxLength: 6,
                                textCapitalization:
                                    TextCapitalization.characters,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 4,
                                ),
                                decoration: const InputDecoration(
                                  labelText: 'e.g. 8FEC69',
                                  counterText: '',
                                ),
                              ),
                              const SizedBox(height: 12),
                              PrimaryButton(
                                label: 'Redeem',
                                pendingLabel: 'Checking…',
                                loading: redeem.submitting,
                                onPressed: _redeem,
                              ),
                              const SizedBox(height: 28),
                            ],
                          ),
                        ),
                        _CouponsSection(
                          searchController: _searchController,
                          currency: session.currency,
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 16)),
                      ],
                    ),
                  ),
                  if (redeem.toast != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: _ToastCard(
                        toast: redeem.toast!,
                        currency: session.currency,
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Tabs + search + list, as slivers so they scroll with the redeem form above.
class _CouponsSection extends StatelessWidget {
  const _CouponsSection({
    required this.searchController,
    required this.currency,
  });

  final TextEditingController searchController;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final token = context.read<AuthController>().session!.token;

    return Consumer<CouponsController>(
      builder: (context, coupons, _) {
        final list = coupons.filtered;

        final Widget body;
        if (coupons.loading) {
          body = const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        } else if (coupons.error != null) {
          body = SliverToBoxAdapter(
            child: _EmptyBox(
              message: coupons.error!,
              action: TextButton(
                onPressed: () => coupons.load(token),
                child: const Text('Retry'),
              ),
            ),
          );
        } else if (list.isEmpty) {
          body = SliverToBoxAdapter(
            child: _EmptyBox(
              message:
                  coupons.query.isNotEmpty
                      ? 'No coupons match this search.'
                      : coupons.showRedeemed
                      ? 'No coupons redeemed yet.'
                      : 'No available coupons right now. One mints automatically every time a customer hits one of your reward bands.',
            ),
          );
        } else {
          body = SliverList.separated(
            itemCount: list.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder:
                (_, i) => _CouponCard(
                  coupon: list[i],
                  date: coupons.dateFor(list[i]),
                  currency: currency,
                ),
          );
        }

        return SliverMainAxisGroup(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: _StatusTabs(
                      showRedeemed: coupons.showRedeemed,
                      onChanged: coupons.setShowRedeemed,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: searchController,
                    onChanged: coupons.setQuery,
                    decoration: InputDecoration(
                      hintText: 'Search coupon code or customer name',
                      hintStyle: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: c.inkSoft,
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        size: 20,
                        color: c.inkSoft,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      border: _pillBorder(c.border),
                      enabledBorder: _pillBorder(c.border),
                      focusedBorder: _pillBorder(c.accent),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            body,
          ],
        );
      },
    );
  }

  OutlineInputBorder _pillBorder(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(999),
    borderSide: BorderSide(color: color, width: 2),
  );
}

/// Redeemed / Available pill toggle — mirrors the web tab group.
class _StatusTabs extends StatelessWidget {
  const _StatusTabs({required this.showRedeemed, required this.onChanged});

  final bool showRedeemed;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    Widget tab(String label, bool selected, VoidCallback onTap) =>
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
            decoration: BoxDecoration(
              color: selected ? c.ink : Colors.transparent,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: selected ? c.background : c.inkSoft,
              ),
            ),
          ),
        );

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        border: Border.all(color: c.border, width: 2),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          tab('Redeemed', showRedeemed, () => onChanged(true)),
          tab('Available', !showRedeemed, () => onChanged(false)),
        ],
      ),
    );
  }
}

class _EmptyBox extends StatelessWidget {
  const _EmptyBox({required this.message, this.action});

  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: c.border, width: 2),
      ),
      child: Column(
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: c.inkSoft,
            ),
          ),
          if (action != null) action!,
        ],
      ),
    );
  }
}

class _CouponCard extends StatelessWidget {
  const _CouponCard({
    required this.coupon,
    required this.date,
    required this.currency,
  });

  final Coupon coupon;
  final DateTime date;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final dateLabel = MaterialLocalizations.of(
      context,
    ).formatShortDate(date.toLocal());

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: c.border, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  coupon.code,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                    color: c.ink,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color:
                      coupon.redeemed
                          ? c.border
                          : c.brand.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  coupon.redeemed ? 'Redeemed' : 'Available',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: coupon.redeemed ? c.inkSoft : c.ink,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            coupon.customerName ?? '—',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: c.ink,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            formatDiscount(coupon.discountType, coupon.discountValue, currency),
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: c.ink,
            ),
          ),
          if (coupon.description.isNotEmpty)
            Text(
              coupon.description,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: c.inkSoft,
              ),
            ),
          const SizedBox(height: 8),
          Text(
            '${coupon.redeemed ? 'Redeemed' : 'Earned'} $dateLabel',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: c.inkSoft,
            ),
          ),
        ],
      ),
    );
  }
}

class _ToastCard extends StatelessWidget {
  const _ToastCard({required this.toast, required this.currency});

  final RedeemToast toast;
  final String currency;

  @override
  Widget build(BuildContext context) {
    if (toast is RedeemErrorToast) {
      return ToastBanner(
        isError: true,
        child: Text((toast as RedeemErrorToast).message),
      );
    }

    final result = (toast as RedeemSuccessToast).result;
    return ToastBanner(
      isError: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Coupon redeemed!'),
          const SizedBox(height: 4),
          Text(
            formatDiscount(result.discountType, result.discountValue, currency),
          ),
          if (result.description.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              result.description,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
          const SizedBox(height: 8),
          const Text(
            'Give this to the customer',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
