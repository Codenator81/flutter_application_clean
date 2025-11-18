import 'package:flutter_application_clean/features/todo/data/models/todo_model.dart';
import 'package:flutter_application_clean/features/todo/domain/entities/todo.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

class TodoLocalDataSource {
  final Box<TodoModel> box;
  final _uuid = const Uuid();

  TodoLocalDataSource(this.box);

  List<Todo> getTodos() {
    return box.values.map((model) => model.toEntity()).toList();
  }

  Todo addTodo(String title) {
    final model = TodoModel(
      id: _uuid.v4(),
      title: title,
      isCompleted: false,
      createdAt: DateTime.now(),
    );
    box.put(model.id, model);
    return model.toEntity();
  }

  Todo toggleTodo(String id) {
    final model = box.get(id);
    if (model == null) {
      throw Exception('Todo not found');
    }

    final updatedModel = TodoModel(
      id: model.id,
      title: model.title,
      isCompleted: !model.isCompleted,
      createdAt: model.createdAt,
    );
    box.put(id, updatedModel);
    return updatedModel.toEntity();
  }

  Todo updateTodo(String id, String newTitle) {
  final model = box.get(id);
  if (model == null) {
    throw Exception('Todo not found');
  }

  final updatedModel = TodoModel(
    id: model.id,
    title: newTitle,
    isCompleted: model.isCompleted,
    createdAt: model.createdAt,
  );
  box.put(id, updatedModel);
  return updatedModel.toEntity();
}

  void deleteTodo(String id) {
    box.delete(id);
  }
}