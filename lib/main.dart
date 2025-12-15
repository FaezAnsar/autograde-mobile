import 'package:autograde_mobile/configs/routing/router.dart';
import 'package:autograde_mobile/configs/service_locator.dart';
import 'package:autograde_mobile/configs/theme/app_theme.dart';
import 'package:autograde_mobile/core/constants/constants.dart' as AppInfo;
import 'package:autograde_mobile/core/cubits/auth/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await ScreenUtil.ensureScreenSize();
  // Load .env & initialize dependencies

  await initializeDependencies();

  // Disable framework-level assertions (temporary dev workaround)
  FlutterError.onError = (FlutterErrorDetails details) {
    if (details.exceptionAsString().contains('mouse_tracker.dart')) {
      // log('⚠️ Ignored Pointer Tracker Assertion');
    } else {
      FlutterError.dumpErrorToConsole(details);
    }
  };

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => locator<AuthCubit>())
          ],
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: AppInfo.appName,
          themeMode: ThemeMode.light,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          routerConfig: router,
        ),
      ),
    );
  }
}
