class AppException implements Exception {
  final String message;
  final String? prefix;

  AppException(this.message, [this.prefix]);

  @override
  String toString() {
    return "${prefix ?? ''}$message";
  }
}

class NetworkException extends AppException {
  NetworkException(String message) : super(message, "Network Error: ");
}

class ServerException extends AppException {
  ServerException(String message) : super(message, "Server Error: ");
}

class UnauthorizedException extends AppException {
  UnauthorizedException(String message) : super(message, "Unauthorized: ");
}

class InvalidInputException extends AppException {
  InvalidInputException(String message) : super(message, "Invalid Input: ");
}
