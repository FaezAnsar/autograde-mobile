import 'dart:io';

import 'package:autograde_mobile/configs/service_locator.dart';
import 'package:autograde_mobile/core/api/models/api_base_message_model.dart';
import 'package:autograde_mobile/core/constants/api_endpoints.dart';
import 'package:autograde_mobile/core/cubits/auth/auth_cubit.dart';
import 'package:autograde_mobile/core/data_source/base_remote_data_source.dart';
import 'package:autograde_mobile/features/camera/models/extract_text_model.dart';
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
    required File image,
  }) async {
    return request(
      endpoint: ApiEndpoints.extractText,
      method: RequestType.post,
      data: FormData.fromMap({
        'file': await MultipartFile.fromFile(
          image.path,
          filename: image.path.split('/').last,
        ),
      }),
      transformer: (data) =>
          EvalAnswerModel.fromJson(data as Map<String, dynamic>),
    );
  }

  //----------------------------Posts----------------------------//
  //   Future<BaseResponse<ApiBasePaginatedModel<PostModel>>> getPosts({
  //     required int page,
  //     String? sort,
  //   }) {
  //     return request(
  //       endpoint: ApiEndpoints.getPostsUrl,
  //       param: {'page': page, 'sort': sort ?? SortType.latest.path},
  //       method: RequestType.get,
  //       transformer: (data) {
  //         return ApiBasePaginatedModel<PostModel>.fromJson(
  //           data as Map<String, dynamic>,
  //           dataParser: (e) => PostModel.fromJson(e as Map<String, dynamic>),
  //         );
  //       },
  //     );
  //   }

  //   Future<BaseResponse<ApiBasePaginatedModel<PostModel>>> getUserPost(
  //       {required int page, required int userId}) {
  //     return request(
  //       endpoint: ApiEndpoints.getUserPostsUrl(userId),
  //       param: {'page': page},
  //       method: RequestType.get,
  //       transformer: (data) => (ApiBasePaginatedModel<PostModel>.fromJson(
  //         data as Map<String, dynamic>,
  //         dataParser: (e) => PostModel.fromJson(e as Map<String, dynamic>),
  //       )),
  //     );
  //   }

  //   Future<BaseResponse<PostModel>> getPost({required int postId}) {
  //     return request(
  //       endpoint: ApiEndpoints.getUpdateAndDeletePostUrl(postId),
  //       method: RequestType.get,
  //       transformer: (data) => PostModel.fromJson(data['post'] as Map<String, dynamic>),
  //     );
  //   }

  //   Future<BaseResponse<ApiBaseMessageModel>> createPost({
  //     required File? image,
  //     required String content,
  //     required List<String>? tags,
  //   }) async {
  //     return request(
  //       endpoint: ApiEndpoints.createPostUrl,
  //       method: RequestType.post,
  //       data: FormData.fromMap(
  //         {
  //           'cover_image': image != null
  //               ? await MultipartFile.fromFile(
  //                   image.path,
  //                   filename: image.path.split('/').last,
  //                 )
  //               : null,
  //           'content': content,
  //           'tags': tags,
  //         },
  //       ),
  //       transformer: (data) => ApiBaseMessageModel.fromJson(data as Map<String, dynamic>),
  //     );
  //   }

  //   Future<BaseResponse<ApiBaseMessageModel>> updatePost({
  //     required int postId,
  //     required String title,
  //     required File? image,
  //     required String content,
  //     required List<String>? tags,
  //   }) async {
  //     return request(
  //       endpoint: ApiEndpoints.getUpdateAndDeletePostUrl(postId),
  //       method: RequestType.post,
  //       data: FormData.fromMap(
  //         {
  //           'title': title,
  //           'cover_image': image != null
  //               ? await MultipartFile.fromFile(
  //                   image.path,
  //                   filename: image.path.split('/').last,
  //                 )
  //               : null,
  //           'content': content,
  //           'tags': tags,
  //         },
  //       ),
  //       transformer: (data) => ApiBaseMessageModel.fromJson(data as Map<String, dynamic>),
  //     );
  //   }

  //   //----------------------------Comments----------------------------//
  //   Future<BaseResponse<ApiBasePaginatedModel<CommentModel>>> getPostComments(int postId, int page) {
  //     return request(
  //       endpoint: ApiEndpoints.getPostCommentsUrl(postId),
  //       param: {'post_id': postId, 'page': page},
  //       method: RequestType.get,
  //       transformer: (data) => (ApiBasePaginatedModel<CommentModel>.fromJson(
  //         data as Map<String, dynamic>,
  //         dataParser: (e) => CommentModel.fromJson(e as Map<String, dynamic>),
  //       )),
  //     );
  //   }

  //   Future<BaseResponse<ApiBaseMessageModel>> createComment({
  //     required String content,
  //     required int postId,
  //   }) {
  //     return request(
  //       data: {
  //         'content': content,
  //       },
  //       endpoint: ApiEndpoints.createCommentUrl(postId),
  //       method: RequestType.post,
  //       transformer: (data) => ApiBaseMessageModel.fromJson(data as Map<String, dynamic>),
  //     );
  //   }

  //   //----------------------------Likes----------------------------//

  //   Future<BaseResponse<ApiBaseMessageModel>> createLike({
  //     required String? reactionType,
  //     required int postId,
  //   }) {
  //     return request(
  //       data: {
  //         'reaction_type': reactionType,
  //       },
  //       endpoint: ApiEndpoints.reactOnPostUrl(postId),
  //       method: RequestType.post,
  //       transformer: (data) => ApiBaseMessageModel.fromJson(data as Map<String, dynamic>),
  //     );
  //   }

  //   Future<BaseResponse<ApiBaseMessageModel>> deletePost(int postId) {
  //     return request(
  //       endpoint: ApiEndpoints.getUpdateAndDeletePostUrl(postId),
  //       method: RequestType.delete,
  //       transformer: (data) => ApiBaseMessageModel.fromJson(data as Map<String, dynamic>),
  //     );
  //   }

  //   //----------------------------Favorite Post----------------------------//
  //   Future<BaseResponse<ApiBasePaginatedModel<PostModel>>> getFavoritePosts(int page) {
  //     return request(
  //       endpoint: ApiEndpoints.getFavoritePostsUrl,
  //       param: {'page': page},
  //       method: RequestType.get,
  //       transformer: (data) => (ApiBasePaginatedModel<PostModel>.fromJson(
  //         data as Map<String, dynamic>,
  //         dataParser: (e) => PostModel.fromJson(e as Map<String, dynamic>),
  //       )),
  //     );
  //   }

  //   //----------------------------Add Favorite Post----------------------------//
  //   Future<BaseResponse<ApiBaseMessageModel>> addFavoritePost(int postId) {
  //     return request(
  //       endpoint: ApiEndpoints.addOrRemoveFavoritePostUrl(postId),
  //       method: RequestType.post,
  //       transformer: (data) => ApiBaseMessageModel.fromJson(data as Map<String, dynamic>),
  //     );
  //   }

  //   Future<BaseResponse<ApiBaseMessageModel>> removeFavoritePost(int postId) {
  //     return request(
  //       endpoint: ApiEndpoints.addOrRemoveFavoritePostUrl(postId),
  //       method: RequestType.delete,
  //       transformer: (data) => ApiBaseMessageModel.fromJson(data as Map<String, dynamic>),
  //     );
  //   }

  //   //----------------------------Report----------------------------//
  //   Future<BaseResponse<ApiBaseMessageModel>> doReport({
  //     required int id,
  //     required String type,
  //     required String reason,
  //     required String description,
  //   }) {
  //     return request(
  //       data: {
  //         'content_id': id,
  //         'content_type': type,
  //         'reason': reason,
  //         'description ': description,
  //       },
  //       endpoint: ApiEndpoints.reportUrl,
  //       method: RequestType.post,
  //       transformer: (data) => ApiBaseMessageModel.fromJson(data as Map<String, dynamic>),
  //     );
  //   }

  //   //----------------------------Space----------------------------//

  //   // Create space
  //   Future<BaseResponse<ApiBaseMessageModel>> createSpace({
  //     required final String spaceName,
  //     required final List<int> userIdList,
  //   }) {
  //     return request(
  //       data: jsonEncode({
  //         'name': spaceName,
  //         'other_user_ids': userIdList,
  //       }),
  //       endpoint: ApiEndpoints.createSpaceUrl,
  //       method: RequestType.post,
  //       transformer: (data) => ApiBaseMessageModel.fromJson(data as Map<String, dynamic>),
  //     );
  //   }

  //   // Get spaces
  //   Future<BaseResponse<ApiBasePaginatedModel<SpaceModel>>> getSpaceList(int page) {
  //     return request(
  //       endpoint: ApiEndpoints.getSpacesUrl,
  //       param: {'page': page},
  //       method: RequestType.get,
  //       transformer: (data) => (ApiBasePaginatedModel<SpaceModel>.fromJson(
  //         data as Map<String, dynamic>,
  //         dataParser: (e) => SpaceModel.fromJson(e as Map<String, dynamic>),
  //       )),
  //     );
  //   }

  //   Future<BaseResponse<ApiBaseMessageModel>> sendInvite({
  //     required int spaceId,
  //     required String email,
  //   }) {
  //     return request(
  //       endpoint: ApiEndpoints.sendSpaceInviteUrl(spaceId),
  //       param: {
  //         'email': email,
  //       },
  //       method: RequestType.post,
  //       transformer: (data) => ApiBaseMessageModel.fromJson(data as Map<String, dynamic>),
  //     );
  //   }

  //   Future<BaseResponse<ApiBasePaginatedModel<SpaceInvitationModel>>> getInvitations(int page) {
  //     return request(
  //       endpoint: ApiEndpoints.getInvitationsUrl,
  //       param: {'page': page},
  //       method: RequestType.get,
  //       transformer: (data) => (ApiBasePaginatedModel<SpaceInvitationModel>.fromJson(
  //         data as Map<String, dynamic>,
  //         dataParser: (e) => SpaceInvitationModel.fromJson(e as Map<String, dynamic>),
  //       )),
  //     );
  //   }

  //   Future<BaseResponse<ApiBasePaginatedModel<UserModel>>> searchProfile({
  //     String? query,
  //     String? userType,
  //   }) {
  //     return request(
  //       endpoint: ApiEndpoints.searchUsersUrl,
  //       param: {
  //         if (query != null) 'query': query,
  //         if (userType != null) 'user_type': userType,
  //       },
  //       method: RequestType.get,
  //       transformer: (data) => (ApiBasePaginatedModel<UserModel>.fromJson(
  //         data as Map<String, dynamic>,
  //         dataParser: (e) => UserModel.fromJson(e as Map<String, dynamic>),
  //       )),
  //     );
  //   }

  //   Future<BaseResponse<ApiBaseMessageModel>> replyInvite({
  //     required int inviteId,
  //     required bool accept,
  //   }) {
  //     return request(
  //       endpoint: ApiEndpoints.sendSpaceInviteUrl(inviteId),
  //       param: {
  //         'status': accept ? 'accepted' : 'rejected',
  //       },
  //       method: RequestType.post,
  //       transformer: (data) => ApiBaseMessageModel.fromJson(data as Map<String, dynamic>),
  //     );
  //   }

  //   // Get space messages
  //   Future<BaseResponse<ApiBasePaginatedModel<SpaceMessageModel>>> getSpaceMessages({
  //     required int page,
  //     required int spaceId,
  //   }) {
  //     return request(
  //       endpoint: ApiEndpoints.getSpaceMessagesUrl(spaceId),
  //       param: {'page': page},
  //       method: RequestType.get,
  //       transformer: (data) => (ApiBasePaginatedModel<SpaceMessageModel>.fromJson(
  //         data as Map<String, dynamic>,
  //         dataParser: (e) => SpaceMessageModel.fromJson(e as Map<String, dynamic>),
  //       )),
  //     );
  //   }

  //   // Get space users
  //   Future<BaseResponse<SpaceDetailModel>> getSpaceDetail({
  //     required int page,
  //     required int spaceId,
  //   }) {
  //     return request(
  //       endpoint: ApiEndpoints.getSpaceDetailUrl(spaceId),
  //       param: {'page': page},
  //       method: RequestType.get,
  //       transformer: (data) => SpaceDetailModel.fromJson(data['data'] as Map<String, dynamic>),
  //     );
  //   }

  //   // Delete space
  //   Future<BaseResponse<ApiBaseMessageModel>> deleteSpace(int spaceId) {
  //     return request(
  //       endpoint: ApiEndpoints.deleteSpaceUrl(spaceId),
  //       method: RequestType.delete,
  //       transformer: (data) => ApiBaseMessageModel.fromJson(data as Map<String, dynamic>),
  //     );
  //   }

  //   // Send space message
  //   Future<BaseResponse<ApiBaseMessageModel>> sendSpaceMessage({
  //     required int spaceId,
  //     required String contentType,
  //     String? message,
  //     File? content,
  //   }) {
  //     Map<String, dynamic> formData = {
  //       'content_type': contentType,
  //     };

  //     if (message != null) {
  //       formData['message'] = message;
  //     }

  //     if (content != null) {
  //       formData['content'] = MultipartFile.fromFileSync(
  //         content.path,
  //         filename: content.path.split('/').last,
  //       );
  //     }

  //     return request(
  //       data: FormData.fromMap(formData),
  //       endpoint: ApiEndpoints.sendSpaceMessageUrl(spaceId),
  //       method: RequestType.post,
  //       transformer: (data) => ApiBaseMessageModel.fromJson(data as Map<String, dynamic>),
  //     );
  //   }

  // //----------------------------Chat----------------------------//
  //   Future<BaseResponse<ApiBasePaginatedModel<ChatModel>>> getChats(int page) {
  //     return request(
  //       endpoint: ApiEndpoints.getAndCreateChatUrl,
  //       param: {'page': page},
  //       method: RequestType.get,
  //       transformer: (data) => (ApiBasePaginatedModel<ChatModel>.fromJson(
  //         data as Map<String, dynamic>,
  //         dataParser: (e) => ChatModel.fromJson(e as Map<String, dynamic>),
  //       )),
  //     );
  //   }

  //   Future<BaseResponse<ChatModel>> createChat({required int otherUserId}) async {
  //     return request(
  //       endpoint: ApiEndpoints.getAndCreateChatUrl,
  //       method: RequestType.post,
  //       data: {
  //         'other_user_id': '$otherUserId',
  //       },
  //       transformer: (data) => ChatModel.fromJson(data['chat'] as Map<String, dynamic>),
  //     );
  //   }

  //   Future<BaseResponse<ApiBaseMessageModel>> createZoomMeeting(
  //       {required String token, required String topic}) async {
  //     return request(
  //       endpoint: ApiEndpoints.createZoomMeetingUrl,
  //       method: RequestType.post,
  //       data: {
  //         'token': token,
  //         'topic': topic,
  //       },
  //       transformer: (data) => ApiBaseMessageModel.fromJson(data as Map<String, dynamic>),
  //     );
  //   }

  //   Future<BaseResponse<ApiBasePaginatedModel<ChatMessageModel>>> getChatMessages({
  //     required int page,
  //     required int chatId,
  //   }) {
  //     return request(
  //       endpoint: ApiEndpoints.getChatMessagesUrl(chatId),
  //       param: {'page': page},
  //       method: RequestType.get,
  //       transformer: (data) => (ApiBasePaginatedModel<ChatMessageModel>.fromJson(
  //         data as Map<String, dynamic>,
  //         dataParser: (e) => ChatMessageModel.fromJson(e as Map<String, dynamic>),
  //       )),
  //     );
  //   }

  //   Future<BaseResponse<ApiBaseMessageModel>> sendChatMessage({
  //     required int chatId,
  //     required String contentType,
  //     String? message,
  //     File? content,
  //   }) {
  //     Map<String, dynamic> formData = {
  //       'content_type': contentType,
  //     };

  //     if (message != null) {
  //       formData['text'] = message;
  //     }

  //     if (content != null) {
  //       formData['content'] = MultipartFile.fromFileSync(
  //         content.path,
  //         filename: content.path.split('/').last,
  //       );
  //     }

  //     return request(
  //       data: FormData.fromMap(formData),
  //       endpoint: ApiEndpoints.sendChatMessageUrl(chatId),
  //       method: RequestType.post,
  //       transformer: (data) => ApiBaseMessageModel.fromJson(data as Map<String, dynamic>),
  //     );
  //   }

  //   // Profile
  //   Future<BaseResponse<ApiBaseMessageModel>> updateProfile({
  //     final File? avatar,
  //     required final String name,
  //     required final String email,
  //     required final String phone,
  //     required final String headline,
  //     required final String userType,
  //   }) async {
  //     Map<String, dynamic> data = {
  //       'name': name,
  //       'email': email,
  //       'phone': phone,
  //       'headline': headline,
  //     };

  //     if (avatar != null) {
  //       data['avatar'] = await MultipartFile.fromFile(
  //         avatar.path,
  //         filename: avatar.path.split('/').last,
  //       );
  //     }
  //     return request(
  //       data: FormData.fromMap(data),
  //       endpoint: ApiEndpoints.updateProfileUrl(userType),
  //       method: RequestType.post,
  //       transformer: (data) => ApiBaseMessageModel.fromJson(data as Map<String, dynamic>),
  //     );
  //   }

  //   Future<BaseResponse<UserModel>> getUserProfile({required int userId}) {
  //     return request(
  //       endpoint: ApiEndpoints.getUserProfile(userId),
  //       method: RequestType.get,
  //       transformer: (data) => UserModel.fromJson(data['data'] as Map<String, dynamic>),
  //     );
  //   }

  //   Future<BaseResponse<ApiBasePaginatedModel<UserModel>>> getUserFollowers({
  //     required int page,
  //     required int userId,
  //   }) {
  //     return request(
  //       endpoint: ApiEndpoints.getUserFollowers(userId),
  //       param: {'page': page},
  //       method: RequestType.get,
  //       transformer: (data) => (ApiBasePaginatedModel<UserModel>.fromJson(
  //         data as Map<String, dynamic>,
  //         dataParser: (e) => UserModel.fromJson(e as Map<String, dynamic>),
  //       )),
  //     );
  //   }

  //   Future<BaseResponse<ApiBasePaginatedModel<UserModel>>> getUserFollowing({
  //     required int page,
  //     required int userId,
  //   }) {
  //     return request(
  //       endpoint: ApiEndpoints.getUserFollowing(userId),
  //       param: {'page': page},
  //       method: RequestType.get,
  //       transformer: (data) => (ApiBasePaginatedModel<UserModel>.fromJson(
  //         data as Map<String, dynamic>,
  //         dataParser: (e) => UserModel.fromJson(e as Map<String, dynamic>),
  //       )),
  //     );
  //   }

  //   Future<BaseResponse<ApiBaseMessageModel>> followUser({required int userId}) async {
  //     return request(
  //       endpoint: ApiEndpoints.followUser(userId),
  //       method: RequestType.post,
  //       data: {
  //         'user_id': userId,
  //       },
  //       transformer: (data) => ApiBaseMessageModel.fromJson(data as Map<String, dynamic>),
  //     );
  //   }

  //   Future<BaseResponse<ApiBaseMessageModel>> unfollowUser({required int userId}) async {
  //     return request(
  //       endpoint: ApiEndpoints.followUser(userId),
  //       method: RequestType.delete,
  //       data: {
  //         'user_id': userId,
  //       },
  //       transformer: (data) => ApiBaseMessageModel.fromJson(data as Map<String, dynamic>),
  //     );
  //   }

  //   Future<BaseResponse<ApiBaseMessageModel>> updatePassword({
  //     required final String currentPassword,
  //     required final String password,
  //   }) async {
  //     Map<String, dynamic> data = {
  //       'current_password': currentPassword,
  //       'password': password,
  //     };
  //     return request(
  //       data: FormData.fromMap(data),
  //       endpoint: ApiEndpoints.updatePasswordUrl,
  //       method: RequestType.post,
  //       transformer: (data) => ApiBaseMessageModel.fromJson(data as Map<String, dynamic>),
  //     );
  //   }

  //   // Delete user account
  //   Future<BaseResponse<ApiBaseMessageModel>> deleteUserAccount({required String currentPassword}) {
  //     return request(
  //       data: FormData.fromMap({'current_password': currentPassword}),
  //       endpoint: ApiEndpoints.deleteAccUrl,
  //       method: RequestType.post,
  //       transformer: (data) => ApiBaseMessageModel.fromJson(data as Map<String, dynamic>),
  //     );
  //   }

  //   // Forgot Password
  //   Future<BaseResponse<ApiBaseMessageModel>> forgotPasswordSendOtp({required String email}) {
  //     return request(
  //       data: {'email': email},
  //       endpoint: ApiEndpoints.forgotPasswordUrl,
  //       method: RequestType.post,
  //       transformer: (data) => ApiBaseMessageModel.fromJson(data as Map<String, dynamic>),
  //     );
  //   }

  //   Future<BaseResponse<ForgotPasswordVerifyOtpModel>> forgotPasswordVerifyOtp(
  //       {required String email, required String otp}) {
  //     return request(
  //       endpoint: ApiEndpoints.forgotPasswordVerifyOtpUrl,
  //       method: RequestType.post,
  //       data: {
  //         'email': email,
  //         'otp': otp,
  //       },
  //       transformer: (data) => ForgotPasswordVerifyOtpModel.fromJson(data as Map<String, dynamic>),
  //     );
  //   }

  //   Future<BaseResponse<ApiBaseMessageModel>> forgotPasswordResetPassword(
  //       {required String email, required String password, required String resetToken}) {
  //     return request(
  //       endpoint: ApiEndpoints.forgotPasswordResetPasswordUrl,
  //       method: RequestType.post,
  //       data: {
  //         'email': email,
  //         'password': password,
  //         'reset_token': resetToken,
  //       },
  //       transformer: (data) => ApiBaseMessageModel.fromJson(data as Map<String, dynamic>),
  //     );
  //   }

  //   // Coach Calendar
  //   Future<BaseResponse<List<CoachAvailabilityResponseModel>>> getCoachAvailability() {
  //     return request(
  //       endpoint: ApiEndpoints.coachCalendarUrl,
  //       method: RequestType.get,
  //       transformer: (data) {
  //         final List<dynamic> list = data as List<dynamic>;
  //         return list
  //             .map((item) => CoachAvailabilityResponseModel.fromJson(item as Map<String, dynamic>))
  //             .toList();
  //       },
  //     );
  //   }

  //   Future<BaseResponse<List<BookingModel>>> getCoachBookings() {
  //     return request(
  //       endpoint: ApiEndpoints.coachBookingsUrl,
  //       method: RequestType.get,
  //       transformer: (data) {
  //         final List<dynamic> list = data as List<dynamic>;
  //         return list.map((item) => BookingModel.fromJson(item as Map<String, dynamic>)).toList();
  //       },
  //     );
  //   }

  //   Future<BaseResponse<ApiBaseMessageModel>> setCoachAvailability({
  //     required String date,
  //     required List<int> hours,
  //   }) {
  //     return request(
  //       endpoint: ApiEndpoints.coachCalendarUrl,
  //       method: RequestType.post,
  //       data: {
  //         'date': date,
  //         'hours': hours,
  //       },
  //       transformer: (data) => ApiBaseMessageModel.fromJson(data as Map<String, dynamic>),
  //     );
  //   }

  //   Future<BaseResponse<ApiBaseMessageModel>> bookCoach({
  //     required int coachUserId,
  //     required String date,
  //     required int hour,
  //   }) {
  //     return request(
  //       endpoint: ApiEndpoints.bookCoachUrl,
  //       method: RequestType.post,
  //       data: {
  //         'coach_user_id': '$coachUserId',
  //         'date': date,
  //         'hour': hour,
  //       },
  //       transformer: (data) => ApiBaseMessageModel.fromJson(data as Map<String, dynamic>),
  //     );
  //   }

  //   Future<BaseResponse<ApiBaseMessageModel>> cancelCoachBooking({
  //     required int bookingId,
  //   }) {
  //     return request(
  //       endpoint: ApiEndpoints.cancelCoachBookingUrl,
  //       method: RequestType.post,
  //       data: {
  //         'booking_id': bookingId,
  //       },
  //       transformer: (data) => ApiBaseMessageModel.fromJson(data as Map<String, dynamic>),
  //     );
  //   }

  //   Future<BaseResponse<List<AthleteBookingModel>>> getAthleteBookings() {
  //     return request(
  //       endpoint: ApiEndpoints.athleteBookingsUrl,
  //       method: RequestType.get,
  //       transformer: (data) {
  //         final List<dynamic> list = data as List<dynamic>;
  //         return list
  //             .map((item) => AthleteBookingModel.fromJson(item as Map<String, dynamic>))
  //             .toList();
  //       },
  //     );
  //   }

  //   // Notifications
  //   Future<BaseResponse<ApiBasePaginatedModel<NotificationModel>>> getNotifications(
  //       {required int page}) {
  //     return request(
  //       endpoint: ApiEndpoints.notificationsUrl,
  //       param: {'page': page},
  //       method: RequestType.get,
  //       transformer: (data) {
  //         return ApiBasePaginatedModel<NotificationModel>.fromJson(
  //           data as Map<String, dynamic>,
  //           dataParser: (e) => NotificationModel.fromJson(e as Map<String, dynamic>),
  //         );
  //       },
  //     );
  //   }

  //   Future<BaseResponse<ApiBaseMessageModel>> markNotificationRead({required String notificationId}) {
  //     return request(
  //       endpoint: '${ApiEndpoints.notificationsUrl}/$notificationId/read',
  //       method: RequestType.post,
  //       transformer: (data) => ApiBaseMessageModel.fromJson(data as Map<String, dynamic>),
  //     );
  //   }

  //   // Meeting Purchase
  //   Future<BaseResponse<MeetingPurchaseModel>> purchaseMeeting({
  //     required String meetingType,
  //     required int chatId,
  //   }) {
  //     return request(
  //       endpoint: ApiEndpoints.meetingPurchaseUrl,
  //       method: RequestType.post,
  //       data: {
  //         'meeting_type': meetingType,
  //         'chat_id': chatId,
  //       },
  //       transformer: (data) => MeetingPurchaseModel.fromJson(data as Map<String, dynamic>),
  //     );
  //   }
}
