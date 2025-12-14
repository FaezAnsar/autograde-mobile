import 'package:autograde_mobile/configs/routing/routes.dart';
import 'package:autograde_mobile/configs/service_locator.dart';
import 'package:autograde_mobile/configs/theme/app_colors.dart';
import 'package:autograde_mobile/core/constants/constants.dart';
import 'package:autograde_mobile/core/cubits/auth/auth_cubit.dart';
import 'package:autograde_mobile/core/cubits/auth/auth_states.dart';
import 'package:autograde_mobile/core/utils/user_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class DrawerWidget extends StatelessWidget {
  DrawerWidget({super.key});
  final AuthCubit _authCubit = locator();

  @override
  Widget build(BuildContext context) {
    final AuthCubit authCubit = locator();
    final UserType? userType = authCubit.getCurrentUserRole();
    return Drawer(
      backgroundColor: AppColors.darkColor,
      child: ListView(
        children: [
          SizedBox(height: 10.0.h),
          BlocBuilder<AuthCubit, AuthState>(
            bloc: _authCubit,
            builder: (context, state) {
              final user = state is AuthAuthorized
                  ? state.user
                  : authCubit.getCurrentUser();
              // Add null safety check
              if (user == null) {
                return const SizedBox.shrink(); // or return a loading/placeholder widget
              }

              return ListTile(
                onTap: () {
                  context.pop();
                  context.push(Routes.myProfileScreen.path, extra: user);
                },
                leading: CircleAvatar(
                  radius: 22.0,
                  backgroundColor: Theme.of(context).primaryColor,
                  child: CircleAvatar(
                    radius: 22.0,
                    backgroundImage: user.avatarUrl == null
                        ? const AssetImage(noImageAvailableImagePath)
                        : NetworkImage(user.avatarUrl!),
                  ),
                ),
                title: Text(
                  user.name ?? "N/A",
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  user.phoneNumber ?? "N/A",
                  style: const TextStyle(color: Colors.white),
                ),
              );
            },
          ),
          SizedBox(height: 10.0.h),
          Visibility(
            visible: userType == UserType.coach,
            child: ListTile(
              leading: const Icon(Icons.create, color: Colors.white),
              title: const Text(
                'Create Post',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                context.pop();
                context.push(Routes.createPostScreen.path);
              },
            ),
          ),
          SizedBox(height: 10.0.h),
          ListTile(
            leading: const Icon(Icons.feed_rounded, color: Colors.white),
            title: const Text('Feed', style: TextStyle(color: Colors.white)),
            onTap: () {
              context.pop();
            },
          ),
          Visibility(
            visible: userType == UserType.athlete,
            child: Column(
              children: [
                SizedBox(height: 10.0.h),
                ListTile(
                  leading: const Icon(
                    Icons.calendar_month,
                    color: Colors.white,
                  ),
                  title: const Text(
                    'Bookings',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    context.pop();
                    context.push(Routes.athleteBookingsScreen.path);
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: 10.0.h),
          ListTile(
            leading: const Icon(Icons.post_add, color: Colors.white),
            title: const Text(
              'Favorites',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              context.pop();
              context.push(Routes.favoritePostsScreen.path);
            },
          ),
          SizedBox(height: 10.0.h),
          ListTile(
            leading: const Icon(
              Icons.space_dashboard_rounded,
              color: Colors.white,
            ),
            title: const Text('Spaces', style: TextStyle(color: Colors.white)),
            onTap: () {
              context.pop();
              context.push(Routes.spacesScreen.path);
            },
          ),
          SizedBox(height: 10.0.h),
          ListTile(
            leading: const Icon(Icons.person, color: Colors.white),
            title: const Text('Coaches', style: TextStyle(color: Colors.white)),
            onTap: () {
              context.pop();
              context.push(Routes.coachesScreen.path);
            },
          ),
          SizedBox(height: 10.0.h),
          ListTile(
            leading: const Icon(Icons.person, color: Colors.white),
            title: const Text(
              'Athletes',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              context.pop();
              context.push(Routes.athletesScreen.path);
            },
          ),
          SizedBox(height: 10.0.h),
          ListTile(
            leading: const Icon(Icons.people_rounded, color: Colors.white),
            title: const Text(
              'Chatrooms',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              context.pop();
              context.push(Routes.chatroomScreen.path);
            },
          ),
          // SizedBox(
          //   height: 10.0.h,
          // ),
          // ListTile(
          //   leading: Image.asset(
          //     promotionsIconPath,
          //     color: Colors.white,
          //   ),
          //   title: const Text(
          //     'Promotions',
          //     style: TextStyle(
          //       color: Colors.white,
          //     ),
          //   ),
          //   onTap: () {
          //     context.pop();
          //     context.push(Routes.promotionsScreen.path);
          //   },
          // ),
          SizedBox(height: 10.0.h),
          ListTile(
            leading: const Icon(Icons.favorite_rounded, color: Colors.white),
            title: const Text('Support', style: TextStyle(color: Colors.white)),
            onTap: () {
              final Uri emailUri = Uri(
                scheme: 'mailto',
                path: 'info@hockeysocialnetwork.com',
              );
              launchUrl(emailUri);
              context.pop();
            },
          ),
          SizedBox(height: 10.0.h),
          Visibility(
            visible: userType != UserType.coach,
            child: ListTile(
              leading: const Icon(Icons.subscriptions, color: Colors.white),
              title: const Text(
                'Subscription',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                context.pop();
                context.push(Routes.subscriptionScreen.path);
              },
            ),
          ),
          SizedBox(height: 10.0.h),
          // BlocListener<AuthCubit, AuthState>(
          //   listener: (context, state) {
          //     if (state is AuthUnauthorized) {
          //       context.go(Routes.landingScreen.path);
          //     }
          //     // else if (state is AuthAuthorized) {
          //     //   context.go(Routes.main.path);
          //     // }
          //   },
          //   child: BlocProvider<LogoutCubit>(
          //     create: (context) => LogoutCubit(),
          //     child: BlocConsumer<LogoutCubit, ApiState<ApiBaseMessageModel>>(
          //       listener: (context, state) {
          //         if (state is ApiLoadedState) {
          //           _authCubit.unAuthorizeUser();
          //         }
          //       },
          //       builder: (context, state) {
          //         return GestureDetector(
          //           onTap: state is ApiLoadingState
          //               ? null
          //               : () {
          //                   context.showConfirmationDialog(
          //                     title: 'Log out',
          //                     content: 'Are you sure you want to log out?',
          //                     onPressed: () {
          //                       context.pop();
          //                       context.read<LogoutCubit>().logout();
          //                     },
          //                   );
          //                 },
          //           child:
          //               // ListTile(
          //               //   leading: Icon(Icons.logout),
          //               //   title: const Text(
          //               //     'LogOut',
          //               //     style: TextStyle(color: AppColors.lightColor),
          //               //   ),
          //               // ),
          //               ProfileOptionTile(
          //             icon: Icons.logout,
          //             title: 'Logout',
          //             isLoading: state is ApiLoadingState,
          //           ),
          //         );
          //       },
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}

class ProfileOptionTile extends StatelessWidget {
  const ProfileOptionTile({
    super.key,
    required this.icon,
    required this.title,
    this.trailing,
    this.isLoading = false,
  });

  final IconData icon;
  final String title;
  final Widget? trailing;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: isLoading
            ? SizedBox(
                width: 20.0.w,
                height: 20.0.h,
                child: CircularProgressIndicator(
                  color: Theme.of(context).primaryColor,
                  strokeWidth: 2.0.w,
                  strokeCap: StrokeCap.round,
                ),
              )
            : (trailing ?? const Icon(Icons.arrow_forward_ios, size: 16.0)),
      ),
    );
  }
}
