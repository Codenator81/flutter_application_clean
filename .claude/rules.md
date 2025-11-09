# Flutter Clean Architecture + Riverpod Development Rules

## Project Architecture

### Clean Architecture Layers

Follow the standard Clean Architecture pattern with these layers:

```
lib/
├── core/                    # Shared utilities, constants, errors
│   ├── constants/
│   ├── errors/
│   ├── network/
│   ├── theme/
│   └── utils/
├── features/                # Feature-based modules
│   └── [feature_name]/
│       ├── data/
│       │   ├── datasources/    # Remote & Local data sources
│       │   ├── models/         # Data models (JSON serialization)
│       │   └── repositories/   # Repository implementations
│       ├── domain/
│       │   ├── entities/       # Business objects
│       │   ├── repositories/   # Repository interfaces
│       │   └── usecases/       # Business logic
│       └── presentation/
│           ├── providers/      # Riverpod providers
│           ├── screens/        # Full-screen pages
│           ├── widgets/        # Reusable components
│           └── state/          # UI state classes
└── main.dart
```

## Riverpod Guidelines

### Provider Types and Usage

**Use the correct provider type:**

- `@riverpod` - For most providers (auto-dispose by default)
- `@Riverpod(keepAlive: true)` - For app-wide state that shouldn't dispose
- Use generated providers from `riverpod_annotation` package

**Provider naming conventions:**

```dart
// Generator creates: userProvider, userRepositoryProvider, etc.
@riverpod
Future<User> user(UserRef ref, String id) async {
  // Implementation
}

// For classes, generator creates: authNotifierProvider
@riverpod
class AuthNotifier extends _$AuthNotifier {
  // Implementation
}
```

### Provider Organization

1. **Data Layer Providers** - In `data/repositories/`
```dart
@riverpod
UserRepository userRepository(UserRepositoryRef ref) {
  final remoteDataSource = ref.watch(userRemoteDataSourceProvider);
  final localDataSource = ref.watch(userLocalDataSourceProvider);
  return UserRepositoryImpl(
    remoteDataSource: remoteDataSource,
    localDataSource: localDataSource,
  );
}
```

2. **Use Case Providers** - In `domain/usecases/`
```dart
@riverpod
GetUserUseCase getUserUseCase(GetUserUseCaseRef ref) {
  return GetUserUseCase(ref.watch(userRepositoryProvider));
}
```

3. **Presentation Providers** - In `presentation/providers/`
```dart
@riverpod
class UserNotifier extends _$UserNotifier {
  @override
  Future<User?> build() async {
    return null;
  }

  Future<void> loadUser(String id) async {
    state = const AsyncValue.loading();
    final useCase = ref.read(getUserUseCaseProvider);
    state = await AsyncValue.guard(() => useCase.execute(id));
  }
}
```

### Riverpod Best Practices

1. **Always use code generation** - Use `@riverpod` annotations instead of manual providers
2. **Use `AsyncValue` for async states** - Handle loading, data, and error states properly
3. **Read vs Watch**:
   - Use `ref.watch` in `build()` methods to rebuild on changes
   - Use `ref.read` in event handlers and callbacks
   - Use `ref.listen` for side effects (navigation, snackbars)
4. **Family providers** - Use parameters in provider functions instead of `.family` modifier
5. **Auto-dispose** - Default behavior is auto-dispose; use `keepAlive: true` sparingly

## Data Layer

### Models

Use `freezed` + `json_serializable` for immutable models:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String name,
    required String email,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}
```

### Data Sources

**Remote Data Source:**
```dart
@riverpod
UserRemoteDataSource userRemoteDataSource(UserRemoteDataSourceRef ref) {
  final dio = ref.watch(dioProvider);
  return UserRemoteDataSourceImpl(dio);
}

abstract class UserRemoteDataSource {
  Future<UserModel> getUser(String id);
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final Dio dio;

  UserRemoteDataSourceImpl(this.dio);

