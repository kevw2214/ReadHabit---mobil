// lib/models/reading_session.dart
import 'question_result.dart'; // ✅ Importación correcta

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
  final String sessionType;
  final int correctAnswers;
  final int totalQuestions;

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
    this.sessionType = 'normal',
    this.correctAnswers = 0,
    this.totalQuestions = 0,
  });

  // Constructor para sesiones con preguntas
  factory ReadingSession.withQuestions({
    required String id,
    required String userId,
    required String bookId,
    required int chaptersRead,
    required int pagesRead,
    required int timeSpent,
    required DateTime sessionDate,
    required List<QuestionResult> questionResults,
    required double comprehensionScore,
  }) {
    final correctAnswers = questionResults.where((r) => r.isCorrect).length;
    
    return ReadingSession(
      id: id,
      userId: userId,
      bookId: bookId,
      chaptersRead: chaptersRead,
      pagesRead: pagesRead,
      timeSpent: timeSpent,
      sessionDate: sessionDate,
      questionResults: questionResults,
      comprehensionScore: comprehensionScore,
      sessionType: 'with_questions',
      correctAnswers: correctAnswers,
      totalQuestions: questionResults.length,
    );
  }

  // Constructor para sesiones normales (sin preguntas)
  factory ReadingSession.normal({
    required String id,
    required String userId,
    required String bookId,
    required int chaptersRead,
    required int pagesRead,
    required int timeSpent,
    required DateTime sessionDate,
  }) {
    return ReadingSession(
      id: id,
      userId: userId,
      bookId: bookId,
      chaptersRead: chaptersRead,
      pagesRead: pagesRead,
      timeSpent: timeSpent,
      sessionDate: sessionDate,
      questionResults: [],
      comprehensionScore: 0.0,
      sessionType: 'normal',
      correctAnswers: 0,
      totalQuestions: 0,
    );
  }

  factory ReadingSession.fromFirestore(Map<String, dynamic> json, String documentId) {
    // Parsear questionResults
    final List<QuestionResult> questionResults = [];
    if (json['questionResults'] != null) {
      questionResults.addAll(
        (json['questionResults'] as List).map((resultJson) =>
          QuestionResult.fromJson(resultJson)
        ).toList()
      );
    }

    return ReadingSession(
      id: documentId,
      userId: json['userId'] ?? '',
      bookId: json['bookId'] ?? '',
      chaptersRead: json['chaptersRead'] ?? 0,
      pagesRead: json['pagesRead'] ?? 0,
      timeSpent: json['timeSpent'] ?? 0,
      sessionDate: DateTime.parse(json['sessionDate']),
      questionResults: questionResults,
      comprehensionScore: (json['comprehensionScore'] ?? 0).toDouble(),
      sessionType: json['sessionType'] ?? 'normal',
      correctAnswers: json['correctAnswers'] ?? 0,
      totalQuestions: json['totalQuestions'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'bookId': bookId,
      'chaptersRead': chaptersRead,
      'pagesRead': pagesRead,
      'timeSpent': timeSpent,
      'sessionDate': sessionDate.toIso8601String(),
      'questionResults': questionResults.map((result) => result.toJson()).toList(),
      'comprehensionScore': comprehensionScore,
      'sessionType': sessionType,
      'correctAnswers': correctAnswers,
      'totalQuestions': totalQuestions,
    };
  }

  // Getters útiles
  bool get hasQuestions => sessionType == 'with_questions';
  bool get isPerfectScore => comprehensionScore == 100.0;
  double get averageTimePerQuestion {
    if (questionResults.isEmpty) return 0.0;
    final totalTime = questionResults.map((r) => r.timeSpent).reduce((a, b) => a + b);
    return totalTime / questionResults.length;
  }
}