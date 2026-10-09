# Firebase Task Manager

Flutter task manager assignment using Firebase Authentication, Cloud Firestore, FCM, and local notifications.

## Connect Firebase

1. Create a Firebase project and register the Android application with package name `com.example.firebase_task_manager`. Register the iOS bundle ID shown by Xcode as well if building for iOS.
2. Enable **Email/Password** and **Google** providers in Firebase Authentication. Add your Android SHA-1/SHA-256 fingerprints to the Firebase Android app for Google sign-in. For iOS, add the reversed client ID URL scheme from `GoogleService-Info.plist` to the Runner target.
3. Create a Cloud Firestore database. Select the Firebase project with `firebase use --add`, then deploy the included rules with `firebase deploy --only firestore:rules`.
4. Install the FlutterFire CLI and run `flutterfire configure` from the project directory. Download `google-services.json` to `android/app/` and `GoogleService-Info.plist` to `ios/Runner/` if the CLI does not place them for you. Keep these project-specific files out of source control if your project policy requires it.
5. Run `flutter pub get`, then `flutter run` on a physical device or configured emulator. Allow notification permission when prompted.

The Android Google Services plugin is applied when `android/app/google-services.json` exists. Firebase initialization uses native platform configuration. No Firebase project credentials are included in this checkout.

For iOS push notifications, enable Push Notifications and Background Modes (Remote notifications) for the Runner target, and upload an APNs authentication key in Firebase Console. iOS Simulator push delivery requires a supported simulator/runtime; use a physical device for the most reliable check.

## Firestore layout

Tasks are stored at `users/{uid}/tasks/{taskId}`. Each task contains `title`, `description`, `dueDate`, `priority`, `completed`, and `createdAt`. The signed-in user's FCM token is stored at `users/{uid}.fcmToken`.

## Test notifications

Run the app, sign in, and copy the FCM token from that user's Firestore document. In Firebase Console, send a test notification to the token. Include `taskId` in custom data to open the related task after tapping. Foreground pushes are displayed with `flutter_local_notifications`; background and terminated notification taps are handled by FCM.

For server initiated notifications, send through the Firebase Admin SDK from a trusted server or Cloud Function. Never put a service account key in the Flutter app.
