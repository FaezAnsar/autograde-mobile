class NotificationHandler {
  // final _firebaseMessaging = FirebaseMessaging.instance;

  // Future<void> initNotifications(
  //     FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
  //   await _firebaseMessaging.requestPermission();

  //   FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);
  //   FirebaseMessaging.onMessage
  //       .listen((message) => handleNotification(message, flutterLocalNotificationsPlugin));
  // }

  // void _onMessageOpenedApp(RemoteMessage message) {
  //   if (message.data['click_action'] == 'FLUTTER_NOTIFICATION_CLICK') {
  //     openLaunchUrl(message.data['url']);
  //   }
  // }

  // Future<void> handleNotification(RemoteMessage message,
  //     FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
  //   log('${message.data}', name: 'NotificationHandler');

  //   final prefs = await SharedPreferences.getInstance();
  //   final currentChatId = prefs.getString("chat_id");

  //   final incomingChatId = message.data['chat_id'];
  //   final incomingSpaceId = message.data['space_id'];

  //   if (currentChatId != null &&
  //       (currentChatId == incomingChatId || currentChatId == incomingSpaceId)) {
  //     // User is already on this chat → don’t show notification
  //     log("Suppressing notification for chatId: $incomingChatId$incomingSpaceId",
  //         name: 'NotificationHandler');
  //     return;
  //   }
  //   // User is not in this chat → show notification
  //   showLocalNotification(message, flutterLocalNotificationsPlugin);
  // }
}
