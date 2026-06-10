import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const _baseUrl = String.fromEnvironment('API_URL', defaultValue: 'http://10.0.2.2:8000/api');

class ApiService {
  static final ApiService _instance = ApiService._();
  factory ApiService() => _instance;
  ApiService._() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'token');
        if (token != null) options.headers['Authorization'] = 'Bearer $token';
        handler.next(options);
      },
      onError: (err, handler) {
        if (err.response?.statusCode == 401) {
          _storage.deleteAll();
        }
        handler.next(err);
      },
    ));
  }

  final _storage = const FlutterSecureStorage();
  final _dio = Dio(BaseOptions(
    baseUrl: _baseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 30),
  ));

  Dio get dio => _dio;

  Future<void> saveToken(String token) => _storage.write(key: 'token', value: token);
  Future<String?> getToken() => _storage.read(key: 'token');
  Future<void> clearToken() => _storage.deleteAll();
}
