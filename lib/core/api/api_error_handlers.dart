import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:autograde_mobile/configs/service_locator.dart';
import 'package:autograde_mobile/core/api/api_exception.dart';
import 'package:autograde_mobile/core/cubits/auth/auth_cubit.dart';
import 'package:autograde_mobile/core/utils/helpers.dart';

mixin ApiErrorHandlers {
  Either<ApiException, T> handleDioException<T>(DioException e) {
    log('ApiException: ${e.response?.data ?? e.message}', name: 'ApiErrorHandlers');

    String message = 'Unknown error';
    final responseData = e.response?.data;
    if (responseData is Map<String, dynamic>) {
      message = (responseData['message'] as String?) ??
          (responseData['detail'] as String?) ??
          message;
    } else if (responseData is String) {
      message = responseData;
    } else if (e.message?.isNotEmpty == true) {
      message = e.message ?? message;
    }

    return left(
      ApiException(
        url: e.requestOptions.path,
        message: message,
        response: e.response,
        statusCode: e.response?.statusCode,
      ),
    );
  }

  Either<ApiException, T> redirectUnauthenticatedHandler<T>(DioException e) {
    if (e.response?.statusCode == 401) {
      // AuthManager.instance.destroySession();
      locator<AuthCubit>().unAuthorizeUser();
      displayToastMessage('Unauthorized, please login again');

      return left(
        ApiException(
          url: e.requestOptions.path,
          message: 'Unauthorized, please login again',
          response: e.response,
          statusCode: e.response?.statusCode,
        ),
      );
    } else {
      return handleDioException(e);
    }
  }
}
