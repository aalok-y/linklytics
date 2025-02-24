plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.linklytics"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "28.0.13004108"  // Match the installed NDK version

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.linklytics" // Your unique application ID
        minSdk = flutter.minSdkVersion // Use the Flutter version value
        targetSdk = flutter.targetSdkVersion // Use the Flutter version value
        versionCode = 1 // Increment this version with every release
        versionName = "1.0.0" // The version string seen by users
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
