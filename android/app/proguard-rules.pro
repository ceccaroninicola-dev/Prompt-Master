# ProGuard rules per IdeAI
# Mantieni le classi Flutter necessarie

# Google Mobile Ads — non rimuovere classi AdMob
-keep class com.google.android.gms.ads.** { *; }
-keep class com.google.ads.** { *; }

# Google UMP (User Messaging Platform) per consenso GDPR
-keep class com.google.android.ump.** { *; }

# Flutter — mantieni le classi del plugin
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Mantieni le annotazioni
-keepattributes *Annotation*

# Mantieni le classi serializzate (JSON parsing)
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}
