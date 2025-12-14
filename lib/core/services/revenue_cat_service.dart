// import 'dart:developer';

// import 'package:flutter/foundation.dart';
// import 'package:flutter/services.dart';
// import 'package:autograde_mobile/configs/revenue_cat_config.dart';
// import 'package:purchases_flutter/purchases_flutter.dart';
// import 'package:url_launcher/url_launcher.dart';

// class RevenueCatService {
//   static final RevenueCatService _instance = RevenueCatService._internal();
//   factory RevenueCatService() => _instance;
//   RevenueCatService._internal();

//   CustomerInfo? _customerInfo;
//   bool _isInitialized = false;

//   /// Initialize the RevenueCat service
//   Future<RevenueCatService> initialize() async {
//     if (_isInitialized) return this;

//     await RevenueCatConfig.initialize();
//     await _loadCustomerInfo();
//     _isInitialized = true;
//     return this;
//   }

//   /// Load current customer info
//   Future<void> _loadCustomerInfo() async {
//     try {
//       _customerInfo = await RevenueCatConfig.getCustomerInfo();
//     } catch (e) {
//       if (kDebugMode) {
//         print('Failed to load customer info: $e');
//       }
//     }
//   }

//   /// Get current customer info
//   CustomerInfo? get customerInfo => _customerInfo;

//   /// Check if user has premium access
//   bool get hasPremiumAccess {
//     if (_customerInfo == null) return false;
//     return RevenueCatConfig.hasActiveEntitlement(_customerInfo!, RevenueCatConfig.premiumAccess);
//   }

//   /// Get available offerings
//   Future<List<Offering>> getOfferings() async {
//     return await RevenueCatConfig.getOfferings();
//   }

//   /// Purchase a package
//   Future<bool> purchasePackage(Package package) async {
//     try {
//       final customerInfo = await RevenueCatConfig.purchasePackage(package);
//       if (customerInfo != null) {
//         _customerInfo = customerInfo;
//         return true;
//       }
//       return false;
//     } catch (e) {
//       if (kDebugMode) {
//         print('Purchase failed: $e');
//       }
//       return false;
//     }
//   }

//   /// Restore purchases
//   Future<bool> restorePurchases() async {
//     try {
//       final customerInfo = await RevenueCatConfig.restorePurchases();
//       if (customerInfo != null) {
//         _customerInfo = customerInfo;
//         return true;
//       }
//       return false;
//     } catch (e) {
//       if (kDebugMode) {
//         print('Restore failed: $e');
//       }
//       return false;
//     }
//   }

//   Future<void> cancelSubscription() async {
//     try {
//       final customerInfo = await Purchases.getCustomerInfo();
//       final managementURL = customerInfo.managementURL;
//       if (managementURL != null) {
//         await launchUrl(Uri.parse(managementURL));
//       } else {
//         throw Exception(
//             'No management URL found. Please manage your subscription from the app store.');
//       }
//     } on PlatformException catch (e) {
//       log('Error launching management URL: ${e.message}');
//       throw Exception('Failed to open subscription management: ${e.message}');
//     }
//   }

//   /// Set user ID for RevenueCat
//   Future<void> setUserId(String userId) async {
//     await RevenueCatConfig.setUserId(userId);
//     await _loadCustomerInfo();
//   }

//   /// Refresh customer info
//   Future<void> refreshCustomerInfo() async {
//     await _loadCustomerInfo();
//   }

//   /// Get subscription status as a string
//   String getSubscriptionStatus() {
//     if (_customerInfo == null) return 'No subscription';

//     if (hasPremiumAccess) return 'Premium';

//     return 'Free';
//   }

//   /// Check if user has any active subscription
//   bool get hasActiveSubscription {
//     return hasPremiumAccess;
//   }
// }
