# Measure Me

[![Flutter](https://img.shields.io/badge/Flutter-02569B?logo=flutter&logoColor=white)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-0175C2?logo=dart&logoColor=white)](https://dart.dev/)
[![iOS](https://img.shields.io/badge/iOS-000000?logo=apple&logoColor=white)](https://www.apple.com/ios/)
[![Android](https://img.shields.io/badge/Android-3DDC84?logo=android&logoColor=white)](https://www.android.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

A simple cross-platform app for keeping track of your body measurements, clothing sizes, shoe sizes, and measurement history.

Built with **Flutter** and designed to be a lightweight personal reference for knowing your measurements and sizes wherever you go.

## Features

- 📏 Track body measurements
- 📈 Keep a history of measurements over time
- 👕 Store clothing and suit sizes
- 👟 Store shoe sizes and foot measurements
- 🏷️ Keep size information for different brands
- 🔔 Set reminders to update measurements
- ❤️ Optional integration with Apple Health
- 🏃 Optional integration with Android Health Connect
- 💾 Local-first data storage
- 📱 iOS and Android support

## Measurements

Measure Me can store common body measurements such as:

- Height
- Weight
- Chest
- Waist
- Hips
- Neck
- Shoulders
- Arms
- Thighs
- Calves
- Other custom measurements

Measurements can be updated over time, allowing you to keep a personal history instead of only storing your current values.

## Clothing & Suit Sizes

Keep your clothing sizes in one place instead of having to remember them for every brand.

Examples include:

- Shirts
- T-Shirts
- Pants
- Jeans
- Jackets
- Suits
- Dress shirts
- Underwear
- Other clothing

Brand-specific sizing can also be stored when measurements or sizes differ between brands.

## Shoes

Store information such as:

- Shoe size
- Size system (US / EU / UK, etc.)
- Foot length
- Foot width
- Brand-specific sizes
- Notes

## Measurement History

Measurements are not simply overwritten.

Each update can be recorded so you can see how your measurements have changed over time.

```text
Current
   ↓
Update measurement
   ↓
New measurement record
   ↓
Measurement history
```

## Reminders

Measure Me can remind you to update your measurements periodically.

For example:

- Monthly
- Every 3 months
- Every 6 months
- Custom intervals

The goal is to make keeping your information up to date effortless.

## Health Integrations

Where supported, Measure Me may integrate with native health platforms:

- **Apple Health / HealthKit**
- **Android Health Connect**

Health integrations are optional and should only be used for data that makes sense to synchronize with the platform.

The app should continue working normally without these integrations.

## Technology

- **Flutter**
- **Dart**
- SQLite / local database
- Apple Health / HealthKit
- Android Health Connect
- Local notifications

## Getting Started

### Requirements

- Flutter 3.47.2 (stable channel) / Dart 3.13.2 — the versions this app was built and verified
  against. Newer stable releases should work; check `flutter --version` against
  `environment.sdk` in `pubspec.yaml` if something doesn't compile.
- Xcode, for iOS (device or simulator).
- Android Studio / the Android SDK, for Android. **Note:** Health Connect requires
  `minSdkVersion 26` (Android 8.0) — already set in `android/app/build.gradle.kts`.

### Setup and running

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # generates Drift's *.g.dart files
flutter run
```

(`make setup` runs the first two steps in one go — see the `Makefile` at the repo root, or
`make help` for every other available shortcut such as `make test` and `make analyze`.)

The app will not compile without that `build_runner` step: the local database's generated code
(table row classes, DAOs, query builders) is not committed to source control and must be produced
locally. See `ARCHITECTURE.md` for why, and for the full dependency/architecture breakdown.

### Why Drift

Drift (built on `sqlite3`) was chosen over Isar or raw `sqlite3`/`sqflite` for three reasons:
type-safe, compile-time-checked queries instead of hand-written SQL strings; first-class
`Stream` support per query, so the UI updates reactively the instant a measurement is saved,
without any manual cache-invalidation code; and straightforward, explicit schema migrations as
the app's data model grows. `SharedPreferences` is deliberately not used for measurement history —
only Drift is, everywhere history needs to persist.

### Apple Health (iOS)

Handled through the `health` plugin, wrapped behind this app's own `HealthService` interface (see
`lib/integrations/health/`). Required project configuration (already applied in this repo):

- `NSHealthShareUsageDescription` and `NSHealthUpdateUsageDescription` in
  `ios/Runner/Info.plist`, explaining why the app wants to read/write Health data.
- The HealthKit capability, via `ios/Runner/Runner.entitlements`
  (`com.apple.developer.healthkit`), and `CODE_SIGN_ENTITLEMENTS` pointed at that file from the
  Xcode project's build settings.
- iOS 15.0+ (the `health` plugin's own minimum).

Only **weight, height, and body fat percentage** ever sync — HealthKit has no data type for
custom body measurements like chest or waist, so those stay local-only by necessity, not by
choice. The Health Integration screen in-app explains this rather than pretending otherwise.

### Android Health Connect

Also handled through the `health` plugin behind `HealthService`. Health Connect is a separate app
on the device (not part of the OS on every version), so the in-app screen checks for it and offers
an install prompt rather than assuming it's present. Required configuration (already applied):

- `minSdkVersion 26` in `android/app/build.gradle.kts`.
- `MainActivity` extends `FlutterFragmentActivity` (not the default `FlutterActivity`) — required
  by the `health` plugin's permission flow on Android 14+.
- `android.permission.health.{READ,WRITE}_{WEIGHT,HEIGHT,BODY_FAT}` permissions, a `<queries>`
  entry for `com.google.android.apps.healthdata`, and the `ViewPermissionUsageActivity`
  activity-alias Health Connect requires for its Play Store privacy-review flow — all declared in
  `android/app/src/main/AndroidManifest.xml`.

As with iOS, only weight/height/body-fat sync — the same platform limitation applies to Health
Connect's data type catalog.

### Notification permissions

The app never requests notification permission at launch. It's requested the first time the user
creates a reminder (Reminders tab → add a reminder), matching platform guidance to ask for
permissions in context. On Android 13+ this is the standard `POST_NOTIFICATIONS` runtime
permission; on iOS it's the standard local-notification alert/badge/sound prompt. Reminders are
scheduled with `AndroidScheduleMode.inexactAllowWhileIdle` on Android, a deliberate choice to avoid
requesting the sensitive `SCHEDULE_EXACT_ALARM` permission for something that doesn't need
minute-level precision.

### Known limitations

- Chest, waist, neck, arm, thigh, and other body-circumference measurements cannot sync to Apple
  Health or Health Connect — neither platform has a data type for them. This is a platform
  limitation, not a missing feature.
- Health Connect must be installed separately by the user on Android; the app detects this and
  offers to open its Play Store listing rather than failing silently.
- CSV export (measurements only) is one-way, meant for opening in a spreadsheet. Re-importing a
  full backup uses the JSON export/import pair instead.

## Privacy

Measure Me is designed around a **local-first** approach.

Personal measurements and sizing information should remain on the user's device unless an explicit synchronization feature is introduced in the future.

No account or cloud backend is required for the core experience.

## Scope

Measure Me intentionally focuses on **measurements and sizing**.

It is **not a workout or gym app**.

Features such as:

- Workout routines
- Exercises
- Sets and reps
- Personal records
- Workout planning
- Exercise instructions
- Gym goals
- Training programs

belong to a separate future Gym app.

The purpose of Measure Me is simple:

> **Measure. Track. Remember.**
