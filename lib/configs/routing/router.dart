import 'package:go_router/go_router.dart';

final router = GoRouter(
  //initialLocation: Routes.splashScreen.path,
  routes: [
    // GoRoute(
    //   path: Routes.splashScreen.path,
    //   builder: (context, state) => const SplashScreen(),
    // ),
    // GoRoute(
    //   path: Routes.landingScreen.path,
    //   builder: (context, state) => const LandingScreen(),
    // ),
    // GoRoute(
    //   path: Routes.signUpScreen.path,
    //   builder: (context, state) => const SignUpScreen(),
    // ),
    // GoRoute(
    //     path: Routes.signUpOtpScreen.path,
    //     builder: (context, state) {
    //       final String email = state.extra as String;
    //       return OtpScreen(email: email);
    //     }),
    // GoRoute(
    //   path: Routes.signUpFinishScreen.path,
    //   builder: (context, state) => const SignUpFinishScreen(),
    // ),
    // GoRoute(
    //   path: Routes.signInScreen.path,
    //   builder: (context, state) => const SignInScreen(),
    // ),
    // GoRoute(
    //   path: Routes.forgotPasswordScreen.path,
    //   builder: (context, state) => const ForgotPasswordScreen(),
    // ),
    // GoRoute(
    //   path: Routes.forgotPasswordOtpScreen.path,
    //   builder: (context, state) => ForgotPasswordOtpScreen(email: state.extra as String),
    // ),
    // GoRoute(
    //   path: Routes.forgotPasswordNewPasswordScreen.path,
    //   builder: (context, state) {
    //     final data = state.extra as Map<String, dynamic>;
    //     return ForgotPasswordNewPasswordScreen(
    //       email: data['email'],
    //       resetToken: data['resetToken'],
    //     );
    //   },
    // ),
    // GoRoute(
    //   path: Routes.dashboardScreen.path,
    //   builder: (context, state) => const DashboardScreen(),
    // ),
    // GoRoute(
    //   path: Routes.createPostScreen.path,
    //   builder: (context, state) => const CreatePostScreen(),
    // ),
    // GoRoute(
    //   path: Routes.updatePostScreen.path,
    //   builder: (context, state) => UpdatePostScreen(state.extra as PostModel),
    // ),
    // GoRoute(
    //   path: Routes.postDetailScreen.path,
    //   builder: (context, state) => PostDetailScreen(state.extra as PostModel),
    // ),
    // GoRoute(
    //   path: Routes.spacesScreen.path,
    //   builder: (context, state) => const SpacesScreen(),
    // ),
    // GoRoute(
    //   path: Routes.spaceMessagesScreen.path,
    //   builder: (context, state) => SpaceMessagesScreen(space: state.extra as SpaceModel),
    // ),
    // GoRoute(
    //   path: Routes.spaceInvitationsScreen.path,
    //   builder: (context, state) => const SpaceInvitationsScreen(),
    // ),
    // GoRoute(
    //   path: Routes.spaceDetailScreen.path,
    //   builder: (context, state) => SpaceDetailScreen(state.extra as SpaceModel),
    // ),
    // GoRoute(
    //   path: Routes.createNewSpaceOneScreen.path,
    //   builder: (context, state) => const CreateNewSpaceOneScreen(),
    // ),
    // GoRoute(
    //   path: Routes.createNewSpaceTwoScreen.path,
    //   builder: (context, state) => CreateNewSpaceTwoScreen(state.extra as String),
    // ),
    // GoRoute(
    //   path: Routes.createNewSpaceThreeScreen.path,
    //   builder: (context, state) => const CreateSpaceThreeScreen(),
    // ),
    // GoRoute(
    //   path: Routes.coachesScreen.path,
    //   builder: (context, state) => const CoachesScreen(),
    // ),
    // GoRoute(
    //   path: Routes.athletesScreen.path,
    //   builder: (context, state) => const AthletesScreen(),
    // ),
    // GoRoute(
    //   path: Routes.setCoachAvailabilityScreen.path,
    //   builder: (context, state) => SetCoachAvailabilityScreen(
    //     selectedDate: state.extra as Map<String, dynamic>?,
    //   ),
    // ),
    // GoRoute(
    //   path: Routes.coachAvailabilityScreen.path,
    //   builder: (context, state) => CoachAvailabilityScreen(state.extra as UserModel),
    // ),
    // GoRoute(
    //   path: Routes.calenderAndBookingScreen.path,
    //   builder: (context, state) => const CalenderAndBookingScreen(),
    // ),
    // GoRoute(
    //   path: Routes.chatroomScreen.path,
    //   builder: (context, state) => const ChatroomScreen(),
    // ),
    // GoRoute(
    //   path: Routes.chatroomDetailsScreen.path,
    //   builder: (context, state) => ChatroomDetailsScreen(
    //     chat: state.extra as ChatModel,
    //   ),
    // ),
    // GoRoute(
    //   path: Routes.promotionsScreen.path,
    //   builder: (context, state) => const PromotionsScreen(),
    // ),
    // GoRoute(
    //   path: Routes.favoritePostsScreen.path,
    //   builder: (context, state) => const FavoritePostsScreen(),
    // ),
    // GoRoute(
    //   path: Routes.reportScreen.path,
    //   builder: (context, state) {
    //     final extra = state.extra as Map<String, dynamic>;
    //     return ReportScreen(
    //       id: extra['id'] as int,
    //       type: extra['type'] as String,
    //     );
    //   },
    // ),
    // GoRoute(
    //   path: Routes.myProfileScreen.path,
    //   builder: (context, state) => MyProfileScreen(state.extra as UserModel),
    // ),
    // GoRoute(
    //   path: Routes.otherProfileScreen.path,
    //   builder: (context, state) => OtherProfileScreen(state.extra as UserModel),
    // ),
    // GoRoute(
    //   path: Routes.profileEditScreen.path,
    //   builder: (context, state) => const EditProfileScreen(),
    // ),
    // GoRoute(
    //   path: Routes.searchUserProfileScreen.path,
    //   builder: (context, state) => SearchUserProfileScreen(userType: state.extra as UserType?),
    // ),
    // GoRoute(
    //   path: Routes.subscriptionScreen.path,
    //   builder: (context, state) => SubscriptionScreen(),
    // ),
    // GoRoute(
    //   path: Routes.athleteBookingsScreen.path,
    //   builder: (context, state) => const AthleteBookingsScreen(),
    // ),
    // GoRoute(
    //   path: Routes.notificationScreen.path,
    //   builder: (context, state) => const NotificationScreen(),
    // ),
    // GoRoute(
    //   path: Routes.buyMeetingPackageScreen.path,
    //   builder: (context, state) => BuyMeetingPackageScreen(
    //     chatId: state.extra as int,
    //   ),
    // ),
    // GoRoute(
    //     path: Routes.followersFollowingScreen.path,
    //     builder: (context, state) {
    //       final data = state.extra as Map<String, dynamic>;
    //       final userId = data['user_id'] as int;
    //       final userName = data['username'] as String;
    //       final initialTabIndex = data['initial_tab_index'] as int?;

    //       return FollowersFollowingScreen(
    //         userId: userId,
    //         userName: userName,
    //         initialTabIndex: initialTabIndex ?? 0,
    //       );
    //     }),
  ],
);
