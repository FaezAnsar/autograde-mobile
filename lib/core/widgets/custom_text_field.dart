import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:autograde_mobile/configs/theme/app_colors.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? hint;
  final bool isPassword;
  final TextInputType keyboardType;
  final TextAlign textAlign;
  final int? maxLength;
  final TextStyle? textStyle;
  final TextStyle? hintStyle;
  final List<TextInputFormatter>? inputFormatters;
  final Function(String)? onChanged;
  final bool readOnly;
  final Function(String)? onSubmitted;
  final Function()? onTap;

  const CustomTextField(
      {super.key,
      this.controller,
      this.focusNode,
      this.hint,
      this.hintStyle,
      this.readOnly = false,
      this.isPassword = false,
      this.keyboardType = TextInputType.text,
      this.textAlign = TextAlign.start,
      this.maxLength,
      this.textStyle,
      this.inputFormatters,
      this.onChanged,
      this.onSubmitted,
      this.onTap});

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onTap: widget.onTap,
      onSubmitted: widget.onSubmitted,
      readOnly: widget.readOnly,
      controller: widget.controller,
      focusNode: widget.focusNode,
      obscureText: widget.isPassword ? !_isPasswordVisible : false,
      keyboardType: widget.keyboardType,
      textAlign: widget.textAlign,
      maxLength: widget.maxLength,
      style: widget.textStyle,
      inputFormatters: widget.inputFormatters,
      maxLengthEnforcement: MaxLengthEnforcement.enforced,
      decoration: InputDecoration(
        counterText: "", // Hide the default character counter
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: const BorderSide(color: AppColors.primaryColor),
        ),
        filled: true,
        fillColor: Colors.grey.shade200,
        hintText: widget.hint,

        contentPadding: EdgeInsets.symmetric(
            vertical: 12.h, horizontal: 10.w), // Prevents clipping
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              )
            : null,
        hintStyle: widget.hintStyle ?? TextStyle(color: Colors.grey[500]),
      ),
      onChanged: widget.onChanged,
    );
  }
}
