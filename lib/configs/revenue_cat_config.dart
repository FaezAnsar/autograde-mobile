// import 'dart:developer';

// import 'package:flutter/foundation.dart';
// import 'package:purchases_flutter/purchases_flutter.dart';

// class RevenueCatConfig {
//   // RevenueCat API Keys
//   static const String androidApiKey = 'goog_ZJwBpnQHjLlYQJgcghxCoOiwbCl';
//   static const String iosApiKey = 'appl_XchnXneOLykhmMhVDTSzuQBvvgy';

//   // Package Identifiers
//   static const String defaultPackage = 'default';
//   static const String meetingPackage = 'meeting';

//   // Product Identifiers
//   static const String monthlySubscription = 'pro_monthly_1:pro';

//   // Entitlement Identifiers
//   static const String premiumAccess = 'Pro';

//   /// Initialize RevenueCat with platform-specific API keys
//   static Future<void> initialize() async {
//     try {
//       if (kDebugMode) {
//         await Purchases.setLogLevel(LogLevel.debug);
//       }

//       // Configure RevenueCat with your API keys
//       PurchasesConfiguration configuration;

//       if (defaultTargetPlatform == TargetPlatform.android) {
//         configuration = PurchasesConfiguration(androidApiKey);
//       } else if (defaultTargetPlatform == TargetPlatform.iOS) {
//         configuration = PurchasesConfiguration(iosApiKey);
//       } else {
//         // For other platforms, you can use a default key or handle accordingly
//         configuration = PurchasesConfiguration(androidApiKey);
//       }

//       await Purchases.configure(configuration);

//       if (kDebugMode) {
//         print('RevenueCat initialized successfully');
//       }
//     } catch (e) {
//       if (kDebugMode) {
//         print('Failed to initialize RevenueCat: $e');
//       }
//     }
//   }

//   /// Get available packages for purchase
//   static Future<List<Offering>> getOfferings() async {
//     try {
//       final offerings = await Purchases.getOfferings();

//       return offerings.all.values.toList();
//     } catch (e) {
//       log('Failed to get offerings: $e');
//       return [];
//     }
//   }

//   /// Purchase a package
//   static Future<CustomerInfo?> purchasePackage(Package package) async {
//     try {
//       final customerInfo = await Purchases.purchasePackage(package);
//       log('Purchase successful: ${customerInfo.entitlements.all}');
//       return customerInfo;
//     } catch (e) {
//       log('Purchase failed: $e');
//       return null;
//     }
//   }

//   /// Restore purchases
//   static Future<CustomerInfo?> restorePurchases() async {
//     try {
//       final customerInfo = await Purchases.restorePurchases();
//       log('Purchases restored: ${customerInfo.entitlements.all}');
//       return customerInfo;
//     } catch (e) {
//       log('Failed to restore purchases: $e');
//       return null;
//     }
//   }

//   /// Check if user has active entitlement
//   static bool hasActiveEntitlement(CustomerInfo customerInfo, String entitlementId) {
//     return customerInfo.entitlements.active.containsKey(entitlementId);
//   }

//   /// Get current customer info
//   static Future<CustomerInfo?> getCustomerInfo() async {
//     try {
//       return await Purchases.getCustomerInfo();
//     } catch (e) {
//       log('Failed to get customer info: $e');
//       return null;
//     }
//   }

//   /// Set user ID for RevenueCat
//   static Future<void> setUserId(String userId) async {
//     try {
//       await Purchases.logIn(userId);
//       log('User ID set for RevenueCat: $userId');
//     } catch (e) {
//       log('Failed to set user ID: $e');
//     }
//   }
// }
