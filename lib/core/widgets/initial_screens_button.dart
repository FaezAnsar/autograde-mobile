import 'package:flutter/material.dart';
import 'package:autograde_mobile/configs/theme/app_colors.dart';
import 'package:autograde_mobile/core/constants/constants.dart';
import 'package:autograde_mobile/core/widgets/loading_widget.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final double? width;
  final double? height;
  final VoidCallback? onPressed;
  final bool isLoading;
  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.height,
    this.width,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.buttonColor,
          foregroundColor: AppColors.lightColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.0),
          ),
        ),
        child: (isLoading)
            ? const LoadingWidget()
            : Text(
                text,
                style: textStyle14.copyWith(fontWeight: FontWeight.w400),
              ),
      ),
    );
  }
}
