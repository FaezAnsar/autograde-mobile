import 'package:dio/dio.dart';

class ApiException implements Exception {
  ApiException({
    required this.url,
    required this.message,
    this.response,
    this.statusCode,
  });
  final String url;
  final String message;
  final int? statusCode;
  final Response<dynamic>? response;

  /// IMPORTANT NOTE
  /// here you can take advantage of toString() method to display the error for user
  /// lets make an example
  /// so in onError method when you make api you can just user apiExceptionInstance.toString() to get the error message from api
  @override
  String toString() {
    return message;
  }
}
