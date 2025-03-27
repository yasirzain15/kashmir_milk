# ====================== FLUTTER CORE PROTECTION ======================
-keep class io.flutter.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class com.example.kashmeer_milk.** { *; }

# ================= PLAY CORE PROTECTION (OPTIMIZED) =================
# Keep only the specific Play Core packages you need
-keep class com.google.android.play.core.tasks.** { *; }
-keep interface com.google.android.play.core.tasks.** { *; }

# For deferred components (if used)
-keep class com.google.android.play.core.splitinstall.** { *; }
-keep class com.google.android.play.core.splitcompat.** { *; }

# ================== FLUTTER ENGINE PROTECTION ========================
-keep class io.flutter.embedding.engine.** { *; }
-keep class io.flutter.embedding.engine.deferredcomponents.** { *; }

# ================= PLATFORM CHANNEL PROTECTION ======================
-keep class * extends io.flutter.plugin.common.MethodCallHandler { *; }
-keep class * implements io.flutter.plugin.common.PluginRegistry$Plugin { *; }

# ==================== FIREBASE PROTECTION ===========================
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# ==================== ESSENTIAL ANNOTATIONS =========================
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes InnerClasses

# ================= ANDROID COMPONENT PROTECTION =====================
-keep public class * extends android.app.Activity
-keep public class * extends android.app.Application
-keep public class * extends android.app.Service

# ================== RESOURCE PROTECTION =============================
-keepclassmembers class **.R$* {
    public static <fields>;
}

# ================ DUPLICATE CLASSES RESOLUTION ======================
# Add these to prevent conflicts between Play Core versions
-dontwarn com.google.android.play.core.**
-dontwarn com.google.android.play.**