  @override
  Future<UserModel> getUserModel(String id) async {
    final response = await dio.get('/users/$id');
    return UserModel.fromJson(response.data);
  }
}
```

### Repositories

**Repository Interface (Domain):**
```dart
abstract class UserRepository {
  Future<Either<Failure, User>> getUser(String id);
  Future<Either<Failure, List<User>>> getUsers();
}
```

**Repository Implementation (Data):**
```dart
class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;
  final UserLocalDataSource localDataSource;

  UserRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, User>> getUser(String id) async {
    try {
      final userModel = await remoteDataSource.getUser(id);
      await localDataSource.cacheUser(userModel);
      return Right(userModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      // Try cache
      try {
        final cachedUser = await localDataSource.getUser(id);
        return Right(cachedUser.toEntity());
      } catch (_) {
        return Left(NetworkFailure());
      }
    }
  }
}
```

## Domain Layer

### Entities

Use `freezed` for immutable domain entities:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';

@freezed
class User with _$User {
  const factory User({
    required String id,
    required String name,
    required String email,
  }) = _User;
}
```

### Use Cases

**Single responsibility - one use case per action:**

```dart
class GetUserUseCase {
  final UserRepository repository;

  GetUserUseCase(this.repository);

  Future<Either<Failure, User>> execute(String id) {
    return repository.getUser(id);
  }
}

// Or with callable class
class GetUserUseCase {
  final UserRepository repository;

  GetUserUseCase(this.repository);

  Future<Either<Failure, User>> call(String id) {
    return repository.getUser(id);
  }
}
```

## Presentation Layer

### State Management with Riverpod

**For simple data fetching:**
```dart
@riverpod
Future<User> user(UserRef ref, String id) async {
  final repository = ref.watch(userRepositoryProvider);
  final result = await repository.getUser(id);
  return result.fold(
    (failure) => throw failure,
    (user) => user,
  );
}

// Usage in widget
class UserScreen extends ConsumerWidget {
  final String userId;

  const UserScreen({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider(userId));

    return userAsync.when(
      data: (user) => Text(user.name),
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => Text('Error: $error'),
    );
  }
}
```

**For complex state (forms, mutations):**
```dart
@riverpod
class UserNotifier extends _$UserNotifier {
  @override
  FutureOr<User?> build() {
    // Initial state
    return null;
  }

  Future<void> updateUser(User user) async {
    state = const AsyncValue.loading();
    final repository = ref.read(userRepositoryProvider);

    state = await AsyncValue.guard(() async {
      final result = await repository.updateUser(user);
      return result.fold(
        (failure) => throw failure,
        (user) => user,
      );
    });
  }
}
```

### UI Widgets

**Screen structure:**
```dart
class UserScreen extends ConsumerWidget {
  const UserScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen for side effects
    ref.listen(userNotifierProvider, (previous, next) {
      next.whenOrNull(
        error: (error, _) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error')),
        ),
      );
    });

    return Scaffold(
      appBar: AppBar(title: const Text('User')),
      body: const _UserBody(),
    );
  }
}

class _UserBody extends ConsumerWidget {
  const _UserBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userNotifierProvider);

    return userAsync.when(
      data: (user) => user == null
        ? const Text('No user')
        : UserCard(user: user),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => ErrorView(error: error),
    );
  }
}
```

## Error Handling

### Failure Classes

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'failures.freezed.dart';

@freezed
class Failure with _$Failure {
  const factory Failure.server(String message) = ServerFailure;
  const factory Failure.network() = NetworkFailure;
  const factory Failure.cache() = CacheFailure;
  const factory Failure.validation(String message) = ValidationFailure;
}
```

### Exception Classes

```dart
class ServerException implements Exception {
  final String message;
  ServerException(this.message);
}

class NetworkException implements Exception {}
class CacheException implements Exception {}
```

## Popular Package Combinations

### Required Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter

  # State Management
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5

  # Functional Programming
  fpdart: ^1.1.0

  # Code Generation
  freezed_annotation: ^2.4.1
  json_annotation: ^4.8.1

  # HTTP & Network
  dio: ^5.4.0
  retrofit: ^4.0.3

  # Local Storage
  hive: ^2.2.3
  hive_flutter: ^1.1.0

  # Routing
  go_router: ^14.0.0

dev_dependencies:
  # Build Runners
  build_runner: ^2.4.7
  riverpod_generator: ^2.3.9
  freezed: ^2.4.6
  json_serializable: ^6.7.1
  retrofit_generator: ^8.0.6
  hive_generator: ^2.0.1

  # Linting
  flutter_lints: ^3.0.1
  custom_lint: ^0.6.2
  riverpod_lint: ^2.3.7
```

