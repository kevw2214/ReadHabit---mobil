// lib/models/reading_session.dart
class ReadingSession {
  final String id;
  final String userId;
  final String bookId;
  final int chaptersRead;
  final int pagesRead;
  final int timeSpent; // minutos
  final DateTime sessionDate;
  final List<QuestionResult> questionResults;
  final double comprehensionScore;

  ReadingSession({
    required this.id,
    required this.userId,
    required this.bookId,
    required this.chaptersRead,
    required this.pagesRead,
    required this.timeSpent,
    required this.sessionDate,
    required this.questionResults,
    required this.comprehensionScore,
  });
}

class QuestionResult {
  final String questionId;
  final int selectedAnswer;
  final bool isCorrect;
  final int timeSpent; // segundos

  QuestionResult({
    required this.questionId,
    required this.selectedAnswer,
    required this.isCorrect,
    required this.timeSpent,
  });
}