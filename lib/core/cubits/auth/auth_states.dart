import 'package:autograde_mobile/core/models/user_model.dart';
import 'package:autograde_mobile/core/utils/user_type.dart';

abstract class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {}

class AuthAuthorized extends AuthState {
  const AuthAuthorized({required this.userType, required this.user});

  final UserType userType;
  final UserModel user;
}

class AuthUnauthorized extends AuthState {}

class AuthError extends AuthState {
  const AuthError(this.message);

  final String message;
}
