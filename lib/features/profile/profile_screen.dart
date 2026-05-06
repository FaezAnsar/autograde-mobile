import 'package:autograde_mobile/configs/routing/routes.dart';
import 'package:autograde_mobile/configs/service_locator.dart';
import 'package:autograde_mobile/core/cubits/auth/auth_cubit.dart';
import 'package:autograde_mobile/core/cubits/auth/auth_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = locator<AuthCubit>().state;
    final user = authState is AuthAuthorized ? authState.user : null;
    final role = authState is AuthAuthorized ? authState.userType.name.toUpperCase() : 'GUEST';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        elevation: 0,
        backgroundColor: const Color(0xFFF8F7F5),
        foregroundColor: const Color(0xFF1A1A1A),
      ),
      backgroundColor: const Color(0xFFF8F7F5),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 28.h, horizontal: 20.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 18,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40.r,
                      backgroundColor: const Color(0xFF1A1A1A),
                      child: Text(
                        user != null && user.name != null && user.name!.isNotEmpty
                            ? user.name![0].toUpperCase()
                            : 'A',
                        style: TextStyle(color: Colors.white, fontSize: 32.sp, fontWeight: FontWeight.w700),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      user?.name ?? 'Learner',
                      style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w700),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      user?.email ?? 'No email available',
                      style: TextStyle(fontSize: 14.sp, color: const Color(0xFF667085)),
                    ),
                    SizedBox(height: 14.h),
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 16.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFEFF4),
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      child: Text(
                        role,
                        style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: const Color(0xFF334155)),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 28.h),
              Text(
                'Account Details',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 14.h),
              _buildDetailTile('Name', user?.name ?? 'Learner'),
              _buildDetailTile('Email', user?.email ?? 'Not provided'),
              _buildDetailTile('Role', role),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  locator<AuthCubit>().unAuthorizeUser();
                  context.go(Routes.signInScreen.path);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A1A1A),
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                ),
                child: Text(
                  'Logout',
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailTile(String label, String value) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 14.sp, color: const Color(0xFF475569), fontWeight: FontWeight.w600),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
