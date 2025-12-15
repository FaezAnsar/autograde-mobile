import 'package:autograde_mobile/configs/routing/routes.dart';
import 'package:autograde_mobile/core/constants/app_assets.dart';
import 'package:autograde_mobile/core/cubits/auth/auth_cubit.dart';
import 'package:autograde_mobile/core/cubits/auth/auth_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Future.delayed(const Duration(seconds: 2), () {
        //locator<AuthCubit>().initialize();
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        // if (state is AuthUnauthorized) {
        //   context.go(Routes.landingScreen.path);
        // } else if (state is AuthAuthorized) {
        //   // final StorageLocalDataSource localStorageClient = locator();
        //   // final userAcceptance = localStorageClient.userAcceptance.get();
        //   // if (userAcceptance == false) {
        //   //   context.go(Routes.signUpFinishScreen.path);
        //   // } else {}
        //   context.go(Routes.dashboardScreen.path);
        // }
        context.go(Routes.dashboardScreen.path);
      },
      child: Scaffold(
        body: Center(child: Image.asset(AppAssets.splashImagePath)),
      ),
    );
  }
}
