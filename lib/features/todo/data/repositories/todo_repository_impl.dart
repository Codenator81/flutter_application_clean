import 'package:flutter_application_clean/core/errors/exceptions.dart';
import 'package:flutter_application_clean/core/errors/failures.dart';
import 'package:flutter_application_clean/features/todo/data/datasources/todo_local_datasource.dart';
import 'package:flutter_application_clean/features/todo/domain/entities/todo.dart';
import 'package:flutter_application_clean/features/todo/domain/repositories/todo_repository.dart';
import 'package:fpdart/fpdart.dart';

class TodoRepositoryImpl implements TodoRepository {
  final TodoLocalDataSource dataSource;

  TodoRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, Todo>> addTodo(String title) async {
    try {
      if (title.trim().isEmpty) {
        return const Left(Failure.validation('Title cannot be empty'));
      }
      final todo = dataSource.addTodo(title);
      return Right(todo);
    } on CacheException {
      return const Left(Failure.cache());
    } catch (e) {
      return Left(Failure.unexpected(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTodo(String id) async {
    try {
      dataSource.deleteTodo(id);
      return const Right(null);
    } on CacheException {
      return const Left(Failure.cache());
    } catch (e) {
      return Left(Failure.unexpected(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Todo>>> getTodos() async {
    try {
      final todos = dataSource.getTodos();
      return Right(todos);
    } on CacheException {
      return const Left(Failure.cache());
    } catch (e) {
      return Left(Failure.unexpected(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Todo>> updateTodo(String id, String newTitle) async {
    try {
      if (newTitle.trim().isEmpty) {
        return const Left(Failure.validation('Title cannot be empty'));
      }
      final todo = dataSource.updateTodo(id, newTitle);
      return Right(todo);
    } on CacheException {
      return const Left(Failure.cache());
    } catch (e) {
      return Left(Failure.unexpected(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Todo>> toggleTodo(String id) async {
    try {
      final todo = dataSource.toggleTodo(id);
      return Right(todo);
    } on CacheException {
      return const Left(Failure.cache());
    } catch (e) {
      return Left(Failure.unexpected(e.toString()));
    }
  }
}
