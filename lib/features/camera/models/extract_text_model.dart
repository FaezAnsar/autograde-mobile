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
      if (json['results'] is List) {
        final results = json['results'] as List;
        if (results.isNotEmpty && results.first is Map<String, dynamic>) {
          final firstResult = results.first as Map<String, dynamic>;
          final extractedText = firstResult['extracted_text'];
          if (extractedText is Map<String, dynamic>) {
            return extractedText['evaluation'] as String?;
          }
          if (extractedText is String) {
            return extractedText;
          }
        }
      }

      if (json['extracted_text'] is Map<String, dynamic>) {
        final extractedText = json['extracted_text'] as Map<String, dynamic>;
        return extractedText['evaluation'] as String?;
      }

      if (json['evaluation'] is String) {
        return json['evaluation'] as String;
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
