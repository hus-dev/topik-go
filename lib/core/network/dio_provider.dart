import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:topik_go/core/auth/session_store.dart';

const _apiBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: '');

String get resolvedApiBaseUrl {
  if (_apiBaseUrl.isNotEmpty) return _apiBaseUrl;
  
  // Use the specific internal IP provided by the backend team for physical device testing.
  // For Android Emulator, 10.0.2.2 is still a standard fallback.
  if (defaultTargetPlatform == TargetPlatform.android && !kIsWeb) {
    // If you are testing on a PHYSICAL Android device, this IP will be used.
    // If you are testing on an EMULATOR, you can still pass --dart-define=API_BASE_URL=http://10.0.2.2:3000
    return 'http://10.188.191.214:3000';
  }
  
  return 'http://10.188.191.214:3000';
}

final dioProvider = Provider<Dio>((ref) {
  final sessionStore = ref.watch(sessionStoreProvider);
  final baseUrl = resolvedApiBaseUrl;
  
  if (kDebugMode) {
    debugPrint('Connecting to API at: $baseUrl');
  }

  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      contentType: 'application/json',
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await sessionStore.readToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          await sessionStore.clearToken();
        }
        handler.next(error);
      },
    ),
  );

  if (kDebugMode) {
    dio.interceptors.add(LogInterceptor(responseBody: true));
  }

  return dio;
});
