import 'package:autograde_mobile/core/api/models/deserializable.dart';
import 'package:autograde_mobile/core/api/models/serializable.dart';

// This model is used for all messages param in API responses
class ApiBaseMessageModel implements Deserializable, Serializable {
  ApiBaseMessageModel({required this.message});

  ApiBaseMessageModel.fromJson(Map<String, dynamic> json)
      : this(message: json['message'] as String?);

  @override
  Map<String, dynamic> toJson() => {'message': message};

  final String? message;
}
