import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stampit_app/controllers/auth_controller.dart';
import 'package:stampit_app/controllers/coupons_controller.dart';
import 'package:stampit_app/controllers/redeem_controller.dart';
import 'package:stampit_app/controllers/scan_controller.dart';
import 'package:stampit_app/core/navigation.dart';
import 'package:stampit_app/core/theme.dart';
import 'package:stampit_app/services/auth_service.dart';
import 'package:stampit_app/services/coupon_service.dart';
import 'package:stampit_app/services/scan_service.dart';
import 'package:stampit_app/views/auth_gate.dart';

class StampItApp extends StatelessWidget {
  const StampItApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => AuthService()),
        Provider(create: (_) => ScanService()),
        Provider(create: (_) => CouponService()),
        ChangeNotifierProvider(
          create: (ctx) => AuthController(ctx.read<AuthService>())..bootstrap(),
        ),
        ChangeNotifierProvider(create: (ctx) => ScanController(ctx.read<ScanService>())),
        ChangeNotifierProvider(create: (ctx) => RedeemController(ctx.read<CouponService>())),
        ChangeNotifierProvider(create: (ctx) => CouponsController(ctx.read<CouponService>())),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'StampIt',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(AppColors.light),
        darkTheme: buildAppTheme(AppColors.dark),
        // Fixed-height layouts (e.g. the home screen tiles) are sized for
        // ~1.0x system font scale; some OEMs (OnePlus/OxygenOS) default to a
        // larger step than others (Samsung/One UI), which was overflowing
        // those tiles. Clamp so device font-size settings can't blow past it.
        builder: (context, child) => MediaQuery.withClampedTextScaling(
          minScaleFactor: 0.9,
          maxScaleFactor: 1.15,
          child: child!,
        ),
        home: const AuthGate(),
      ),
    );
  }
}
