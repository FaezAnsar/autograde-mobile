import 'dart:io';

import 'package:autograde_mobile/configs/service_locator.dart';
import 'package:autograde_mobile/core/api/api_cubit.dart';
import 'package:autograde_mobile/core/api/api_state.dart';
import 'package:autograde_mobile/core/data_source/app_remote_data_source.dart';
import 'package:autograde_mobile/core/utils/helpers.dart';
import 'package:autograde_mobile/features/camera/models/extract_text_model.dart';

class EvaluateAnswerCubit extends AppApiCubit<EvalAnswerModel> {
  final AppRemoteDataSource _appRemoteDataSource = locator();

  bool isSuccess = false;

  Future<void> evalAns({required File image}) async {
    await call(
      () {
        return _appRemoteDataSource.submitAnswer(image: image);
      },
      onSuccess: () {
        if (state is ApiLoadedState) {
          isSuccess = true;
          final response = (state as ApiLoadedState<EvalAnswerModel>).data;
          displayToastMessage(response.message ?? '');
        }
      },
      onError: () {
        if (state is ApiErrorState) {
          displayToastMessage((state as ApiErrorState).error);
        }
      },
    );
  }
}
