import 'dart:async';

import 'package:autograde_mobile/configs/routing/routes.dart';
import 'package:autograde_mobile/core/constants/app_assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final bool _showContent = true;

  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds:5000), () {
      if (!mounted) return;
      context.go(Routes.signInScreen.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F5),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF8F7F5), Color(0xFFFFFFFF)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 900),
              opacity: _showContent ? 1 : 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.85, end: 1.0),
                    duration: const Duration(milliseconds: 900),
                    curve: Curves.easeOutBack,
                    builder: (context, scale, child) {
                      return Transform.scale(scale: scale, child: child);
                    },
                    child: Container(
                      width: 140.w,
                      height: 140.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 18,
                            offset: Offset(0, 12.h),
                          ),
                        ],
                      ),
                      child: Center(
                        child: ClipOval(
                          child: Image.asset(
                            AppAssets.splashImagePath,
                            width: 96.w,
                            height: 96.w,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Text(
                    'AutoGrade',
                    style: TextStyle(
                      color: const Color(0xFF1A1A1A),
                      fontSize: 34.sp,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'Instant answer checks with smart improvement tips',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xFF7C7C7C),
                      fontSize: 16.sp,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 28.h),
                  SizedBox(
                    width: 180.w,
                    child: LinearProgressIndicator(
                      color: const Color(0xFF1A1A1A),
                      backgroundColor: const Color(0xFFD9D9D9),
                    ),
                  ),
                  SizedBox(height: 22.h),
                  ElevatedButton(
                    onPressed: () => context.go(Routes.signInScreen.path),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.r),
                      ),
                      padding: EdgeInsets.symmetric(
                        vertical: 14.h,
                        horizontal: 36.w,
                      ),
                    ),
                    child: Text(
                      'Enter Autograde',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
