import 'package:freezed_annotation/freezed_annotation.dart';

part 'failures.freezed.dart';

@freezed
class Failure with _$Failure {
  const factory Failure.server(String message) = ServerFailure;
  const factory Failure.network() = NetworkFailure;
  const factory Failure.cache() = CacheFailure;
  const factory Failure.validation(String message) = ValidationFailure;
  const factory Failure.unexpected(String message) = UnexpectedFailure;
}
