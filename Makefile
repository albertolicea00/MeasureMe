# Makefile for MeasureMe (Flutter app)
#
# New contributor? Run `make setup` first — it installs dependencies and
# generates the Drift database code (`app_database.g.dart` etc.) that the
# app needs before it will compile.
#
# Run `make` or `make help` to list every other target.

.PHONY: get generate watch analyze format format-check test test-unit icons clean run-ios run-android build-ios build-apk setup ci help

help: ## Show this help message
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage: make \033[36m<target>\033[0m\n\nTargets:\n"} /^[a-zA-Z0-9_-]+:.*##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)

get: ## Install/update Dart & Flutter package dependencies
	flutter pub get

# --delete-conflicting-outputs is accepted but is currently a no-op with the
# installed build_runner version (it says so in its own warning output).
# Kept here anyway for forward/backward compatibility with other versions.
generate: ## Run build_runner once to regenerate Drift's *.g.dart files
	dart run build_runner build --delete-conflicting-outputs

watch: ## Run build_runner in watch mode for continuous codegen while editing tables/DAOs
	dart run build_runner watch --delete-conflicting-outputs

analyze: ## Run static analysis (flutter analyze)
	flutter analyze

format: ## Format all Dart source files in place
	dart format .

format-check: ## Check formatting without writing changes; fails if anything is unformatted (CI-friendly)
	dart format --output=none --set-exit-if-changed .

test: ## Run the full test suite
	flutter test

test-unit: ## Run only the unit tests (test/unit)
	flutter test test/unit

icons: ## Regenerate app launcher icons from assets/icon/*.png
	dart run flutter_launcher_icons

clean: ## Remove build artifacts (flutter clean)
	flutter clean

run-ios: ## Run the app on an iOS device/simulator
	flutter run -d ios

run-android: ## Run the app on an Android device/emulator
	flutter run -d android

build-ios: ## Build a release iOS app
	flutter build ios --release

build-apk: ## Build a release Android APK
	flutter build apk --release

setup: get generate ## First-time setup: install dependencies and generate Drift code

ci: format-check analyze test ## Run the checks a CI pipeline / pre-PR review expects

.DEFAULT_GOAL := help
