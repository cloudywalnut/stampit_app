# stampit_app — Android build & release notes

Flutter staff app for StampIt (scan/redeem). This file documents the
Android toolchain versions, how to produce a new release build, and —
most importantly — why the signing key can never change once this app is
live on Play Store.

## Versions this project actually uses

| Component | Version | Where it's set |
|---|---|---|
| Flutter | 3.29.3 (stable) | machine-wide install |
| Dart SDK | ^3.7.2 | `pubspec.yaml` |
| `compileSdk` / `targetSdk` | 36 (Android 16) | Hardcoded in `build.gradle.kts` (Google Play requires targeting API 36 for uploads) |
| `minSdk` | 21 (Android 5.0) | Flutter's own default; also set explicitly for `flutter_launcher_icons` |
| NDK | 26.3.11579264 | Flutter 3.29.3's bundled default (`ndkVersion = flutter.ndkVersion`) |
| Gradle wrapper | 8.10.2 | `android/gradle/wrapper/gradle-wrapper.properties` |
| Java/Kotlin target | 11 | `build.gradle.kts` |

**`compileSdk`/`targetSdk` are the only hand-picked values** — everything
else is what Flutter 3.29.3 asks Gradle for by default. Once this project
upgrades past Flutter 3.35 (which defaults to compileSdk/targetSdk 36
itself), the override can revert to
`flutter.compileSdkVersion`/`flutter.targetSdkVersion`.

`mobile_scanner`'s constraint is `^7.0.0`, currently resolving to `7.0.1`.

**Known gap, not yet hit:** several plugins (`mobile_scanner`, `app_links`,
`path_provider_android`, `shared_preferences_android`, `url_launcher_android`)
request NDK `27.0.12077973`, above the `26.3.11579264` this project pins.
Gradle falls back and builds fine (warning only, not an error). If a future
plugin bump turns this into a hard requirement, install NDK 27 via Android
Studio's SDK Manager (or `sdkmanager` once `cmdline-tools` is installed)
and add `ndkVersion = "27.0.12077973"` under `android { }` in
`android/app/build.gradle.kts`.

**Local machine's Android SDK has**: platforms `android-35` and
`android-36`, build-tools `34.0.0` and `35.0.1` — all required by this
toolchain.

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

**Before every upload to Play Console**, bump the version in `pubspec.yaml`:

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
