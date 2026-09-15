import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stampit_app/controllers/auth_controller.dart';
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
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'StampIt',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(AppColors.light),
        darkTheme: buildAppTheme(AppColors.dark),
        home: const AuthGate(),
      ),
    );
  }
}