### Code Generation

**Run code generation:**
```bash
# One-time generation
dart run build_runner build --delete-conflicting-outputs

# Watch mode (development)
dart run build_runner watch --delete-conflicting-outputs
```

### API Client with Retrofit

```dart
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'api_client.g.dart';

@riverpod
Dio dio(DioRef ref) {
  final dio = Dio(BaseOptions(
    baseUrl: 'https://api.example.com',
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 3),
  ));

  dio.interceptors.add(LogInterceptor(
    requestBody: true,
    responseBody: true,
  ));

  return dio;
}

@riverpod
ApiClient apiClient(ApiClientRef ref) {
  final dio = ref.watch(dioProvider);
  return ApiClient(dio);
}

@RestApi()
abstract class ApiClient {
  factory ApiClient(Dio dio, {String? baseUrl}) = _ApiClient;

  @GET('/users/{id}')
  Future<UserModel> getUser(@Path('id') String id);

  @GET('/users')
  Future<List<UserModel>> getUsers();

  @POST('/users')
  Future<UserModel> createUser(@Body() UserModel user);
}
```

### Local Storage with Hive

```dart
@riverpod
Future<Box<UserModel>> userBox(UserBoxRef ref) async {
  Hive.registerAdapter(UserModelAdapter());
  return await Hive.openBox<UserModel>('users');
}

@riverpod
UserLocalDataSource userLocalDataSource(UserLocalDataSourceRef ref) {
  final box = ref.watch(userBoxProvider).requireValue;
  return UserLocalDataSourceImpl(box);
}
```

### Routing with GoRouter

```dart
@riverpod
GoRouter router(RouterRef ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/user/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return UserScreen(userId: id);
        },
      ),
    ],
  );
}

// In main.dart
class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      routerConfig: router,
    );
  }
}
```

## Testing Guidelines

### Unit Tests (Use Cases & Repositories)

```dart
void main() {
  late MockUserRepository mockRepository;
  late GetUserUseCase useCase;

  setUp(() {
    mockRepository = MockUserRepository();
    useCase = GetUserUseCase(mockRepository);
  });

  test('should return User when repository call is successful', () async {
    // Arrange
    const user = User(id: '1', name: 'Test', email: 'test@test.com');
    when(() => mockRepository.getUser('1'))
        .thenAnswer((_) async => const Right(user));

    // Act
    final result = await useCase.execute('1');

    // Assert
    expect(result, const Right(user));
    verify(() => mockRepository.getUser('1')).called(1);
  });
}
```

### Widget Tests with Riverpod

```dart
void main() {
  testWidgets('UserScreen displays user name', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userProvider('1').overrideWith((ref) async {
            return const User(id: '1', name: 'John', email: 'john@test.com');
          }),
        ],
        child: const MaterialApp(
          home: UserScreen(userId: '1'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('John'), findsOneWidget);
  });
}
```

## Code Style & Best Practices

1. **Naming Conventions**:
   - Files: `snake_case.dart`
   - Classes: `PascalCase`
   - Variables/Functions: `camelCase`
   - Constants: `camelCase` (or `SCREAMING_SNAKE_CASE` for compile-time constants)
   - Private members: prefix with `_`

2. **Immutability**:
   - Use `@freezed` for all data classes
   - Use `const` constructors wherever possible
   - Avoid mutable state outside Riverpod notifiers

3. **Null Safety**:
   - Avoid `!` operator; use null-aware operators (`?.`, `??`)
   - Use `required` parameters instead of nullable with assertions

4. **Async/Await**:
   - Always handle errors with try-catch or `Either`
   - Use `AsyncValue` in Riverpod for async states

