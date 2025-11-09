import 'package:flutter_application_clean/features/todo/domain/entities/todo.dart';
import 'package:uuid/uuid.dart';

class TodoLocalDataSource {
  final List<Todo> _todos = [];
  final _uuid = const Uuid();

  List<Todo> getTodos() {
    return List.unmodifiable(_todos);
  }

  Todo addTodo(String title) {
    final todo = Todo(
      id: _uuid.v4(),
      title: title,
      isCompleted: false,
      createdAt: DateTime.now(),
    );
    _todos.add(todo);
    return todo;
  }

  Todo toggleTodo(String id) {
    final index = _todos.indexWhere((todo) => todo.id == id);
    if (index == -1) {
      throw Exception('Todo not found');
    }

    final todo = _todos[index];
    final updatedTodo = todo.copyWith(isCompleted: !todo.isCompleted);
    _todos[index] = updatedTodo;
    return updatedTodo;
  }

  void deleteTodo(String id) {
    _todos.removeWhere((todo) => todo.id == id);
  }
}
