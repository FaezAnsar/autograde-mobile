import 'package:autograde_mobile/core/api/models/api_base_message_model.dart';

class EvalQuestionModel {
  EvalQuestionModel({
    this.questionId,
    this.questionText,
    this.answerText,
    this.score,
    this.comments,
  });

  factory EvalQuestionModel.fromJson(Map<String, dynamic> json) {
    return EvalQuestionModel(
      questionId: json['question_id'] as String?,
      questionText: json['question_text'] as String?,
      answerText: json['answer_text'] as String?,
      score: json['score'] as String?,
      comments: json['comments'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'question_id': questionId,
        'question_text': questionText,
        'answer_text': answerText,
        'score': score,
        'comments': comments,
      };

  final String? questionId;
  final String? questionText;
  final String? answerText;
  final String? score;
  final String? comments;
}

class EvalAnswerModel extends ApiBaseMessageModel {
  EvalAnswerModel({
    super.message,
    this.eval,
    this.questionId,
    this.questionText,
    this.answerText,
    this.score,
    this.comments,
    this.questions = const [],
  });

  EvalAnswerModel.fromJson(Map<String, dynamic> json)
      : this(
          message: ApiBaseMessageModel.fromJson(json).message,
          eval: _extractEvalString(json),
          questionId: _extractQuestionId(json),
          questionText: _extractQuestionText(json),
          answerText: _extractAnswerText(json),
          score: _extractScore(json),
          comments: _extractComments(json),
          questions: _extractQuestions(json),
        );

  static List<Map<String, dynamic>> _extractEvaluations(Map<String, dynamic> json) {
    final evaluations = <Map<String, dynamic>>[];

    if (json['results'] is List) {
      final results = json['results'] as List;
      for (final result in results) {
        if (result is Map<String, dynamic> && result['evaluation'] is Map<String, dynamic>) {
          evaluations.add(result['evaluation'] as Map<String, dynamic>);
        }
      }
    }

    if (evaluations.isEmpty && json['evaluation'] is Map<String, dynamic>) {
      evaluations.add(json['evaluation'] as Map<String, dynamic>);
    }

    return evaluations;
  }

  static List<EvalQuestionModel> _extractQuestions(Map<String, dynamic> json) {
    final evaluations = _extractEvaluations(json);
    final questions = <EvalQuestionModel>[];

    for (final evaluation in evaluations) {
      if (evaluation['questions'] is List) {
        final questionList = evaluation['questions'] as List;
        questions.addAll(
          questionList
              .whereType<Map<String, dynamic>>()
              .map(EvalQuestionModel.fromJson),
        );
      }
    }

    return questions;
  }

  static Map<String, dynamic>? _extractFirstQuestion(Map<String, dynamic> json) {
    final evaluations = _extractEvaluations(json);
    for (final evaluation in evaluations) {
      if (evaluation['questions'] is List) {
        final questions = evaluation['questions'] as List;
        if (questions.isNotEmpty && questions.first is Map<String, dynamic>) {
          return questions.first as Map<String, dynamic>;
        }
      }
    }
    return null;
  }

  static String? _extractEvalString(Map<String, dynamic> json) {
    final question = _extractFirstQuestion(json);
    if (question != null && question['comments'] is String) {
      return question['comments'] as String;
    }

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
  }

  static String? _extractQuestionId(Map<String, dynamic> json) {
    final question = _extractFirstQuestion(json);
    return question?['question_id'] as String?;
  }

  static String? _extractQuestionText(Map<String, dynamic> json) {
    final question = _extractFirstQuestion(json);
    return question?['question_text'] as String?;
  }

  static String? _extractAnswerText(Map<String, dynamic> json) {
    final question = _extractFirstQuestion(json);
    return question?['answer_text'] as String?;
  }

  static String? _extractScore(Map<String, dynamic> json) {
    final question = _extractFirstQuestion(json);
    return question?['score'] as String?;
  }

  static String? _extractComments(Map<String, dynamic> json) {
    final question = _extractFirstQuestion(json);
    return question?['comments'] as String?;
  }

  @override
  Map<String, dynamic> toJson() => {
        'message': message,
        'evaluation': eval,
        'question_id': questionId,
        'question_text': questionText,
        'answer_text': answerText,
        'score': score,
        'comments': comments,
        'questions': questions.map((item) => item.toJson()).toList(),
      };

  final String? eval;
  final String? questionId;
  final String? questionText;
  final String? answerText;
  final String? score;
  final String? comments;
  final List<EvalQuestionModel> questions;
}
