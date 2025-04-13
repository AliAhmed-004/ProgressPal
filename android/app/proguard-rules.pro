# Flutter related
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# flutter_local_notifications plugin
-keep class com.dexterous.** { *; }

# Needed for Gson serialization (used by flutter_local_notifications internally)
-keep class com.google.gson.** { *; }
-keep class com.google.gson.reflect.TypeToken
-keepattributes Signature
-keepattributes *Annotation*

# Keep generic type info (needed for deserialization)
-keep class * extends java.lang.annotation.Annotation { *; }

# AndroidX and support libs (general stability)
-keep class androidx.** { *; }
-dontwarn androidx.**

# Prevent obfuscation of data models (if any exist and are serialized)
# You can be more specific based on your own data models
-keep class your.package.name.** { *; }

# (Optional) If youre using WorkManager, AlarmManager, or any Android service in the background:
-keep class android.app.AlarmManager { *; }
-keep class android.app.job.JobScheduler { *; }

# Prevent stripping of notification-related classes
-keep class android.app.Notification { *; }
-keep class android.app.NotificationManager { *; }

# Optional: disable code shrinking for debugging
# (for final release, remove or set to false in build.gradle.kts)
# isMinifyEnabled = false
# isShrinkResources = false
# Flutter dynamic feature loading support (SplitCompat)
-keep class com.google.android.play.** { *; }
-dontwarn com.google.android.play.**

# Keep Flutter classes related to deferred components
-keep class io.flutter.embedding.engine.deferredcomponents.** { *; }
-dontwarn io.flutter.embedding.engine.deferredcomponents.**

