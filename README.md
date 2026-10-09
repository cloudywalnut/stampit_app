# stampit_app — Android build & release notes

Flutter staff app for StampIt (scan/redeem). This file documents the
Android toolchain versions, how to produce a new release build, and —
most importantly — why the signing key can never change once this app is
live on Play Store. App structure and backend wiring live in `memory.md`.

## Versions this project actually uses

| Component | Version | Where it's set |
|---|---|---|
| Flutter | 3.29.3 (stable) | machine-wide install |
| Dart SDK | ^3.7.2 | `pubspec.yaml` |
| `compileSdk` / `targetSdk` | 36 (Android 16) | `android/build.gradle.kts` — Flutter default is 35; Google Play requires 36 |
| `minSdk` | 24 (Android 7.0) | `android/build.gradle.kts` — Flutter default is 21; Play Console rejected < 24. Also `min_sdk_android` for `flutter_launcher_icons` |
| NDK | 27.0.12077973 | `android/build.gradle.kts` — Flutter default is 26.3.11579264; 27 is what the plugins request |
| Android Gradle Plugin | 8.7.0 | `android/settings.gradle.kts` (Flutter default) |
| Kotlin | 1.8.22 | `android/settings.gradle.kts` (Flutter default) |
| Gradle wrapper | 8.10.2 | `android/gradle/wrapper/gradle-wrapper.properties` (Flutter default) |
| Java/Kotlin target | 11 | `android/app/build.gradle.kts` (Flutter default) |
| Build tools | 34.0.0 | Not set — Android Gradle Plugin 8.7.0's default |

`compileSdk`, `minSdk` and NDK are defined once in `android/build.gradle.kts`
and applied to both the app and every Flutter plugin, so the whole build
uses one value for each. Change them only there. After upgrading past
Flutter 3.35 (which defaults to 36), the 36 override becomes redundant.

`mobile_scanner`'s constraint is `^7.0.0`, currently resolving to `7.0.1`.

**Local machine's Android SDK** (`C:\Users\mzm\AppData\Local\Android\sdk`):

| What | Version | Where it comes from | Used by the app? |
|---|---|---|---|
| SDK platform | 35 | Flutter's default | No |
| SDK platform | 36 | We added it | Yes |
| Build tools | 34.0.0 | Default (through the Android Gradle Plugin) | Yes |
| Build tools | 35.0.1 | Neither — probably Android Studio | No |
| NDK | 26.3.11579264 | Flutter's default | No |
| NDK | 27.0.12077973 | We added it | Yes |

Also installed: `platform-tools` (adb — used for connecting phones) and
CMake 3.22.1 (unused). The unused items total ~2.3 GB, mostly NDK 26.3.

### How a release build happens, step by step

1. **Flutter** reads `pubspec.yaml` (app version, packages).
2. **Gradle** + **Android Gradle Plugin** take over and read the settings
   (compileSdk 36, minSdk 24, targetSdk 36, NDK 27).
3. **Dart code** is compiled by Flutter into native phone code.
4. **Plugins' Android code** is compiled by Kotlin/Java against Android 36.
5. **NDK** trims the native parts (Flutter engine, compiled Dart).
6. **R8** shrinks unused Java/Kotlin code.
7. **Build tools** pack code, icons and settings into one file (minSdk and
   targetSdk get written in here).
8. **Signing** with the upload key from `key.properties` → `app-release.aab`.
9. **Play** checks it, re-signs with Google's key, and makes per-phone APKs.

## Building a new release AAB

```
flutter clean
flutter pub get
flutter build appbundle --release
```

- `flutter clean` isn't strictly required for a plain code change, but is
  good practice before a release build to rule out stale build cache.
- Output: `build/app/outputs/bundle/release/app-release.aab`, signed
  automatically using whatever `android/key.properties` points to (see
  below). R8 shrinking/obfuscation runs automatically on release builds
  (mapping file lands in `build/app/outputs/mapping/release/`) — this is
  the Flutter Gradle plugin's default for the release build type, nothing
  extra to configure.
- For local testing on a device instead of a Play Store upload, `flutter
  build apk --release` produces `build/app/outputs/flutter-apk/app-release.apk`.

**Current version:** `1.1.0+7` (versionCode 6 was used on closed testing).

**Before every upload to Play Console** (any track), bump the version in `pubspec.yaml`:

```
version: 1.0.1+3
         ^^^^^ ^
         |     versionCode — must strictly increase on every upload,
         |     or Play Console rejects it outright.
         versionName — cosmetic, shown to users, bump however makes sense
         (patch/minor/major).
```

## Why the signing key can never change

Once the first release AAB is uploaded to Play Console, that app listing is
tied to the signing key. **Every future upload must be signed with the same
key**, or Play Console rejects it outright — no override.

This app is built and uploaded as an `.aab` (Android App Bundle), which
Google has required for all new apps since 2021 — and **uploading an AAB
is only possible with Play App Signing enabled; there's no way to opt
out.** That matters a lot here: it means Google, not this machine, holds
the actual certificate that signs what reaches users. What lives in
`key.properties` / `stampit-upload-key.jks` is only the **upload key** —
proof to Google that an upload really comes from you, not the thing that
signs the final app.

Concretely, that means these must never change for the life of this app:

- **`android/key.properties`** — `keyAlias`, `keyPassword`, `storePassword`,
  and the `storeFile` path. Gitignored on purpose (it's a secret) and not
  committed anywhere.
- **The actual keystore file it points to** — currently
  `C:\Users\mzm\stampit-upload-key.jks`, which lives outside this repo
  entirely and is not checked in.

**Losing this file is a real hassle, but not catastrophic — because Play
App Signing is active.** If it's lost (this machine dies, the file gets
deleted, whatever), you're not locked out forever and you don't need a new
app listing: Play Console → this app → Setup → App integrity → **"Request
upload key reset."** You verify you're the legitimate owner, Google
processes the request, and you get a new upload key while keeping the same
app listing and the same real signing certificate underneath. Historically
this review takes Google a few business days, and you can't publish
updates while it's pending.

**Back this up anyway** (password manager, encrypted drive, wherever) —
avoiding a multi-day publishing freeze and an identity-verification process
is reason enough, even though it's no longer an unrecoverable dead end.
