// This is for authentication APIs

import 'package:autograde_mobile/core/api/models/api_base_message_model.dart';
import 'package:autograde_mobile/core/constants/api_endpoints.dart';
import 'package:autograde_mobile/core/data_source/base_remote_data_source.dart';
import 'package:autograde_mobile/core/models/login_model.dart';
import 'package:dio/dio.dart';

class AuthRemoteDataSource extends BaseRemoteDataSource {
  Future<BaseResponse<LogInModel>> signup({
    required String username,
    required String email,
    required String password,
  }) {
    return request(
      endpoint: ApiEndpoints.signupUrl,
      method: RequestType.post,
      contentType: Headers.jsonContentType,
      data: {
        'username': username,
        'email': email,
        'password': password,
      },
      transformer: (data) => LogInModel.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<BaseResponse<LogInModel>> login({
    required String username,
    required String password,
  }) {
    return request(
      endpoint: ApiEndpoints.loginUrl,
      method: RequestType.post,
      contentType: Headers.jsonContentType,
      data: {
        'username': username,
        'password': password,
      },
      transformer: (data) => LogInModel.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<BaseResponse<ApiBaseMessageModel>> logout({
    required String token,
  }) {
    return request(
      endpoint: ApiEndpoints.logoutUrl,
      method: RequestType.post,
      contentType: Headers.jsonContentType,
      headers: {'Authorization': 'Token $token'},
      data: {},
      transformer: (data) => ApiBaseMessageModel.fromJson(data as Map<String, dynamic>),
    );
  }
}
