# Flutter Clean Architecture Project

This is a Flutter project using **Clean Architecture** with **Riverpod** state management.

## Architecture

This project follows Clean Architecture principles with three main layers:

- **Domain Layer**: Business logic, entities, use cases, repository interfaces
- **Data Layer**: Models, data sources (remote/local), repository implementations
- **Presentation Layer**: UI widgets, screens, Riverpod providers, state management

## Key Technologies

- **State Management**: Riverpod with code generation (`riverpod_annotation`)
- **Immutability**: Freezed for data classes
- **Functional Programming**: fpdart for Either types and error handling
- **Code Generation**: build_runner for generating providers, JSON serialization, etc.

## Important Rules

⚠️ **Always follow the detailed guidelines in `.claude/rules.md`** when:
- Creating new features
- Writing data models
- Implementing state management
- Structuring files and folders

## Quick Commands

Run code generation:
```bash
dart run build_runner watch --delete-conflicting-outputs
```

## Project Structure

```
lib/
├── core/           # Shared utilities, constants, errors, theme
├── features/       # Feature modules (Clean Architecture)
│   └── [feature]/
│       ├── data/       # Models, data sources, repository impl
│       ├── domain/     # Entities, repository interfaces, use cases
│       └── presentation/  # Screens, widgets, providers
└── main.dart
```

## Code Style

- Use `@riverpod` annotations (not manual providers)
- Use `@freezed` for all data classes
- Handle async operations with `AsyncValue`
- Follow Either pattern for error handling
- Keep features modular and independent

---

**For detailed implementation guidelines, see [.claude/rules.md](.claude/rules.md)**
