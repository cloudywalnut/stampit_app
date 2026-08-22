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
  **Currently pointed at a LAN dev IP** (`http://192.168.68.8:3000`), not the
  production `https://stampit.digital` — this needs to be swapped back before
  shipping a release build.

## Android build config

- `compileSdk` / `targetSdk`: 35 (Flutter's default for this SDK version,
  taken from `flutter.compileSdkVersion` / `flutter.targetSdkVersion` —
  not pinned explicitly in `build.gradle.kts`)
- `minSdk`: 21 (Flutter default; `flutter_launcher_icons` config also sets
  `min_sdk_android: 21`)
- NDK: `ndkVersion = flutter.ndkVersion` → resolves to **26.3.11579264**
  (Flutter 3.29.3's bundled default). Not overridden in `build.gradle.kts`.
- Java/Kotlin target: 11
- Gradle wrapper: 8.10.2 (`android/gradle/wrapper/gradle-wrapper.properties`)
- `mobile_scanner` is pinned to exact `7.0.1` (not `^7.0.0`) — every release
  from 7.1.0 onward bumps the plugin's own `compileSdk` requirement to 36,
  above what this Flutter SDK's default Android toolchain (compileSdk 35 /
  AGP 8.7.0) supports. 7.0.1 is the newest release still on compileSdk 35.

### Signing / release build

- Release signing config reads `android/key.properties`
  (`keyAlias`, `keyPassword`, `storeFile`, `storePassword`) — this file is
  gitignored and kept locally, not committed to the repo. No keystore file
  is checked in either.
- App version: `1.0.0+1` (`pubspec.yaml`), i.e. versionName 1.0.0 /
  versionCode 1.

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
