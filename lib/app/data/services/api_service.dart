import 'package:dio/dio.dart';
import 'app_exceptions.dart';

class ApiService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://trogon.info/task/api/',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  Future<dynamic> getHomeData() async {
    return _safeApiCall(() => _dio.get('home.php'));
  }

  Future<dynamic> getCourseDetails(String courseId) async {
    return _safeApiCall(() => _dio.get('video_details.php'));
  }

  Future<dynamic> getStreakData() async {
    return _safeApiCall(() => _dio.get('streak.php'));
  }

  Future<dynamic> _safeApiCall(Future<Response> Function() call) async {
    try {
      final response = await call();
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw AppException('An unexpected error occurred: $e');
    }
  }

  Exception _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException(
          'Connection timed out. Please check your internet.',
        );
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 401)
          return UnauthorizedException('Session expired. Please login again.');
        if (statusCode == 400) return InvalidInputException('Bad request.');
        if (statusCode! >= 500)
          return ServerException('Server side error. Please try later.');
        return AppException('Received invalid status code: $statusCode');
      case DioExceptionType.cancel:
        return AppException('Request was cancelled.');
      case DioExceptionType.connectionError:
        return NetworkException('No internet connection.');
      default:
        return AppException('Something went wrong. Please try again.');
    }
  }
}
