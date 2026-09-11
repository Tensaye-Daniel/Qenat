# Qenat

Qenat is a Flutter app for planning your days and keeping a sustainable rhythm. It combines a month-based calendar with task tracking and progress insights so you can focus on what matters without losing momentum.

## Overview

The app helps you:

- plan daily tasks from a calendar view
- track completion progress across the month
- monitor streaks and recent consistency
- keep progress local and private using a lightweight database
- maintain a calm, minimal visual experience throughout the day

## Features

- Calendar-focused planning interface with month navigation and quick return to today
- Daily progress tracking for tasks and completion states
- Streak summaries and trend insights for recent activity
- Clean, custom-themed UI with warm, readable design choices
- Local persistence built with Drift and SQLite
- State management with Riverpod

## Tech Stack

- Flutter
- Dart
- Riverpod
- Drift / SQLite
- fl_chart for visual summaries
- Google Fonts for typography
- Intl for date formatting

## Project Structure

- `lib/main.dart` — app entry point
- `lib/core/` — shared theme, utilities, and UI pieces
- `lib/features/calendar/` — calendar planning screens and providers
- `lib/features/tasks/` — task models, progress logic, and data access
- `lib/features/stats/` — insights and trend summaries
- `test/` — unit and widget tests

## Getting Started

Make sure Flutter is installed and configured on your machine.

1. Clone the repository
2. Install dependencies:

   ```bash
   flutter pub get
   ```

3. Run the app:

   ```bash
   flutter run
   ```

## Useful Commands

```bash
flutter analyze
flutter test
flutter run
```

## Notes

This project is designed for local personal productivity tracking and is intended to stay lightweight, fast, and focused on daily rhythm rather than heavy project management features.
