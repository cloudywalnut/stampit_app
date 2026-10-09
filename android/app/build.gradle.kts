import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(keystorePropertiesFile.inputStream())
}

val stampitCompileSdk: Int by rootProject.extra
val stampitMinSdk: Int by rootProject.extra
val stampitNdkVersion: String by rootProject.extra

android {
    namespace = "digital.stampit.stampit_app"
    // compileSdk, minSdk, targetSdk and ndkVersion come from the root
    // android/build.gradle.kts, which also forces them onto every plugin.
    // None are Flutter 3.29.3 defaults (35 / 21 / 35 / 26.3.11579264):
    // Google Play requires targetSdk 36 and minSdk 24, and NDK 27 is what
    // the plugins' AGP 8.7.0 asks for.
    compileSdk = stampitCompileSdk
    ndkVersion = stampitNdkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "digital.stampit.stampit_app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = stampitMinSdk
        targetSdk = stampitCompileSdk
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String?
            keyPassword = keystoreProperties["keyPassword"] as String?
            storeFile = keystoreProperties["storeFile"]?.let { file(it) }
            storePassword = keystoreProperties["storePassword"] as String?
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}
