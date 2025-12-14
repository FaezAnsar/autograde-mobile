import 'dart:convert';

import 'package:autograde_mobile/core/models/user_model.dart';
import 'package:autograde_mobile/core/utils/sharedpreference_handler.dart';
import 'package:autograde_mobile/core/utils/user_type.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageLocalDataSource {
  StorageLocalDataSource(this.sharedPreferences);

  final SharedPreferences sharedPreferences;

  SharedPreferenceHandler<String?> get userToken => SharedPreferenceHandler<String?>(
        sharedPreferences: sharedPreferences,
        key: 'user_token',
        defaultValue: null,
      );

  SharedPreferenceHandler<UserModel?> get user => SharedPreferenceHandler<UserModel?>(
        sharedPreferences: sharedPreferences,
        key: 'user',
        defaultValue: null,
        serializer: (user) => jsonEncode(user?.toJson()),
        deserializer: (json) {
          if (json != null) {
            final userData = jsonDecode(json);
            if (userData is Map<String, dynamic>) {
              return UserModel.fromJson(userData);
            }
          }
          return null;
        },
      );

  SharedPreferenceHandler<UserType?> get userRole => SharedPreferenceHandler<UserType?>(
        sharedPreferences: sharedPreferences,
        key: 'user_role',
        defaultValue: null,
        serializer: (userRole) => userRole?.name,
        deserializer: (name) =>
            name == null ? null : UserType.values.firstWhere((e) => e.name == name),
      );

  SharedPreferenceHandler<bool> get userAcceptance => SharedPreferenceHandler<bool>(
        sharedPreferences: sharedPreferences,
        key: 'user_acceptance',
        defaultValue: false,
      );

  SharedPreferenceHandler<String?> get chatId => SharedPreferenceHandler<String?>(
        sharedPreferences: sharedPreferences,
        key: 'chat_id',
        defaultValue: null,
      );
}
