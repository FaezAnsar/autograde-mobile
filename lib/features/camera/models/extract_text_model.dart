import 'package:autograde_mobile/core/api/models/api_base_message_model.dart';

class EvalAnswerModel extends ApiBaseMessageModel {
  EvalAnswerModel({super.message, this.eval});

  EvalAnswerModel.fromJson(Map<String, dynamic> json)
    : this(
        message: ApiBaseMessageModel.fromJson(json).message,
        eval: _extractEvaluation(json),
      );

  static String? _extractEvaluation(Map<String, dynamic> json) {
    try {
      // Try different possible response structures
      if (json.containsKey('evaluation')) {
        return json['evaluation'] as String?;
      } else if (json.containsKey('extracted_text') &&
          json['extracted_text'] is Map<String, dynamic>) {
        final extractedText = json['extracted_text'] as Map<String, dynamic>;
        return extractedText['evaluation'] as String?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Map<String, dynamic> toJson() => {'message': message, 'evaluation': eval};

  final String? eval;
}
