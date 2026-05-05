import 'package:autograde_mobile/configs/routing/routes.dart';
import 'package:autograde_mobile/configs/service_locator.dart';
import 'package:autograde_mobile/core/api/api_exception.dart';
import 'package:autograde_mobile/core/cubits/auth/auth_cubit.dart';
import 'package:autograde_mobile/core/repositories/auth_repository.dart';
import 'package:autograde_mobile/core/utils/user_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fpdart/fpdart.dart' as fpdart;
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  late AnimationController _animationController;
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() => _isLoading = true);

    final fpdart.Either<ApiException, dynamic> result = await locator<AuthRepository>()
        .login(
      username: _usernameController.text.trim(),
      password: _passwordController.text.trim(),
    );

    if (!mounted) return;

    result.match(
      (error) {
        setState(() => _isLoading = false);
        _showError(error.message);
      },
      (loginModel) {
        if (loginModel.user == null || loginModel.token == null) {
          setState(() => _isLoading = false);
          _showError('Unexpected login response.');
          return;
        }

        locator<AuthCubit>().authorizeUser(
          token: loginModel.token!,
          user: loginModel.user!,
          userType: loginModel.user!.type ?? UserType.parent,
        );

        context.go(
          Routes.homeScreen.path,
          extra: {
            'name': loginModel.user!.name ?? loginModel.user!.email ?? 'Learner',
            'email': loginModel.user!.email ?? '',
          },
        );
      },
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFef4444),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      const Color(0xFF1a1a2e),
                      const Color(0xFF16213e),
                    ]
                  : [
                      const Color(0xFFF8FAFB),
                      const Color(0xFFEFF2F5),
                    ],
            ),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20.h),
                  // Logo/Brand section with animation
                  _buildBrandSection(),
                  SizedBox(height: 48.h),
                  // Form section
                  _buildFormSection(),
                  SizedBox(height: 32.h),
                  // Sign up link
                  _buildSignUpSection(),
                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBrandSection() {
    return FadeTransition(
      opacity: Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _animationController, curve: const Interval(0, 0.3)),
      ),
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, -20), end: Offset.zero).animate(
          CurvedAnimation(parent: _animationController, curve: const Interval(0, 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Decorative accent
            Container(
              width: 48.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: const Color(0xFF6366f1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              'Welcome back',
              style: TextStyle(
                fontSize: 36.sp,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : const Color(0xFF0f172a),
                letterSpacing: -0.5,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              'Sign in to your AutoGrade account',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w400,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormSection() {
    return FadeTransition(
      opacity: Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _animationController, curve: const Interval(0.2, 0.7)),
      ),
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 30), end: Offset.zero).animate(
          CurvedAnimation(parent: _animationController, curve: const Interval(0.2, 0.7)),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Username field
              _buildTextFormField(
                controller: _usernameController,
                label: 'Username',
                hint: 'teacher1',
                keyboardType: TextInputType.text,
                icon: Icons.person_outline_rounded,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your username';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24.h),
              // Password field
              _buildTextFormField(
                controller: _passwordController,
                label: 'Password',
                hint: 'Enter your password',
                obscureText: _obscurePassword,
                icon: Icons.lock_outline_rounded,
                suffixIcon: GestureDetector(
                  onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                  child: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: Colors.grey[500],
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              SizedBox(height: 12.h),
              // Forgot password link
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // Navigate to forgot password
                  },
                  child: Text(
                    'Forgot password?',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF6366f1),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 28.h),
              // Login button
              _buildLoginButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    IconData? icon,
    Widget? suffixIcon,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      style: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w500,
        color: isDark ? Colors.white : const Color(0xFF0f172a),
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: TextStyle(
          fontSize: 16.sp,
          color: Colors.grey[400],
        ),
        prefixIcon: icon != null
            ? Padding(
                padding: EdgeInsets.only(left: 16.w, right: 12.w),
                child: Icon(icon, color: Colors.grey[500], size: 20.sp),
              )
            : null,
        prefixIconConstraints: icon != null ? BoxConstraints(minWidth: 0, minHeight: 0) : null,
        suffixIcon: suffixIcon != null
            ? Padding(
                padding: EdgeInsets.only(right: 12.w),
                child: suffixIcon,
              )
            : null,
        suffixIconConstraints: suffixIcon != null ? BoxConstraints(minWidth: 0, minHeight: 0) : null,
        filled: true,
        fillColor: isDark
            ? const Color(0xFF2a2a3e).withOpacity(0.7)
            : Colors.white.withOpacity(0.6),
        contentPadding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(
            color: Colors.grey[300] ?? Colors.grey,
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(
            color: isDark
                ? Colors.grey[700]!
                : Colors.grey[300]!,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(
            color: Color(0xFF6366f1),
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(
            color: Color(0xFFef4444),
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(
            color: Color(0xFFef4444),
            width: 2,
          ),
        ),
        labelStyle: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          color: Colors.grey[600],
        ),
        errorStyle: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
          color: const Color(0xFFef4444),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366f1).withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _login,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6366f1),
          disabledBackgroundColor: const Color(0xFF6366f1).withOpacity(0.6),
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
        child: SizedBox(
          width: double.infinity,
          child: Center(
            child: _isLoading
                ? SizedBox(
                    height: 20.h,
                    width: 20.h,
                    child: const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    'Sign In',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignUpSection() {
    return FadeTransition(
      opacity: Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _animationController, curve: const Interval(0.5, 1.0)),
      ),
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF2a2a3e).withOpacity(0.5)
              : Colors.white.withOpacity(0.4),
          border: Border.all(
            color: Colors.grey[300] ?? Colors.grey,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Don't have an account? ",
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            TextButton(
              onPressed: () => context.go(Routes.signUpScreen.path),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Create Account',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF6366f1),
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}