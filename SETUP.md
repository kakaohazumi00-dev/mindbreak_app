# MindBreak — Flutter Setup Guide
## Full Android app with Firebase · Targets Android 30 (API 30)

---

## Prerequisites

Install these before starting:

| Tool | Version | Link |
|------|---------|-------|
| Flutter SDK | 3.16 or later | https://docs.flutter.dev/get-started/install |
| Android Studio | Latest (Hedgehog+) | https://developer.android.com/studio |
| Java 17+ | Bundled with Android Studio | |
| Node.js | 18+ (for Firebase CLI) | https://nodejs.org |

Verify Flutter works:
```bash
flutter doctor
```
All items should be green ✅ before proceeding.

---

## Step 1 — Get the code

Copy the `flutter_mindbreak/` folder from this project to anywhere on your machine:

```bash
# Example
cp -r flutter_mindbreak/ ~/projects/mindbreak
cd ~/projects/mindbreak
```

---

## Step 2 — Install Flutter dependencies

```bash
flutter pub get
```

---

## Step 3 — Set up Firebase

### 3a. Create a Firebase project

1. Go to https://console.firebase.google.com
2. Click **Add project** → name it `mindbreak`
3. Disable Google Analytics if you don't need it → **Create project**

### 3b. Add an Android app

1. In the Firebase console, click the **Android icon** (Add app)
2. Set **Android package name** to: `com.mindbreak.app`
3. Set **App nickname** to: `MindBreak`
4. Click **Register app**
5. Download `google-services.json`
6. Place it at: `android/app/google-services.json`

### 3c. Enable Authentication

1. In Firebase console → **Authentication** → **Get started**
2. Click **Sign-in method** tab
3. Enable **Anonymous** → Save

### 3d. Create Firestore database

1. In Firebase console → **Firestore Database** → **Create database**
2. Choose **Start in test mode** (you can tighten rules later)
3. Pick the closest region → **Enable**

### 3e. Generate firebase_options.dart

Install the FlutterFire CLI:
```bash
dart pub global activate flutterfire_cli
```

Run the configurator (from inside the flutter_mindbreak folder):
```bash
flutterfire configure --project=<your-firebase-project-id>
```

This automatically overwrites `lib/firebase_options.dart` with the correct values.
✅ You are done with Firebase setup.

---

## Step 4 — Set up an Android emulator or device

### Option A — Physical Android device (recommended for testing blocking)

1. Enable **Developer Options** on your phone (tap Build Number 7 times)
2. Enable **USB Debugging**
3. Connect via USB
4. Run `flutter devices` — your device should appear

### Option B — Android emulator (API 30)

1. Open Android Studio → **Device Manager** → **Create Device**
2. Choose **Pixel 6** → Next
3. Select system image: **API 30 (Android 11)** → Download it → Next
4. Click **Finish**
5. Start the emulator

---

## Step 5 — Run the app

```bash
flutter run
```

To run on a specific device:
```bash
flutter devices         # list devices
flutter run -d <device-id>
```

The app will launch. You'll see the Home, Stats, and Settings tabs.

---

## Step 6 — Enable Usage Access (real tracking)

For the app to see actual screen time data:

1. On the device/emulator: **Settings → Apps → Special App Access → Usage Access**
2. Find **MindBreak** → toggle **Allow**

If this is skipped, the app falls back to the built-in simulated usage values.

---

## Step 7 — Enable Accessibility Service (real blocking)

For the app to actually intercept and block targeted apps:

1. **Settings → Accessibility → Downloaded apps → MindBreak Blocker**
2. Toggle **Use MindBreak Blocker** → Allow

What this does:
- Monitors which app opens in the foreground
- When a "blocked" app (one that has hit its limit) is opened, it immediately
  brings MindBreak to the foreground, showing the ShieldScreen
- No data is sent anywhere — all monitoring is local

> **Note:** On Android 10+, some manufacturers (Samsung, Xiaomi, etc.) restrict
> background accessibility services. If blocking doesn't work, check your
> manufacturer's battery optimization settings and disable them for MindBreak.

---

## Step 8 — Build a release APK (to install on any Android 11 phone)

```bash
flutter build apk --release --target-platform android-arm64
```

The APK will be at:
```
build/app/outputs/flutter-apk/app-release.apk
```

Transfer it to your phone and install (you may need to allow "Install from unknown sources" once).

---

## Firestore data structure

```
users/
  {uid}/               ← anonymous Firebase Auth UID, device-bound
    game: {
      streak, longestStreak, points,
      totalCleanDays, totalLockedDays,
      lockedToday, lastCleanDate
    }
    settings: {
      dailyLimitMinutes, strictMode,
      hapticsEnabled, notificationsEnabled
    }
    weekly: [
      { date, minutes, locked },
      ... (7 entries)
    ]
    updatedAt: Timestamp
```

---

## Firestore security rules (tighten before production)

In Firebase console → Firestore → Rules, paste:

```js
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

This ensures every user can only access their own data.

---

## Project structure

```
lib/
  main.dart                   ← Firebase init, Provider setup, bottom nav
  firebase_options.dart       ← Auto-generated by flutterfire configure
  theme/app_theme.dart        ← Dark theme, color constants
  models/
    game_state.dart           ← Streak, points, ranks, DayUsage
    tracked_app.dart          ← App usage data model
    app_settings.dart         ← Settings model
  providers/
    game_provider.dart        ← Streak/points logic + Firestore sync
    shield_provider.dart      ← App tracking, lock state + native channel
  screens/
    home_screen.dart          ← Weekly graph, top app, simulate buttons
    stats_screen.dart         ← Rank widget, streak card, stats grid
    settings_screen.dart      ← Limit presets, toggles, account section
    shield_screen.dart        ← Lock screen with countdown
  widgets/
    weekly_bar_chart.dart     ← Custom painted bar chart

android/app/src/main/
  kotlin/com/mindbreak/app/
    MainActivity.kt           ← Flutter entry + MethodChannel for native
    UsageStatsHelper.kt       ← UsageStatsManager queries
    AppBlockerService.kt      ← AccessibilityService that enforces blocks
  res/xml/
    accessibility_service_config.xml
```

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| `google-services.json not found` | Place it at `android/app/google-services.json` |
| `firebase_options.dart has placeholder values` | Run `flutterfire configure` |
| Usage stats always 0 | Grant Usage Access in Android Settings (Step 6) |
| Blocking doesn't work | Enable Accessibility Service (Step 7) |
| Build fails on `compileSdkVersion` | Update Android SDK in Android Studio SDK Manager |
| `flutter doctor` shows Android toolchain issues | Install Android SDK Build-Tools 34 via SDK Manager |
