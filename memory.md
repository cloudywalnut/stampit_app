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
- Redeem: `redeem_view.dart` + `RedeemController` + `CouponService`
- Home: `home_view.dart`

## Backend wiring (`lib/core/constants.dart`)

- Supabase URL/anon key: same project the web app uses (anon key is public by
  design; RLS does the actual access control)
- `webBaseUrl` — the web app also hosts the REST routes this app calls
  (`/api/scan`, `/api/staff-login`, `/api/coupons/redeem`, `/api/me`).
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

## Android build config

- `compileSdk` / `targetSdk`: **36**, hardcoded in `build.gradle.kts`
  (Google Play requires targeting API 36 for uploads). Flutter's own
  default (`flutter.compileSdkVersion`/`targetSdkVersion`) only reaches 36
  starting Flutter 3.35 — revert to those once this project upgrades past
  that.
- `minSdk`: 21 (Flutter default; `flutter_launcher_icons` config also sets
  `min_sdk_android: 21`)
- NDK: `ndkVersion = flutter.ndkVersion` → resolves to **26.3.11579264**.
  Not overridden in `build.gradle.kts`. Several plugins (`app_links`,
  `mobile_scanner`, `path_provider_android`, `shared_preferences_android`,
  `url_launcher_android`) request `27.0.12077973` instead — Gradle warns
  but builds fine on 26.3.11579264. If a future plugin bump makes 27 a hard
  requirement, add `ndkVersion = "27.0.12077973"` under `android { }`.
- Java/Kotlin target: 11
- Gradle wrapper: 8.10.2 (`android/gradle/wrapper/gradle-wrapper.properties`)
- `mobile_scanner` constraint: `^7.0.0`, currently resolving to `7.0.1`.
- Local Android SDK (`C:\Users\mzm\AppData\Local\Android\sdk`) has
  platforms `android-35`/`android-36` and build-tools `34.0.0`/`35.0.1`
  installed — all required by this toolchain, none of it unused cruft.

### Signing / release build

- Release signing config reads `android/key.properties`
  (`keyAlias`, `keyPassword`, `storeFile`, `storePassword`) — this file is
  gitignored and kept locally, not committed to the repo. No keystore file
  is checked in either.
- App version: `1.0.1+3` (`pubspec.yaml`), i.e. versionName 1.0.1 /
  versionCode 3. **Already published to Play Console once** (the `+1`
  build) — `versionCode` must strictly increase on every future upload, or
  Play Console rejects it; `versionName` can be bumped however makes sense.

### How the AAB is built

Standard Flutter release flow, no custom scripts/CI wired up yet:

```
flutter build appbundle --release
```

This produces `build/app/outputs/bundle/release/app-release.aab`, signed
with whatever `android/key.properties` points to. R8 shrinking/obfuscation
runs on release builds (mapping output lands in
`build/app/outputs/mapping/release/`), even though `minifyEnabled` isn't set
explicitly in `build.gradle.kts` — this is the Flutter Gradle plugin's
default for the release build type.

A plain `flutter build apk --release` also works for local testing
(`build/app/outputs/flutter-apk/app-release.apk`).
