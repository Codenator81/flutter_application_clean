class ServerException implements Exception {
  final String message;

  ServerException(this.message);

  @override
  String toString() => 'ServerException: $message';
}

class NetworkException implements Exception {
  @override
  String toString() => 'NetworkException: No internet connection';
}

class CacheException implements Exception {
  @override
  String toString() => 'CacheException: Failed to access cache';
}

class ValidationException implements Exception {
  final String message;

  ValidationException(this.message);

  @override
  String toString() => 'ValidationException: $message';
}
