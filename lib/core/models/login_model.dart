import 'package:autograde_mobile/core/api/models/api_base_message_model.dart';
import 'package:autograde_mobile/core/models/user_model.dart';

class LogInModel extends ApiBaseMessageModel {
  LogInModel({
    super.message,
    this.user,
    this.token,
  });

  LogInModel.fromJson(Map<String, dynamic> json)
      : this(
          message: ApiBaseMessageModel.fromJson(json).message,
          user: json['user'] == null
              ? null
              : UserModel.fromJson(json['user'] as Map<String, dynamic>),
          token: json['token'] as String?,
        );

  @override
  Map<String, dynamic> toJson() => {
        'message': message,
        'user': user,
        'token': token,
      };

  final UserModel? user;
  final String? token;
}
