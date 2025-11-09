# Flutter Clean Architecture

A Flutter project implementing Clean Architecture with Riverpod state management.

## Features

- **Clean Architecture** - Separation of concerns with Domain, Data, and Presentation layers
- **Riverpod** - Type-safe dependency injection and state management
- **Code Generation** - Automated code generation with build_runner
- **Freezed** - Immutable data classes with union types
- **fpdart** - Functional programming with Either for error handling
- **Dio + Retrofit** - Type-safe HTTP client
- **GoRouter** - Declarative routing
- **Hive** - Fast local storage

## Clean TODO Demo App

A production-ready TODO application demonstrating Clean Architecture principles with modern Flutter development practices.

### Features Implemented:
- ✅ **Home Feature** - Welcome screen with app overview
- ✅ **TODO Feature** - Full CRUD operations following Clean Architecture
  - **Domain Layer**: Todo entities and business rules
  - **Data Layer**: In-memory data storage with repository pattern
  - **Presentation Layer**: Todo list UI with Riverpod state management

### Architecture Highlights:
- **Separation of Concerns** - Clear boundaries between domain, data, and presentation layers
- **Dependency Inversion** - Domain layer has no dependencies on outer layers
- **Testability** - Each layer can be tested independently
- **Scalability** - Feature-based structure makes it easy to add new functionality
- **Code Generation** - Automated boilerplate with freezed and riverpod_generator

## Project Structure

```
lib/
├── core/
│   ├── constants/      # App-wide constants
│   ├── errors/         # Failure and Exception classes
│   ├── network/        # Dio configuration
│   ├── theme/          # App theme
│   └── utils/          # Utility functions
├── features/
│   └── [feature_name]/
│       ├── data/
│       │   ├── datasources/    # Remote & Local data sources
│       │   ├── models/         # JSON serializable models
│       │   └── repositories/   # Repository implementations
│       ├── domain/
│       │   ├── entities/       # Business entities
│       │   ├── repositories/   # Repository interfaces
│       │   └── usecases/       # Business logic
│       └── presentation/
│           ├── providers/      # Riverpod providers
│           ├── screens/        # Full-screen pages
│           ├── widgets/        # Reusable widgets
│           └── state/          # UI state classes
└── main.dart
```

## Getting Started

### Prerequisites

- Flutter SDK ^3.9.2
- Dart SDK ^3.9.0

### Installation

1. Clone the repository
2. Install dependencies:
```bash
flutter pub get
```

3. Run code generation:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Development

For continuous code generation during development:
```bash
flutter pub run build_runner watch --delete-conflicting-outputs
```

### Run the app

```bash
flutter run
```

## Code Generation

This project uses several code generators:

- **riverpod_generator** - Generates Riverpod providers from `@riverpod` annotations
- **freezed** - Generates immutable classes with copyWith, equality, etc.
- **json_serializable** - Generates JSON serialization code
- **retrofit_generator** - Generates type-safe API clients

After making changes to files with these annotations, run:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## Creating a New Feature

Follow these steps to create a new feature following Clean Architecture:

1. Create the feature folder structure:
```bash
mkdir -p lib/features/my_feature/{data/{datasources,models,repositories},domain/{entities,repositories,usecases},presentation/{providers,screens,widgets}}
```

2. Create domain entities and repository interface
3. Create data models and implement repository
4. Create use cases for business logic
5. Create Riverpod providers for state management
6. Create UI screens and widgets
7. Run code generation
8. Add tests

## Architecture Guidelines

See [CLAUDE.md](CLAUDE.md) for AI-assisted development guidelines and [.claude/rules.md](.claude/rules.md) for detailed architectural rules.

## Key Technologies

### State Management
- **flutter_riverpod** - Provider-based state management
- **riverpod_annotation** - Code generation for providers

### Functional Programming
- **fpdart** - Either, Option, and other functional types

### Networking
- **dio** - HTTP client
- **retrofit** - Type-safe REST client
- **pretty_dio_logger** - Network request logging

### Local Storage
- **hive** - NoSQL database
- **shared_preferences** - Key-value storage

### Code Generation
- **freezed** - Immutable classes
- **json_serializable** - JSON serialization
- **build_runner** - Code generation runner

### Testing
- **mocktail** - Mocking library

## Testing

Run tests:
```bash
flutter test
```

Run tests with coverage:
```bash
flutter test --coverage
```

## License

This project is licensed under the MIT License.
