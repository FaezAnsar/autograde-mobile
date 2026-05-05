import 'package:autograde_mobile/core/api/api_exception.dart';
import 'package:autograde_mobile/core/api/models/api_base_message_model.dart';
import 'package:autograde_mobile/core/data_source/auth_remote_data_source.dart';
import 'package:autograde_mobile/core/models/login_model.dart';
import 'package:fpdart/fpdart.dart';

class AuthRepository {
  AuthRepository(this.authRemoteDataSource);

  final AuthRemoteDataSource authRemoteDataSource;

  Future<Either<ApiException, LogInModel>> signup({
    required String username,
    required String email,
    required String password,
  }) {
    return authRemoteDataSource.signup(
      username: username,
      email: email,
      password: password,
    );
  }

  Future<Either<ApiException, LogInModel>> login({
    required String username,
    required String password,
  }) {
    return authRemoteDataSource.login(
      username: username,
      password: password,
    );
  }

  Future<Either<ApiException, ApiBaseMessageModel>> logout({
    required String token,
  }) {
    return authRemoteDataSource.logout(token: token);
  }
}
