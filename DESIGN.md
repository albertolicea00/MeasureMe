# MeasureMe - Design & UX Specification

This document details the visual design, user experience (UX), branding, and design system specifications for **MeasureMe**. For technical architecture and data modeling, refer to [ARCHITECTURE.md](ARCHITECTURE.md).

## 1. Executive Summary & Brand Philosophy

**Brand Identity:** MeasureMe is positioned as a premium, elegant personal measurement and sizing assistant. It is designed to feel like a high-end bespoke tailoring assistant and personal health tracker combined. 
**Core Tenets:**
- **Precision & Elegance:** The visual language should communicate accuracy, cleanliness, and sophistication.
- **Health & Wellness:** Focused on holistic tracking rather than aggressive fitness.
- **Avoid Gym Stereotypes:** The design must explicitly avoid the "bodybuilding" or "gym-bro" aesthetic. No aggressive neon colors, no dumbbell imagery, and no "no pain no gain" messaging.

## 2. Visual Identity & Design System

- **Color Palette:**
  - **Light Mode:** Crisp whites, soft off-white backgrounds (e.g., `#F8F9FA`), subtle greys for secondary text, and a refined primary accent color (e.g., a deep tailored navy `#1A365D` or sophisticated sage green).
  - **Dark Mode:** Deep, rich dark backgrounds (not pure black, e.g., `#121212` or `#1E1E1E`), with low-contrast borders and elevated surfaces to create depth without harshness.
- **Typography:** Clean, highly legible sans-serif fonts (like Inter, SF Pro, or Roboto). Emphasize hierarchy through weight and size rather than multiple font families.
- **Card Styling:** 
  - Subtle and elegant.
  - Border radius: Medium (e.g., 12dp to 16dp).
  - Shadows: Minimal, soft, and diffuse to create slight elevation without heavy contrast.
- **Iconography:** 
  - Focus on measuring tools (tape measure, rulers) and abstract human silhouettes.
  - Strictly avoid fitness-specific icons (dumbbells, weights, muscular flexes).
  - Outline or soft-filled icons with consistent stroke weights.

## 3. Navigation & Layout Architecture

- **Bottom Navigation Bar:** The primary mode of navigation for top-level destinations (e.g., Dashboard, History, Wardrobe/Sizing, Settings).
- **Dashboard/Home Layout:** A modular, card-based layout prioritizing the most relevant data at a glance.
- **Responsive Structure:**
  - **Phones:** Standard vertical scrolling with bottom navigation.
  - **Tablets:** Adaptive layouts utilizing side navigation rails or multi-column grids to maximize screen real estate.
  - **Cross-Platform Accents:** The UI relies on Material 3 guidelines for core structure, while adopting Cupertino (iOS) accents (such as smooth page transitions, specific switch styles, and bounce scrolling) to feel native on Apple devices.

## 4. User Experience (UX) Flows & Components

### Measurement Sessions UX
- **Batch Entry UI:** Optimized for speed and fluidity when entering multiple measurements consecutively (e.g., Chest -> Waist -> Hips).
- **Partial Saves:** The UI must support and clearly indicate temporary states before the entire session is committed. Smooth transitions between input fields (auto-focus next).

### Dashboard UX
- **Current Measurements Cards:** Display the most recent values with subtle trend indicators (up/down arrows with neutral colors).
- **Quick Actions:** Prominent FAB or quick action buttons to instantly start a new measurement session.
- **Progress Summary & Reminder Cards:** Contextual cards placed at the top of the feed to remind users to log missing data or celebrate consistency.
- **Empty States:** Clear, welcoming empty states when no data is available.

### Measurement History & Charts UX
- **Visual Indicators:** Clean, smooth line charts with soft gradients filling the area below the curve.
- **Non-Judgmental Language:** Trend charts and summaries must use neutral, objective language (e.g., "Weight changed by 2kg", avoiding phrases like "You gained weight!").

### Clothing & Shoe Sizing UX
- **Brand Profiles UI:** Dedicated screens for specific brands, allowing users to save their perfect fit.
- **Inventory Cards & Size Comparisons:** Visual cards showing saved items, enabling quick comparison between different brands' sizing scales.

### Onboarding Flow UI
- **4-Screen Intro:** A brief, beautifully animated introduction explaining the app's core value proposition.
- **Minimal Data Collection:** Ask only for essential starting data (e.g., preferred unit system) to minimize friction.

## 5. Empty States & Feedback Design

- **Empty States:** When no data exists (e.g., a new user opening the History tab), display beautifully crafted empty state illustrations and clear, encouraging calls-to-action (CTAs). Avoid dead ends.
- **Interactive Feedback:** Provide immediate visual or haptic feedback for user actions (e.g., subtle haptics when saving a measurement, snackbars for success confirmations).

## 6. Accessibility & Theme System

- **Dynamic Text:** Fully support OS-level text scaling without breaking layouts.
- **Screen Readers:** Ensure all interactive elements have semantic labels and content descriptions for VoiceOver/TalkBack.
- **High Contrast:** Ensure text-to-background contrast ratios meet WCAG AA standards minimum.
- **Touch Targets:** All interactive components must have a minimum touch target size of 48x48dp.
- **Theme Persistence:** Support explicit user overrides for Light, Dark, or System Default themes, and persist this preference across app launches.
