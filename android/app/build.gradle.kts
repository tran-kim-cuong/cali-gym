import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// 1. Khởi tạo đọc file key.properties
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.example.californiaflutter"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.californiaflutter"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            // Lấy đường dẫn file: ưu tiên biến từ Azure DevOps, nếu không có thì lấy từ file local
            val keystorePath = System.getenv("KEYSTORE_FILE_PATH") ?: keystoreProperties.getProperty("storeFile")
            val sPassword = System.getenv("STORE_PASSWORD") ?: keystoreProperties.getProperty("storePassword")
            val kPassword = System.getenv("KEY_PASSWORD") ?: keystoreProperties.getProperty("keyPassword")
            val kAlias = System.getenv("KEY_ALIAS") ?: keystoreProperties.getProperty("keyAlias")

            storeFile = if (keystorePath != null) file(keystorePath) else null
            storePassword = sPassword
            keyPassword = kPassword
            keyAlias = kAlias
        }
    }

    buildTypes {
        getByName("release") {
            // Sử dụng cấu hình release đã tạo ở trên
            signingConfig = signingConfigs.getByName("release")

            // Tối ưu hóa: R8/ProGuard (tùy chọn)
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

flutter {
    source = "../.."
}
