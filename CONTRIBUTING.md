# Contributing to Measure Me

Thank you for your interest in contributing to Measure Me!

Measure Me is a Flutter application focused on personal body measurements, clothing sizes, shoe sizes, and measurement history.

Contributions, bug reports, feature suggestions, and improvements are welcome.

## Before Contributing

Please read:

- `README.md` for the project overview.
- `ARCHITECTURE.md` for the project scope and architecture.
- `DESIGN.md` for the project design system.
- `CODE_OF_CONDUCT.md` for community expectations.

Keep in mind that Measure Me is intentionally focused on measurements and sizing. Workout tracking and gym functionality belong to a separate project.

## Getting Started

### Requirements

- Flutter SDK
- Dart SDK
- Xcode for iOS development
- Android Studio or Android SDK for Android development

### Setup

Clone the repository:

```bash
git clone <repository-url>
cd measure_me
```

Install dependencies:

```bash
flutter pub get
```

Run the application:

```bash
flutter run
```

## Project Guidelines

When contributing:

- Keep the code simple and maintainable.
- Follow standard Flutter and Dart conventions.
- Prefer clear, readable code over unnecessary abstractions.
- Keep features focused on the purpose of the application.
- Avoid adding dependencies unless they provide clear value.
- Keep platform-specific functionality isolated where possible.
- Protect user privacy and personal measurement data.

## Architecture

Keep responsibilities separated where practical.

```text
lib/
├── app/
├── core/
├── data/
├── features/
├── services/
└── shared/
```

The exact structure may evolve as the application grows.

## Adding Features

Before implementing a large feature, open an issue or discussion describing:

- What problem it solves.
- Why it belongs in Measure Me.
- How it should work.
- Any platform-specific considerations.

Small bug fixes and improvements can usually be submitted directly.

## Health Integrations

HealthKit and Health Connect integrations should:

- Request only the permissions required.
- Clearly explain why permissions are needed.
- Never expose health data unnecessarily.
- Gracefully handle denied or unavailable permissions.
- Keep the application functional when health integrations are unavailable.

## Privacy

Never commit:

- Personal measurements
- Real user health data
- Private screenshots containing personal information
- API keys
- Credentials
- Secrets
- Private user data

Use mock or anonymized data for examples and tests.

## Code Style

Format Dart code before submitting:

```bash
dart format .
```

Analyze the project:

```bash
flutter analyze
```

Run tests:

```bash
flutter test
```

Pull requests should not introduce new analyzer warnings or failing tests.

## Commits

Use clear and concise commit messages.

Examples:

```text
feat: add measurement history
fix: correct shoe size conversion
refactor: simplify measurement repository
docs: update health integration guide
test: add measurement validation tests
```

## Pull Requests

Pull requests should:

- Clearly describe the change.
- Explain why the change is needed.
- Keep unrelated changes out of the PR.
- Include tests when appropriate.
- Update documentation when necessary.
- Include screenshots for significant UI changes.

Keep pull requests focused and reasonably small when possible.

## Bug Reports

When reporting a bug, include:

- Device and OS version
- Flutter version
- Steps to reproduce
- Expected behavior
- Actual behavior
- Screenshots or logs when useful

Do not include real personal measurements or other sensitive information.

## Feature Requests

Feature requests are welcome, but should remain aligned with the project's scope.

Features related to:

- Workouts
- Exercises
- Sets and reps
- Personal records
- Training programs
- Gym planning

should be considered for the future Gym app rather than Measure Me.

## License

By contributing to Measure Me, you agree that your contributions will be licensed under the project's MIT License.