import 'package:autograde_mobile/core/api/models/api_base_message_model.dart';

class EvalAnswerModel extends ApiBaseMessageModel {
  EvalAnswerModel({super.message, required this.eval});

  EvalAnswerModel.fromJson(Map<String, dynamic> json)
    : this(
        message: ApiBaseMessageModel.fromJson(json).message,
        eval: json['evaluation'] as String,
      );

  @override
  Map<String, dynamic> toJson() => {'message': message, 'evaluation': eval};

  final String eval;
}
