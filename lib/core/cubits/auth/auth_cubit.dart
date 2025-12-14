import 'package:autograde_mobile/core/cubits/auth/auth_states.dart';
import 'package:autograde_mobile/core/data_source/storage_local_data_source.dart';
import 'package:autograde_mobile/core/models/user_model.dart';
import 'package:autograde_mobile/core/utils/user_type.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this.localStorageClient) : super(AuthInitial());

  StorageLocalDataSource localStorageClient;

  void initialize() {
    String? token = getCurrentToken();
    final usertype = localStorageClient.userRole.get();
    final user = localStorageClient.user.get();
    if (token != null && usertype != null && user != null) {
      authorizeUser(token: token, userType: usertype, user: user);
    } else {
      unAuthorizeUser();
    }
  }

  void authorizeUser({
    required String token,
    required UserType userType,
    required UserModel user,
  }) {
    localStorageClient.userToken.save(token);
    localStorageClient.userRole.save(userType);
    localStorageClient.user.save(user);
    //locator<RevenueCatService>().setUserId('${user.id}');
    emit(AuthAuthorized(userType: userType, user: user));
  }

  void unAuthorizeUser() {
    localStorageClient.userToken.delete();
    localStorageClient.userRole.delete();
    localStorageClient.user.delete();
    emit(AuthUnauthorized());
  }

  String? getCurrentToken() {
    return localStorageClient.userToken.get();
  }

  UserType? getCurrentUserRole() {
    if (state is AuthAuthorized) {
      return (state as AuthAuthorized).userType;
    }
    return null;
  }

  UserModel? getCurrentUser() {
    if (state is AuthAuthorized) {
      return (state as AuthAuthorized).user;
    }
    return null;
  }

  void updateUser(UserModel updatedUser) {
    if (state is AuthAuthorized) {
      final currentState = state as AuthAuthorized;
      localStorageClient.user.save(updatedUser);
      emit(AuthAuthorized(userType: currentState.userType, user: updatedUser));
    }
  }

  void acceptTermsAndConditions() {
    localStorageClient.userAcceptance.save(true);
  }
}
