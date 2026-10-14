# Post Reader & Favorites (Flutter)

## Run it
```bash
flutter create . --project-name post_reader_favorites   # generates android/ios/web folders (keeps lib/ & pubspec.yaml)
flutter pub get
flutter run
```

### Android: internet permission
Open `android/app/src/main/AndroidManifest.xml` and add this line above `<application ...>`:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
```
(macOS desktop builds need the `com.apple.security.network.client` entitlement.)

## Structure
```
lib/
  main.dart                    Hive init + named routes
  constants.dart               route names, box name, API url
  models/post.dart
  theme/app_theme.dart         ThemeData (colors, fonts, buttons, inputs)
  screens/posts_screen.dart    GET list + POST dialog  (route '/')
  screens/post_details_screen  details + Save button   (route '/details')
  screens/favorites_screen     Hive Read/Update/Delete (route '/favorites')
  widgets/                     PostTile, NewPostDialog, NoteDialog, MessageView
```
