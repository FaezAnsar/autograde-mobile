// import 'dart:developer';

// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:autograde_mobile/core/utils/helpers.dart';

// // Future handleBackgroundMessage(RemoteMessage message) async {
// //   log('Message: ${message.data}');
// // }

// class NotificationService {
//   final _firebaseMessaging = FirebaseMessaging.instance;

//   Future initNotifications() async {
//     await _firebaseMessaging.requestPermission();
//     final token = await _firebaseMessaging.getToken();
//     FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);
//     log('Token: $token', name: 'Notification Service');
//   }

//   void _onMessageOpenedApp(RemoteMessage message) {
//     if (message.data['click_action'] == 'FLUTTER_NOTIFICATION_CLICK') {
//       openLaunchUrl(message.data['url']);
//     }
//   }
// }
