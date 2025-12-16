import 'package:dio/dio.dart';
import 'package:hertzmobile/models/auth_models.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.50.92:8001/api';

  late Dio _dio;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        responseType: ResponseType.json,
        contentType: 'application/json',
      ),
    );
  }

  /// Set authorization token for authenticated requests
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  /// Clear authorization token
  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }

  /// Login API
  Future<LoginResponse> login(LoginRequest request) async {
    try {
      print(request.toJson());
      final response = await _dio.post('/auth/login', data: request.toJson());
      return LoginResponse.fromJson(response.data);
    } on DioException catch (e) {
      print(e.response?.data);
      return LoginResponse(
        success: false,
        message: e.response?.data['message'] ?? 'Login failed',
        statusCode: e.response?.statusCode ?? 0,
        errors: e.response?.data['errors'] as Map<String, dynamic>?,
      );
    } catch (e) {
      return LoginResponse(
        success: false,
        message: 'An unexpected error occurred',
        statusCode: 0,
      );
    }
  }

  /// Register API
  Future<RegisterResponse> register(RegisterRequest request) async {
    try {
      final response = await _dio.post(
        '/auth/register',
        data: request.toJson(),
      );
      return RegisterResponse.fromJson(response.data);
    } on DioException catch (e) {
      return RegisterResponse(
        success: false,
        message: e.response?.data['message'] ?? 'Registration failed',
        statusCode: e.response?.statusCode ?? 0,
        errors: e.response?.data['errors'] as Map<String, dynamic>?,
      );
    } catch (e) {
      return RegisterResponse(
        success: false,
        message: 'An unexpected error occurred',
        statusCode: 0,
      );
    }
  }
}
