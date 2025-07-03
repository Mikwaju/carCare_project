plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.carcare"
    compileSdk = 35 // Replace with your actual compileSdk version
    ndkVersion = "27.0.12077973"

    defaultConfig {
        applicationId = "com.example.carcare"
        minSdk = 23
        targetSdk = 35 // Replace with your actual targetSdk version
        versionCode = 1 // Replace with your actual versionCode
        versionName = "1.0" // Replace with your actual versionName
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    buildTypes {
        release {
            // If you want to enable resource shrinking, enable minify too:
            isMinifyEnabled = true          // Enable code shrinking
            isShrinkResources = true        // Enable resource shrinking

            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
