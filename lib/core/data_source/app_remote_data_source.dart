import 'dart:io';

import 'package:autograde_mobile/configs/service_locator.dart';
import 'package:autograde_mobile/core/api/models/api_base_message_model.dart';
import 'package:autograde_mobile/core/constants/api_endpoints.dart';
import 'package:autograde_mobile/core/cubits/auth/auth_cubit.dart';
import 'package:autograde_mobile/core/data_source/base_remote_data_source.dart';
import 'package:autograde_mobile/features/camera/models/extract_text_model.dart';
import 'package:autograde_mobile/features/home/models/history_item_model.dart';
import 'package:dio/dio.dart';

class AppRemoteDataSource extends BaseRemoteDataSource {
  @override
  void preRequestHook({required String endpoint, required RequestType method}) {
    final userToken = locator<AuthCubit>().getCurrentToken();
    if (userToken != null && userToken.isNotEmpty) {
      authorizeRequest(userToken);
    }
  }

  // Logout
  Future<BaseResponse<ApiBaseMessageModel>> logout(String endPoint) {
    return request(
      endpoint: endPoint,
      method: RequestType.post,
      transformer: (data) =>
          ApiBaseMessageModel.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<BaseResponse<EvalAnswerModel>> submitAnswer({
    required File file,
    required String subject,
  }) async {
    final fileName = file.path.split(RegExp(r'[\\/]+')).last;
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        file.path,
        filename: fileName,
      ),
      'subject': subject,
    });

    final token = locator<AuthCubit>().getCurrentToken();
    final headers = <String, dynamic>{};
    if (token != null && token.isNotEmpty) {
      headers[HttpHeaders.authorizationHeader] = 'Token $token';
    }

    return request(
      endpoint: ApiEndpoints.extractText,
      method: RequestType.post,
      contentType: 'multipart/form-data',
      headers: headers,
      data: formData,
      transformer: (data) =>
          EvalAnswerModel.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<BaseResponse<List<HistoryItemModel>>> getHistory() async {
    final token = locator<AuthCubit>().getCurrentToken();
    final headers = <String, dynamic>{};
    if (token != null && token.isNotEmpty) {
      headers[HttpHeaders.authorizationHeader] = 'Token $token';
    }

    return request(
      endpoint: ApiEndpoints.history,
      method: RequestType.get,
      headers: headers,
      transformer: (data) {
        final json = data as Map<String, dynamic>;
        final historyJson = json['history'] as List<dynamic>?;
        if (historyJson == null) {
          return <HistoryItemModel>[];
        }
        return historyJson
            .whereType<Map<String, dynamic>>()
            .map(HistoryItemModel.fromJson)
            .toList();
      },
    );
  }

}
