import 'package:autograde_mobile/configs/routing/routes.dart';
import 'package:autograde_mobile/configs/service_locator.dart';
import 'package:autograde_mobile/core/cubits/auth/auth_cubit.dart';
import 'package:autograde_mobile/core/cubits/auth/auth_states.dart';
import 'package:autograde_mobile/core/data_source/app_remote_data_source.dart';
import 'package:autograde_mobile/features/home/models/history_item_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _evaluatedCount = 0;
  bool _isHistoryLoading = true;
  String? _historyError;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isHistoryLoading = true;
      _historyError = null;
    });

    final response = await locator<AppRemoteDataSource>().getHistory();
    if (!mounted) return;

    response.fold(
      (error) {
        setState(() {
          _historyError = error.message;
          _evaluatedCount = 0;
          _isHistoryLoading = false;
        });
      },
      (items) {
        final completedCount = items.where((item) => item.evaluationText.trim().isNotEmpty).length;
        setState(() {
          _evaluatedCount = completedCount;
          _isHistoryLoading = false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = locator<AuthCubit>().state;
    final user = authState is AuthAuthorized ? authState.user : null;
    final contactInfo = user?.phoneNumber != null && user!.phoneNumber!.isNotEmpty
        ? user.phoneNumber!
        : 'No phone available';

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
              Expanded(
                child: SingleChildScrollView(
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
                      _buildDetailTile('Subscriptions', 'No active subscriptions'),
                      _buildDetailTile(
                        'Total Evaluated',
                        _isHistoryLoading
                            ? 'Loading...'
                            : _historyError != null
                                ? 'N/A'
                                : '$_evaluatedCount',
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16.h),
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
