import 'package:autograde_mobile/core/cubits/auth/auth_cubit.dart';
import 'package:autograde_mobile/core/data_source/app_remote_data_source.dart';
import 'package:autograde_mobile/core/data_source/auth_remote_data_source.dart';
import 'package:autograde_mobile/core/data_source/storage_local_data_source.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

GetIt locator = GetIt.instance;

Future<void> initializeDependencies() async {
  final sharedPreferences = await SharedPreferences.getInstance();

  // Data sources
  locator.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSource(),
  );
  locator.registerLazySingleton<AppRemoteDataSource>(
    () => AppRemoteDataSource(),
  );
  locator.registerLazySingleton<StorageLocalDataSource>(
    () => StorageLocalDataSource(sharedPreferences),
  );

  // Services
  // locator.registerSingletonAsync<RevenueCatService>(
  //   () async => await RevenueCatService().initialize(),
  // );

  // // Cubits/Blocs
  locator.registerLazySingleton<AuthCubit>(() => AuthCubit(locator()));
  // locator.registerLazySingleton<LogoutCubit>(() => LogoutCubit());

  // locator.registerLazySingleton<LocaleCubit>(
  //     () => LocaleCubit(locator<StorageLocalDataSource>()));

  // Ensure all Async and ready-able dependencies are ready
  await locator.allReady();
}
