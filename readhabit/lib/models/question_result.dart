class QuestionResult {
  final String questionId;
  final int selectedAnswer;
  final bool isCorrect;
  final int timeSpent; // segundos
  final DateTime answeredAt;

  QuestionResult({
    required this.questionId,
    required this.selectedAnswer,
    required this.isCorrect,
    required this.timeSpent,
    DateTime? answeredAt,
  }) : answeredAt = answeredAt ?? DateTime.now();

  factory QuestionResult.fromJson(Map<String, dynamic> json) {
    return QuestionResult(
      questionId: json['questionId'] ?? '',
      selectedAnswer: json['selectedAnswer'] ?? -1,
      isCorrect: json['isCorrect'] ?? false,
      timeSpent: json['timeSpent'] ?? 0,
      answeredAt: json['answeredAt'] != null
          ? DateTime.parse(json['answeredAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'selectedAnswer': selectedAnswer,
      'isCorrect': isCorrect,
      'timeSpent': timeSpent,
      'answeredAt': answeredAt.toIso8601String(),
    };
  }

  QuestionResult copyWith({
    String? questionId,
    int? selectedAnswer,
    bool? isCorrect,
    int? timeSpent,
    DateTime? answeredAt,
  }) {
    return QuestionResult(
      questionId: questionId ?? this.questionId,
      selectedAnswer: selectedAnswer ?? this.selectedAnswer,
      isCorrect: isCorrect ?? this.isCorrect,
      timeSpent: timeSpent ?? this.timeSpent,
      answeredAt: answeredAt ?? this.answeredAt,
    );
  }
}
