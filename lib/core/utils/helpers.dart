import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

bool isType<T, Y>() => T == Y;

void displayToastMessage(String text, {Toast toastLength = Toast.LENGTH_LONG}) {
  Fluttertoast.showToast(
    msg: text,
    gravity: ToastGravity.BOTTOM,
    timeInSecForIosWeb: 2,
    backgroundColor: Colors.black87,
    textColor: Colors.white,
    webShowClose: true,
    toastLength: toastLength,
  );
}

Future<void> openLaunchUrl(String url) async {
  if (await canLaunchUrl(Uri.parse(url))) {
    await launchUrl(Uri.parse(url));
  } else {
    throw 'Could not launch $url';
  }
}

String getImageExtension(File imageFile) {
  String filePath = imageFile.path;
  String extension = filePath.substring(filePath.lastIndexOf('.'));
  return extension; // e.g., '.jpg', '.png'
}

void showSnackBar(
  BuildContext context,
  String message, {
  SnackBarAction? action,
}) {
  ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(message), action: action));
}

String timeAgo(DateTime dateTime) {
  final now = DateTime.now();
  final difference = now.difference(dateTime);

  if (difference.inSeconds < 60) {
    return 'just now';
  } else if (difference.inMinutes < 60) {
    return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ';
  } else if (difference.inHours < 24) {
    return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ';
  } else if (difference.inDays < 7) {
    return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ';
  } else if (difference.inDays < 30) {
    final weeks = (difference.inDays / 7).floor();
    return '$weeks week${weeks > 1 ? 's' : ''} ';
  } else if (difference.inDays < 365) {
    final months = (difference.inDays / 30).floor();
    return '$months month${months > 1 ? 's' : ''} ';
  } else {
    final years = (difference.inDays / 365).floor();
    return '$years year${years > 1 ? 's' : ''} ';
  }
}

Future<File> urlToFile(String imageUrl) async {
  try {
    // Download the image from the URL
    final response = await http.get(Uri.parse(imageUrl));

    if (response.statusCode == 200) {
      // Get the temporary directory
      final directory = await getTemporaryDirectory();

      // Create a file path with a unique name
      final filePath =
          '${directory.path}/image_${DateTime.now().millisecondsSinceEpoch}.png';

      // Write the image bytes to the file
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      return file;
    } else {
      throw Exception('Failed to download image: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error converting URL to file: $e');
  }
}

// Future<File?> compressImage(XFile imageFile) async {
//   try {
//     final dir = await getTemporaryDirectory();
//     final targetPath = path.join(
//       dir.absolute.path,
//       '${DateTime.now().millisecondsSinceEpoch}_compressed.jpg',
//     );

//     final compressedFile = await FlutterImageCompress.compressAndGetFile(
//       imageFile.path,
//       targetPath,
//       quality: 65,
//       minWidth: 1024,
//       minHeight: 1024,
//       format: CompressFormat.jpeg,
//     );

//     return compressedFile != null ? File(compressedFile.path) : null;
//   } catch (e) {
//     // If compression fails, return original file
//     return File(imageFile.path);
//   }
//}

// void showLocalNotification(
//   RemoteMessage message,
//   FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
// ) async {
//   const androidPlatformChannelSpecifics = AndroidNotificationDetails(
//     'chat_channel',
//     'Chat Messages',
//     channelDescription: 'Notifications for chat messages',
//     importance: Importance.high,
//     priority: Priority.high,
//   );

//   const platformChannelSpecifics = NotificationDetails(
//     android: androidPlatformChannelSpecifics,
//   );

  // int notificationId = DateTime.now().millisecondsSinceEpoch.remainder(100000);

  // await flutterLocalNotificationsPlugin.show(
  //   notificationId,
  //   message.notification?.title ?? "New Message",
  //   message.notification?.body ?? "",
  //   platformChannelSpecifics,
  //   payload: message.data['chatId'],
  // );
//}
