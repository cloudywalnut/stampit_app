# stampit_app — current state

Flutter staff app for StampIt: scan customer QR codes and redeem coupons on
the go. Companion to the `stampit/` Next.js web app — same Supabase project.

## Stack

- Flutter 3.29.3 (stable channel), Dart SDK ^3.7.2
- State management: `provider` (ChangeNotifier controllers, manual DI via
  `MultiProvider` in `lib/app.dart`)
- Backend: Supabase (`supabase_flutter`) for auth/session, plus a REST API
  hosted by the `stampit/` web app for scan/redeem business logic
- Package: `digital.stampit.stampit_app`

## Screens / architecture

MVC-ish layering: `views/` (UI) → `controllers/` (ChangeNotifier) →
`services/` (API/Supabase calls) → `models/`.

- Auth: `auth_gate.dart` routes between welcome / login / staff login and the
  authenticated app based on `AuthController`
- Scan: `scan_view.dart` + `ScanController` + `ScanService` — QR scanning via
  `mobile_scanner`
- Redeem: `redeem_view.dart` + `RedeemController` + `CouponService` — the
  web Coupons page's counterpart: the redeem form on top, then the coupon list
  below (Redeemed/Available tabs, search by code or customer name, all
  client-side over one `GET /api/coupons` fetch via `CouponsController`;
  re-fetched after a successful redeem)
- Home: `home_view.dart`

## Backend wiring (`lib/core/constants.dart`)

- Supabase URL/anon key: same project the web app uses (anon key is public by
  design; RLS does the actual access control)
- `webBaseUrl` — the web app also hosts the REST routes this app calls
  (`/api/scan`, `/api/staff-login`, `/api/coupons`, `/api/coupons/redeem`,
  `/api/me`).
  Points at production `https://stampit.digital`; swap to a LAN IP
  (`http://<laptop-IP>:3000`) only temporarily for local dev-server testing
  on a physical device, then swap back before any release build.
- `ApiClient.onUnauthorized` (wired up in `AuthController`'s constructor) +
  the global `navigatorKey` in `lib/core/navigation.dart`: any authenticated
  API call (one that sent a Bearer token) coming back 401 forces a sign-out
  and pops back to the root route, so an expired/revoked token (staff JWTs
  expire after 12h server-side, no refresh) bounces the user to the login
  screen instead of leaving whatever screen was open stuck on a raw
  "Not signed in." error.

## Android build config, versions, release & signing

See `README.md` — it is the single place for SDK/NDK versions (and which
are Flutter defaults), the release build steps, app version, and signing.
