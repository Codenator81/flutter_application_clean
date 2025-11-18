import 'package:flutter_application_clean/features/todo/data/datasources/todo_local_datasource.dart';
import 'package:flutter_application_clean/features/todo/data/models/todo_model.dart';
import 'package:flutter_application_clean/features/todo/data/repositories/todo_repository_impl.dart';
import 'package:flutter_application_clean/features/todo/domain/entities/todo.dart';
import 'package:flutter_application_clean/features/todo/domain/repositories/todo_repository.dart';
import 'package:hive/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'todo_providers.g.dart';

// Hive Box Provider
@Riverpod(keepAlive: true)
Future<Box<TodoModel>> todoBox(TodoBoxRef ref) async {
  // Open the box (creates if doesn't exist)
  return await Hive.openBox<TodoModel>('todos');
}

// Data Source Provider
@riverpod
TodoLocalDataSource todoLocalDataSource(TodoLocalDataSourceRef ref) {
  final box = ref.watch(todoBoxProvider).requireValue;
  return TodoLocalDataSource(box);
}

// Repository Provider
@riverpod
TodoRepository todoRepository(TodoRepositoryRef ref) {
  final dataSource = ref.watch(todoLocalDataSourceProvider);
  return TodoRepositoryImpl(dataSource);
}

// Todo List Provider (State)
@riverpod
class TodoList extends _$TodoList {
  @override
  Future<List<Todo>> build() async {
    final repository = ref.watch(todoRepositoryProvider);
    final result = await repository.getTodos();

    return result.fold(
      (failure) => throw failure, // AsyncValue will catch this
      (todos) => todos, // Return success data
    );
  }

  Future<void> addTodo(String title) async {
    final repository = ref.read(todoRepositoryProvider);
    final result = await repository.addTodo(title);
    return result.fold(
      (failure) => throw failure, //  Will be caught by caller
      (_) => ref.invalidateSelf(), // Success - refresh list
    );
  }

  Future<void> toggleTodo(String id) async {
    final repository = ref.read(todoRepositoryProvider);
    final result = await repository.toggleTodo(id);
    return result.fold(
      (failure) => throw failure, //  Will be caught by caller
      (_) => ref.invalidateSelf(), // Success - refresh list
    );
  }

  Future<void> updateTodo(String id, String newTitle) async {
    final repository = ref.read(todoRepositoryProvider);
    final result = await repository.updateTodo(id, newTitle);

    result.fold((failure) => throw failure, (_) => ref.invalidateSelf());
  }

  Future<void> deleteTodo(String id) async {
    final repository = ref.read(todoRepositoryProvider);
    final result = await repository.deleteTodo(id);
    result.fold((failure) => throw failure, (_) => ref.invalidateSelf());
  }
}
