import 'package:flutter_application_clean/core/errors/failures.dart';
import 'package:flutter_application_clean/features/todo/domain/entities/todo.dart';
import 'package:fpdart/fpdart.dart';

abstract class TodoRepository {
  Future<Either<Failure, List<Todo>>> getTodos();
  Future<Either<Failure, Todo>> addTodo(String title);
  Future<Either<Failure, Todo>> toggleTodo(String id);
  Future<Either<Failure, void>> deleteTodo(String id);
}
