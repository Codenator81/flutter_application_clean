import 'package:flutter_application_clean/features/todo/data/datasources/todo_local_datasource.dart';
import 'package:flutter_application_clean/features/todo/data/repositories/todo_repository_impl.dart';
import 'package:flutter_application_clean/features/todo/domain/entities/todo.dart';
import 'package:flutter_application_clean/features/todo/domain/repositories/todo_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'todo_providers.g.dart';

// Data Source Provider
@riverpod
TodoLocalDataSource todoLocalDataSource(TodoLocalDataSourceRef ref) {
  return TodoLocalDataSource();
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
    return repository.getTodos();
  }

  Future<void> addTodo(String title) async {
    final repository = ref.read(todoRepositoryProvider);
    await repository.addTodo(title);
    ref.invalidateSelf(); // Refresh the list
  }

  Future<void> toggleTodo(String id) async {
    final repository = ref.read(todoRepositoryProvider);
    await repository.toggleTodo(id);
    ref.invalidateSelf(); // Refresh the list
  }

  Future<void> deleteTodo(String id) async {
    final repository = ref.read(todoRepositoryProvider);
    await repository.deleteTodo(id);
    ref.invalidateSelf(); // Refresh the list
  }
}
