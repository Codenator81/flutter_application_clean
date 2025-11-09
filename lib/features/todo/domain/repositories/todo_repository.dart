import 'package:flutter_application_clean/features/todo/domain/entities/todo.dart';

abstract class TodoRepository {
  Future<List<Todo>> getTodos();
  Future<Todo> addTodo(String title);
  Future<Todo> toggleTodo(String id);
  Future<void> deleteTodo(String id);
}
