plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.flutter_application_1"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // Mengaktifkan fitur desugaring untuk mendukung API Java 8+ di Android lama
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        // Menyamakan target JVM dengan Java 17
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.example.flutter_application_1"
        
        // Memungkinkan aplikasi memiliki lebih banyak method (penting untuk app kompleks)
        multiDexEnabled = true

        // DISARANKAN: Ubah dari flutter.minSdkVersion ke 21 secara manual
        minSdk = flutter.minSdkVersion 
        targetSdk = flutter.targetSdkVersion

        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // Menggunakan debug config untuk testing release sementara
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Library pendukung untuk desugaring (WAJIB ADA)
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}
