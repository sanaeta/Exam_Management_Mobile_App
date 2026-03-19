import 'package:dio/dio.dart';

class DioClient {
  late Dio dio;

  String? token;

  DioClient({this.token}) {
    dio = Dio(
      BaseOptions(
        baseUrl: 'http://10.0.2.2:8000/api/',
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );

    dio.interceptors.add(LogInterceptor(responseBody: true));
  }
}