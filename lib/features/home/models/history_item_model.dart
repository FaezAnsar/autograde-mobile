class HistoryItemModel {
  HistoryItemModel({
    required this.paperId,
    required this.paperCode,
    required this.paperNumber,
    required this.questionId,
    required this.evaluationText,
    required this.createdAt,
  });

  factory HistoryItemModel.fromJson(Map<String, dynamic> json) {
    return HistoryItemModel(
      paperId: json['paper_id'] as String? ?? '',
      paperCode: json['paper_code'] as String? ?? '',
      paperNumber: json['paper_number'] as String? ?? '',
      questionId: json['question_id'] as String? ?? '',
      evaluationText: json['evaluation_text'] as String? ?? '',
      createdAt: json['created_at'] as String? ?? '',
    );
  }

  final String paperId;
  final String paperCode;
  final String paperNumber;
  final String questionId;
  final String evaluationText;
  final String createdAt;
}
