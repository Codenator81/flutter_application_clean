import 'package:flutter_application_clean/features/todo/data/datasources/todo_local_datasource.dart';
import 'package:flutter_application_clean/features/todo/domain/entities/todo.dart';
import 'package:flutter_application_clean/features/todo/domain/repositories/todo_repository.dart';

class TodoRepositoryImpl implements TodoRepository {
  final TodoLocalDataSource dataSource;

  TodoRepositoryImpl(this.dataSource);

  @override
  Future<Todo> addTodo(String title) async {
    return dataSource.addTodo(title);
  }

  @override
  Future<void> deleteTodo(String id) async {
    return dataSource.deleteTodo(id);
  }

  @override
  Future<List<Todo>> getTodos() async {
    return dataSource.getTodos();
  }

  @override
  Future<Todo> toggleTodo(String id) async {
    return dataSource.toggleTodo(id);
  }
}
