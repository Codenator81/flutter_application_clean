import 'package:hive/hive.dart';
import 'package:flutter_application_clean/features/todo/domain/entities/todo.dart';

part 'todo_model.g.dart';

@HiveType(typeId: 0)
class TodoModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final bool isCompleted;

  @HiveField(3)
  final DateTime? createdAt;

  TodoModel({
    required this.id,
    required this.title,
    required this.isCompleted,
    this.createdAt,
  });

  // Convert Model to Domain Entity
  Todo toEntity() {
    return Todo(
      id: id,
      title: title,
      isCompleted: isCompleted,
      createdAt: createdAt,
    );
  }

  // Convert Domain Entity to Model
  factory TodoModel.fromEntity(Todo todo) {
    return TodoModel(
      id: todo.id,
      title: todo.title,
      isCompleted: todo.isCompleted,
      createdAt: todo.createdAt,
    );
  }
}
