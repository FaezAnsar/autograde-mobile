import 'package:autograde_mobile/configs/theme/app_colors.dart';
import 'package:autograde_mobile/core/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppTheme {
  static const fontName = 'Poppins';

  static final inputDecorationTheme = InputDecorationTheme(
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.r),
      borderSide: const BorderSide(color: AppColors.inputTextFieldColor),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.r),
      borderSide: const BorderSide(color: AppColors.primaryColor),
    ),
    filled: true,
    fillColor: AppColors.inputTextFieldColor,

    contentPadding: EdgeInsets.symmetric(
      vertical: 12.h,
      horizontal: 12.w,
    ), // Prevents clipping

    hintStyle: TextStyle(color: Colors.grey[500]),
  );

  static final elevatedButtonThemeData = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      backgroundColor: AppColors.primaryColor,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadiusMd8),
      ),
    ),
  );

  static final textButtonTheme = TextButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      foregroundColor: AppColors.primaryColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadiusMd8),
      ),
    ),
  );

  static const floatingActionButtonTheme = FloatingActionButtonThemeData(
    backgroundColor: AppColors.primaryColor,
    foregroundColor: Colors.white,
  );

  // Light Theme
  static final lightTheme = ThemeData(
    useMaterial3: true,
    floatingActionButtonTheme: floatingActionButtonTheme,
    primaryColor: AppColors.primaryColor,
    scaffoldBackgroundColor: AppColors.lightColor,
    brightness: Brightness.light,
    fontFamily: fontName,
    appBarTheme: AppBarTheme(
      color: AppColors.lightColor,
      surfaceTintColor: AppColors.lightColor,
      titleTextStyle: textStyle16.copyWith(
        fontWeight: FontWeight.w600,
        fontFamily: AppTheme.fontName,
        color: AppColors.darkColor,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.lightColor,
    ),
    inputDecorationTheme: inputDecorationTheme,
    elevatedButtonTheme: elevatedButtonThemeData,
    textButtonTheme: textButtonTheme,
  );

  // Dark Theme
  static final darkTheme = ThemeData(
    useMaterial3: true,
    floatingActionButtonTheme: floatingActionButtonTheme,
    primaryColor: AppColors.primaryColor,
    scaffoldBackgroundColor: AppColors.darkColor,
    brightness: Brightness.dark,
    fontFamily: fontName,
    appBarTheme: AppBarTheme(
      color: AppColors.darkColor,
      surfaceTintColor: AppColors.darkColor,
      titleTextStyle: textStyle16.copyWith(
        fontWeight: FontWeight.w600,
        fontFamily: AppTheme.fontName,
        color: AppColors.lightColor,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.darkColor,
    ),
    inputDecorationTheme: inputDecorationTheme,
    elevatedButtonTheme: elevatedButtonThemeData,
    textButtonTheme: textButtonTheme,
  );
}
