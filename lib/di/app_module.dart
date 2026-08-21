import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:loan_calculator_simple/config/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

@module
abstract class AppModule {
  @preResolve
  Future<SharedPreferences> get sharedPreferences {
    return SharedPreferences.getInstance();
  }

  @lazySingleton
  ApiConfig get apiConfig => ApiConfig.fromEnvironment();

  @lazySingleton
  Dio dio(ApiConfig apiConfig) {
    final dio = Dio(
      BaseOptions(
        baseUrl: apiConfig.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        sendTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );

    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          logPrint: (object) => debugPrint(object.toString()),
        ),
      );
    }

    return dio;
  }
}
