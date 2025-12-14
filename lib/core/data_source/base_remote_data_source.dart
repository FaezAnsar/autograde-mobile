import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:autograde_mobile/core/api/api_error_handlers.dart';
import 'package:autograde_mobile/core/api/api_exception.dart';
import 'package:autograde_mobile/core/api/cache_manager.dart';
import 'package:autograde_mobile/core/constants/api_endpoints.dart';
import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

typedef BaseResponse<T> = Either<ApiException, T>;

enum RequestType { get, post, put, delete }

abstract class BaseRemoteDataSource with ApiErrorHandlers, DioCacheManager {
  BaseRemoteDataSource({
    this.baseUrl = ApiEndpoints.baseUrl,
    Map<String, dynamic>? requestHeaders,
  }) : baseHeaders = requestHeaders ?? {};

  final String baseUrl;
  final Map<String, dynamic> baseHeaders;

  Future<BaseResponse<T>> request<T>({
    required String endpoint,
    required RequestType method,
    required T Function(dynamic data) transformer,
    Map<String, dynamic>? param,
    Map<String, dynamic>? headers,
    String? contentType,
    Object? data,
    Either<ApiException, T> Function<T>(DioException e)? dioErrorHandler,
    bool useCache = false,
  }) async {
    dioErrorHandler ??= redirectUnauthenticatedHandler;

    try {
      preRequestHook(endpoint: endpoint, method: method);
      final dio =
          Dio(
              BaseOptions(
                baseUrl: baseUrl,
                contentType: contentType,
                headers: {
                  HttpHeaders.acceptHeader: Headers.jsonContentType,
                  ...baseHeaders,
                  ...?headers,
                },
                responseType: ResponseType.json,
              ),
            )
            ..interceptors.addAll([
              PrettyDioLogger(
                requestHeader: true,
                requestBody: true,
                responseBody: true,
                responseHeader: false,
                error: true,
                compact: true,
                maxWidth: 120,
              ),
              if (useCache) await getCacheInterceptor(),
            ]);

      Future<Response<dynamic>> request;

      switch (method) {
        case RequestType.post:
          request = dio.post(endpoint, data: param ?? data);
        case RequestType.get:
          request = dio.get(endpoint, queryParameters: param);
        case RequestType.put:
          request = dio.put(endpoint, data: param ?? data);
        case RequestType.delete:
          request = dio.delete(endpoint, data: param ?? data);
      }

      final response = await request;
      postRequestHook(endpoint: endpoint, method: method, response: response);

      if (response.data != null) {
        return right(transformer(response.data));
      } else {
        return left(
          ApiException(
            url: endpoint,
            message: 'No data found',
            response: response,
            statusCode: response.statusCode,
          ),
        );
      }
    } catch (e) {
      if (e is DioException) {
        return dioErrorHandler(e);
      } else {
        if (e is Error) {
          log('Error: $e ${(e).stackTrace}', name: 'BaseRemoteDataSource');
        } else if (e is Exception) {
          log('Error: $e', name: 'BaseRemoteDataSource');
        }
        return left(
          ApiException(
            url: endpoint,
            message: 'Network error',
            response: null,
            statusCode: null,
          ),
        );
      }
    }
  }

  void authorizeRequest(String token) {
    baseHeaders['Authorization'] = 'Bearer $token';
  }

  /// Runs before every request
  void preRequestHook({
    required String endpoint,
    required RequestType method,
  }) {}

  /// Only runs for successful requests
  void postRequestHook({
    required String endpoint,
    required RequestType method,
    required Response<dynamic> response,
  }) {}
}
