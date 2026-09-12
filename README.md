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

> **Measure. Track. Remember.**3
