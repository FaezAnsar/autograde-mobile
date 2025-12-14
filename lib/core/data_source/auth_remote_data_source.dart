// This is for authentication APIs

import 'package:autograde_mobile/core/data_source/base_remote_data_source.dart';

class AuthRemoteDataSource extends BaseRemoteDataSource {
  // Future<BaseResponse<ApiBaseMessageModel>> sendOtp({
  //   required String endPoint,
  //   required String phoneNumber,
  // }) {
  //   return request(
  //     endpoint: endPoint,
  //     method: RequestType.post,
  //     data: {'phone': phoneNumber},
  //     transformer: (data) =>
  //         ApiBaseMessageModel.fromJson(data as Map<String, dynamic>),
  //   );
  // }

  // Future<BaseResponse<ApiBaseMessageModel>> verifyEmailOtp({
  //   required String email,
  //   required String otp,
  // }) {
  //   return request(
  //     endpoint: ApiEndpoints.verifyEmailOtp,
  //     method: RequestType.post,
  //     data: {'email': email, 'otp': otp},
  //     transformer: (data) =>
  //         ApiBaseMessageModel.fromJson(data as Map<String, dynamic>),
  //   );
  // }

  // Future<BaseResponse<ApiBaseMessageModel>> resendEmailOtp({
  //   required String email,
  // }) {
  //   return request(
  //     endpoint: ApiEndpoints.resendEmailVerificationOtpUrl,
  //     method: RequestType.post,
  //     data: {'email': email},
  //     transformer: (data) =>
  //         ApiBaseMessageModel.fromJson(data as Map<String, dynamic>),
  //   );
  // }

  // Future<BaseResponse<LogInModel>> registration({
  //   required String email,
  //   required String password,
  //   required String name,
  //   required String phone,
  //   required UserType userType,
  // }) {
  //   switch (userType) {
  //     case UserType.coach:
  //       return coachRegistration(
  //         name: name,
  //         email: email,
  //         phone: phone,
  //         password: password,
  //       );

  //     case UserType.parent:
  //       return parentRegistration(
  //         name: name,
  //         email: email,
  //         phone: phone,
  //         password: password,
  //       );

  //     case UserType.athlete:
  //       return athleteRegistration(
  //         name: name,
  //         email: email,
  //         phone: phone,
  //         password: password,
  //       );
  //   }
  // }

  // Future<BaseResponse<LogInModel>> coachRegistration({
  //   required String name,
  //   required String email,
  //   required String phone,
  //   required String password,
  // }) async {
  //   final token = await FirebaseMessaging.instance.getToken();
  //   return request(
  //     endpoint: ApiEndpoints.coachRegistrationUrl,
  //     method: RequestType.post,
  //     data: {
  //       'name': name,
  //       'email': email,
  //       'phone': phone,
  //       'password': password,
  //       'fcm_token': token,
  //     },
  //     transformer: (data) => LogInModel.fromJson(data as Map<String, dynamic>),
  //   );
  // }

  // Future<BaseResponse<LogInModel>> parentRegistration({
  //   required String name,
  //   required String email,
  //   required String phone,
  //   required String password,
  // }) async {
  //   final token = await FirebaseMessaging.instance.getToken();
  //   return request(
  //     endpoint: ApiEndpoints.parentRegistrationUrl,
  //     method: RequestType.post,
  //     data: {
  //       'name': name,
  //       'email': email,
  //       'phone': phone,
  //       'password': password,
  //       'fcm_token': token,
  //     },
  //     transformer: (data) => LogInModel.fromJson(data as Map<String, dynamic>),
  //   );
  // }

  // Future<BaseResponse<LogInModel>> athleteRegistration({
  //   required String name,
  //   required String email,
  //   required String phone,
  //   required String password,
  // }) async {
  //   final token = await FirebaseMessaging.instance.getToken();
  //   return request(
  //     endpoint: ApiEndpoints.athleteRegistrationUrl,
  //     method: RequestType.post,
  //     data: {
  //       'name': name,
  //       'email': email,
  //       'phone': phone,
  //       'password': password,
  //       'fcm_token': token,
  //     },
  //     transformer: (data) => LogInModel.fromJson(data as Map<String, dynamic>),
  //   );
  // }

  // ////Logins
  // Future<BaseResponse<LogInModel>> logIn({
  //   required String email,
  //   required String password,
  //   required String token,
  // }) async {
  //   return request(
  //     endpoint: ApiEndpoints.loginUrl,
  //     method: RequestType.post,
  //     data: {'email': email, 'password': password, 'fcm_token': token},
  //     transformer: (data) {
  //       return LogInModel.fromJson(data as Map<String, dynamic>);
  //     },
  //   );
  // }
}
