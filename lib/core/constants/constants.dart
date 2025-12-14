import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

//------------------------------App Info------------------------------//
const String appName = 'Hockey Social Network';
const String appDevVersion = 'v1.0';
const String packageName = 'com.hockeysocialnetwork.app';
const String appEmail = 'info@hockeysocialnetwork.com';
const String privacyPolicy = 'https://www.termsfeed.com/live/0afa81c0-8031-4237-b58f-a644c21cd83d';
const String termsOfUse = 'https://www.example.com/terms-of-use';

//------------------------------APIs------------------------------//
const String baseUrl = 'https://hockey-connect.restncode.net';
final baseWebSocketUri = Uri(
  scheme: 'wss',
  host: 'ws-hockey-connect.restncode.net',
  port: 443,
);
const String webSocketKey = 'vs0xp3hskbtwkkv8lp8y';

//------------------------------Durations------------------------------//
const Duration apiTimeoutDuration = Duration(seconds: 10);

//------------------------------Icons------------------------------//
const String baseIconPath = 'assets/icons/';
const String logoIconPath = '${baseIconPath}logo.png';
const String googleIconPath = '${baseIconPath}google.png';
const String filterIconPath = '${baseIconPath}filter.png';
const String feedIconPath = '${baseIconPath}feed.png';
const String spacesIconPath = '${baseIconPath}spaces.png';
const String chatroomIconPath = '${baseIconPath}chatroom.png';
const String promotionsIconPath = '${baseIconPath}promotions.png';
const String supportIconPath = '${baseIconPath}support.png';

//------------------------------Images------------------------------//
const String baseImagePath = 'assets/images/';
const String noImageAvailableImagePath = '${baseImagePath}no_img_available.jpg';
const String placeHolderImagePath = '${baseImagePath}placeholder_loading.gif';
const String postCoverImagePath = '${baseImagePath}post_cover.png';
const String postCover2ImagePath = '${baseImagePath}post_cover2.png';
const String dummyProfilePic1ImagePath = '${baseImagePath}dummy_profile_pic1.jpeg';
const String dummyProfilePic2ImagePath = '${baseImagePath}dummy_profile_pic2.jpeg';
const String dummyProfilePic3ImagePath = '${baseImagePath}dummy_profile_pic3.jpeg';
const String dummyProfilePic4ImagePath = '${baseImagePath}dummy_profile_pic4.jpeg';

//------------------------------Padding and margin sizes------------------------------//
const double marginOrPaddingXs4 = 4.0;
const double marginOrPaddingSm8 = 8.0;
const double marginOrPaddingMd16 = 16.0;
const double marginOrPaddingLg24 = 24.0;
const double marginOrPaddingXl32 = 32.0;

//------------------------------Text styles------------------------------//
TextStyle textStyle10 = TextStyle(
  fontSize: 10.0.sp,
  fontWeight: FontWeight.bold,
);

TextStyle textStyle12 = TextStyle(
  fontSize: 12.0.sp,
  fontWeight: FontWeight.bold,
);

TextStyle textStyle14 = TextStyle(
  fontSize: 14.0.sp,
  fontWeight: FontWeight.bold,
);

TextStyle textStyle16 = TextStyle(
  fontSize: 16.0.sp,
  fontWeight: FontWeight.bold,
);

TextStyle textStyle18 = TextStyle(
  fontSize: 18.0.sp,
  fontWeight: FontWeight.bold,
);

TextStyle textStyle20 = TextStyle(
  fontSize: 20.0.sp,
  fontWeight: FontWeight.bold,
);

//------------------------------Border radius------------------------------//
const double borderRadiusMd8 = 6.0;

//------------------------------Sharedpreference keys------------------------------//
const String userSharedPreferenceKey = 'user';