5. **Separation of Concerns**:
   - Keep business logic in use cases
   - Keep UI logic in widgets/notifiers
   - Never mix layers (presentation shouldn't know about data sources)

6. **Provider Dependencies**:
   - Inject dependencies through providers
   - Use `ref.watch` for reactive dependencies
   - Keep provider graph clean and testable

## File Templates

### Feature Checklist

When creating a new feature, ensure you have:

- [ ] Domain entities (`domain/entities/`)
- [ ] Repository interface (`domain/repositories/`)
- [ ] Use cases (`domain/usecases/`)
- [ ] Data models with JSON serialization (`data/models/`)
- [ ] Remote data source (`data/datasources/`)
- [ ] Local data source if needed (`data/datasources/`)
- [ ] Repository implementation (`data/repositories/`)
- [ ] Riverpod providers (`presentation/providers/`)
- [ ] Screen widgets (`presentation/screens/`)
- [ ] Reusable widgets (`presentation/widgets/`)
- [ ] Unit tests for use cases
- [ ] Widget tests for screens

## Common Patterns

### Pagination

```dart
@riverpod
class UserListNotifier extends _$UserListNotifier {
  int _page = 1;
  bool _hasMore = true;

  @override
  Future<List<User>> build() async {
    return _fetchUsers();
  }

  Future<void> loadMore() async {
    if (!_hasMore || state.isLoading) return;

    _page++;
    final newUsers = await _fetchUsers();

    state = AsyncValue.data([
      ...state.value ?? [],
      ...newUsers,
    ]);

    if (newUsers.length < 20) _hasMore = false;
  }

  Future<List<User>> _fetchUsers() async {
    final repository = ref.read(userRepositoryProvider);
    final result = await repository.getUsers(page: _page);
    return result.fold((failure) => throw failure, (users) => users);
  }
}
```

### Search/Filtering

```dart
@riverpod
class SearchQuery extends _$SearchQuery {
  @override
  String build() => '';

  void update(String query) => state = query;
}

@riverpod
Future<List<User>> searchResults(SearchResultsRef ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.isEmpty) return [];

  // Debounce
  await Future.delayed(const Duration(milliseconds: 300));
  if (query != ref.read(searchQueryProvider)) return [];

  final repository = ref.watch(userRepositoryProvider);
  final result = await repository.searchUsers(query);
  return result.fold((failure) => throw failure, (users) => users);
}
```

### Form Validation

```dart
@freezed
class LoginState with _$LoginState {
  const factory LoginState({
    @Default('') String email,
    @Default('') String password,
    String? emailError,
    String? passwordError,
    @Default(false) bool isSubmitting,
  }) = _LoginState;
}

@riverpod
class LoginNotifier extends _$LoginNotifier {
  @override
  LoginState build() => const LoginState();

  void setEmail(String email) {
    state = state.copyWith(
      email: email,
      emailError: _validateEmail(email),
    );
  }

  void setPassword(String password) {
    state = state.copyWith(
      password: password,
      passwordError: _validatePassword(password),
    );
  }

  Future<void> submit() async {
    if (!_isValid()) return;

    state = state.copyWith(isSubmitting: true);
    final authUseCase = ref.read(loginUseCaseProvider);

    final result = await authUseCase.execute(
      email: state.email,
      password: state.password,
    );

    result.fold(
      (failure) => state = state.copyWith(isSubmitting: false),
      (_) => {/* Navigate to home */},
    );
  }

  String? _validateEmail(String email) {
    if (email.isEmpty) return 'Email is required';
    if (!email.contains('@')) return 'Invalid email';
    return null;
  }

  String? _validatePassword(String password) {
    if (password.isEmpty) return 'Password is required';
    if (password.length < 6) return 'Password too short';
    return null;
  }

  bool _isValid() {
    return _validateEmail(state.email) == null &&
           _validatePassword(state.password) == null;
  }
}
```

## Performance Optimization

1. **Use `const` constructors** - Reduce widget rebuilds
2. **Lazy loading** - Use `autoDispose` providers that load on-demand
3. **Select specific state** - Use `select` to watch only needed parts:
   ```dart
   final userName = ref.watch(userProvider.select((user) => user.name));
   ```
4. **Avoid rebuilding large trees** - Break widgets into smaller `ConsumerWidget`s
5. **Cache with keepAlive** - For expensive computations:
   ```dart
   @Riverpod(keepAlive: true)
   Future<AppConfig> appConfig(AppConfigRef ref) async {
     // Expensive operation
   }
   ```

## Migration Guide

When adding Clean Architecture + Riverpod to an existing project:

1. Install dependencies
2. Setup folder structure
3. Run `dart run build_runner watch`
4. Create core utilities (failures, exceptions)
5. Migrate features one at a time:
   - Start with domain layer (entities, repositories)
   - Add data layer (models, data sources, repository impl)
   - Convert StatefulWidgets to ConsumerWidgets
   - Replace setState with Riverpod providers
6. Add tests incrementally
