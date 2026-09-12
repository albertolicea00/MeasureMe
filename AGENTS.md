# AGENTS.md — AI Agent Guidelines for MeasureMe

Welcome AI Agents! This repository contains **MeasureMe**, a polished, production-ready Flutter mobile app for tracking personal body measurements, fitness progress, clothing/suit sizing, and shoe measurements.

Before modifying code or generating features, read these authoritative documentation files in order:

1. [README.md](README.md) — High-level project overview, tech stack, installation, and setup instructions.
2. [ARCHITECTURE.md](ARCHITECTURE.md) — Technical architecture, Clean Architecture layers, Drift database schema, state management (Riverpod), and platform integration interfaces (`HealthService`).
3. [DESIGN.md](DESIGN.md) — Design system, color palettes (Light/Dark mode), typography, UI/UX flows, empty states, and accessibility rules.
4. [CONTRIBUTING.md](CONTRIBUTING.md) — Contribution guidelines, PR workflows, testing standards, and code quality expectations.
5. [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) — Community guidelines and behavioral expectations.

---

## 🎯 Core Product Purpose & Scope Boundaries

> [!IMPORTANT]
> **Product Identity**: MeasureMe is a **premium personal measurement and sizing assistant**, NOT a gym/workout logger.

- **IN-SCOPE**:
  - Body measurements history (Chest, Waist, Hips, Weight, Height, Arms, Thighs, Body Fat %, etc.)
  - Measurement sessions (batch entry UI with partial saves)
  - Clothing & Suit sizes and brand-specific size profiles (Nike, Levi's, SuitSupply, etc.)
  - Shoe sizes (US/EU/UK) and foot measurements (length, width, arch notes)
  - Local recurring measurement reminders (local notifications)
  - Unit conversions (Metric vs Imperial presentation without mutating stored canonical values)
  - Apple Health & Android Health Connect synchronization (optional, non-blocking)
  - Local-first offline storage via Drift

- **OUT-OF-SCOPE (DO NOT BUILD)**:
  - Workout routines, sets, reps, exercise guides, personal records (PRs), or gym workout planning. (These belong to a separate future workout app).

---

## 📐 Non-Negotiable Development Rules for AI Agents

1. **Clean Architecture Isolation**: Keep `domain/`, `data/`, `presentation/`, and `integrations/` strictly decoupled. Never write database queries or health kit calls directly inside Flutter UI widgets.
2. **Canonical Data Storage**: Always store physical measurements internally using canonical base units (Metric: `cm`, `kg`). Convert to Imperial (`in`, `lb`) or specific shoe systems (`EU`, `US`, `UK`) **only** in the presentation layer.
3. **Dynamic Extensibility**: Never hard-code database tables to fixed body measurement fields. Store measurements as extensible key-value entities (`MeasurementType` + `MeasurementRecord`).
4. **Offline-First & Local Privacy**: Ensure 100% functionality offline using Drift (SQLite). Never silently transmit health/body data to external servers.
5. **Non-Judgmental UX & Tone**: Trend charts and progress indicators must use neutral, objective visual language. Do not assume weight/size increases or decreases are inherently "good" or "bad".
6. **Graceful Platform Fallbacks**: If Apple Health or Health Connect permissions are denied or unsupported on a device, display clear fallback banners. Never crash or mock fake synchronization.
7. **Verification**: Always run `flutter test` and static analysis after making changes.

---

## 🛠 Useful Commands for Agents

- Run code generator (Drift / Riverpod): `flutter pub run build_runner build --delete-conflicting-outputs`
- Run all tests: `flutter test`
- Analyze codebase: `flutter analyze`