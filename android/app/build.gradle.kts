plugins {
    id("com.android.application")
    id("kotlin-android")
    // Il Flutter Gradle Plugin va applicato dopo Android e Kotlin
    id("dev.flutter.flutter-gradle-plugin")
}

// Leggi il keystore di rilascio da key.properties (se presente)
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = java.util.Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(keystorePropertiesFile.inputStream())
}

android {
    namespace = "com.cortexlabs.ideai"
    compileSdk = 35
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.cortexlabs.ideai"
        minSdk = 21
        targetSdk = 34
        versionCode = 1
        versionName = "1.0.0"
        // Necessario per google_mobile_ads (multidex su API < 21 non serve con minSdk 21)
        multiDexEnabled = true
    }

    // Configurazione firma di rilascio
    signingConfigs {
        if (keystorePropertiesFile.exists()) {
            create("release") {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            // Usa il keystore di rilascio se disponibile, altrimenti debug
            signingConfig = if (keystorePropertiesFile.exists()) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
            // Abilita R8/ProGuard per ridurre la dimensione dell'APK
            isMinifyEnabled = true
            isShrinkResources = true
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
