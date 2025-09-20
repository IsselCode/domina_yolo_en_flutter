# ========= FLUTTER BÁSICO =========
# Mantener código de Flutter/Dart
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }
-dontwarn io.flutter.embedding.**

# ========= FIREBASE =========
# Mantener clases de Firebase
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# ========= ML KIT =========
# Mantener clases necesarias para ML Kit
-keep class com.google.mlkit.** { *; }
-dontwarn com.google.mlkit.**

# ========= IMAGE PICKER =========
-keep class io.flutter.plugins.imagepicker.** { *; }

# ========= ULTRALYTICS / YOLO =========
# Mantener toda la librería de ultralytics y dependencias de snakeyaml
-keep class org.yaml.snakeyaml.** { *; }
-dontwarn org.yaml.snakeyaml.**
-dontwarn java.beans.**

# ========= KOTLIN REFLECTION =========
# Necesario para que no elimine metadata usada por algunas librerías
-keep class kotlin.Metadata { *; }

# ========= OTROS =========
# Mantener enums (importante si usas switch-case en Dart/Java)
-keepclassmembers enum * { *; }

# Evitar advertencias de anotaciones
-dontwarn javax.annotation.**
