# Expense Tracker App

A fully offline expense management application built with Flutter using BLoC pattern and Clean Architecture.

## Features

- **Offline-First**: All data stored locally using SQLite
- **Expense & Income Tracking**: Add, edit, and delete transactions with categories
- **Smart Categories**: Separate Spend and Earn categories with usage protection
- **Advanced Filtering**: Filter by type, category, and search by notes
- **Reports & Analytics**: Visual charts and period-based insights
- **CSV Import/Export**: Data portability for backup and migration
- **Theme Support**: Light, Dark, and System theme modes

## Project Structure

```
lib/
├── app.dart                    # App configuration and theme setup
├── main.dart                   # Entry point
├── routes/                     # Navigation and routing
│   └── app_router.dart        # GoRouter configuration
├── core/                       # Core utilities and shared code
│   ├── constants/             # App constants (currencies)
│   ├── db/                    # Database configuration
│   ├── di/                    # Dependency injection setup
│   ├── errors/                # Error handling
│   ├── theme/                 # Theme configuration and cubit
│   └── utils/                 # Utilities (Result, CSV service)
└── features/                   # Feature modules
    ├── categories/            # Category management
    │   ├── data/             # Data layer (models, repositories)
    │   ├── domain/           # Business logic (entities, usecases)
    │   └── presentation/     # UI layer (bloc, pages, widgets)
    ├── home/                  # Home dashboard
    ├── onboarding/           # First-run setup
    ├── reports/              # Analytics and reports
    ├── settings/             # App settings
    └── transactions/         # Transaction management
```

## Tech Stack

- **Flutter**: 3.8.1+
- **State Management**: flutter_bloc (BLoC pattern)
- **Local Database**: SQLite with migrations support
- **Routing**: go_router
- **Dependency Injection**: get_it
- **Charts**: fl_chart

## Getting Started

### Prerequisites

- Flutter SDK 3.8.1 or higher
- Dart SDK
- Android Studio / VS Code with Flutter extensions

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd expense_app-master
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run code generation (if needed):
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

4. Run the app:
```bash
flutter run
```

### Building for Release

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS
flutter build ios --release
```

## Running Tests

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage
```

## Code Analysis

```bash
# Run static analysis
flutter analyze

# Format code
flutter format lib test
```

---

Built with Flutter
