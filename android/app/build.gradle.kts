plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android") // correct plugin for Kotlin DSL
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.cruddy_app"
    compileSdk = 35
    ndkVersion = "27.0.12077973"

    defaultConfig {
        applicationId = "com.example.cruddy_app"
        minSdk = 21
        targetSdk = 35
        versionCode = 1
        versionName = "1.0"
    }

    buildTypes {
        getByName("release") {
            // resource shrinking requires code shrinking
            isMinifyEnabled = false   // disable code shrinking
            isShrinkResources = false // disable resource shrinking

            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }
}

flutter {
    source = "../.."
}
