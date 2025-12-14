import 'dart:async';
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:autograde_mobile/core/api/api_state.dart';
import 'package:autograde_mobile/core/data_source/base_remote_data_source.dart';

abstract class AppApiCubit<T> extends Cubit<ApiState<T>> {
  AppApiCubit() : super(const ApiInitialState());

  Future<BaseResponse<T?>?> call(
    Future<BaseResponse<T?>> Function() caller, {
    void Function()? onSuccess,
    void Function()? onError,
  }) async {
    try {
      if (state is ApiLoadingState) return null;
      emitLoading();
      final response = await caller.call();

      response.fold(
        (error) {
          log('Error Response: $error', name: 'ApiCubit');
          emitError(message: error.message, errorCode: error.statusCode);
          onError?.call();
        },
        (data) {
          if (data != null) {
            emitLoaded(data: data, statusCode: 200);
            onSuccess?.call();
          } else {
            emitError(message: 'Data is null');
            onError?.call();
          }
        },
      );

      return response;
    } catch (error) {
      log('Error: $error ${(error as Error).stackTrace}', name: 'ApiCubit');
      emitError(message: error.toString());
    }
    return null;
  }

  void emitLoading() {
    emit(const ApiLoadingState());
  }

  void emitError({required String message, int? errorCode}) {
    emit(ApiErrorState(error: message, statusCode: errorCode));
  }

  void emitLoaded({required T data, required int statusCode}) {
    emit(ApiLoadedState(data: data, statusCode: statusCode));
  }
}
