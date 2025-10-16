// lib/models/user_book.dart - ACTUALIZADO
import 'package:readhabit/models/book.dart';

enum BookStatus { inProgress, completed, abandoned }

class UserBook {
  final String id;
  final String userId;
  final String bookId;
  final Book book;
  final BookStatus status;
  final int currentChapter;
  final int totalChapters;
  final DateTime startDate;
  final DateTime? completedDate;
  final DateTime lastReadDate;
  final int readingPlan; // capítulos por día
  final double comprehensionScore; // ✅ Nuevo: Score de comprensión
  final int totalQuestionsAnswered; // ✅ Nuevo: Preguntas respondidas
  final int correctAnswers; // ✅ Nuevo: Respuestas correctas

  UserBook({
    required this.id,
    required this.userId,
    required this.bookId,
    required this.book,
    required this.status,
    this.currentChapter = 0,
    required this.totalChapters,
    required this.startDate,
    this.completedDate,
    required this.lastReadDate,
    this.readingPlan = 1,
    this.comprehensionScore = 0.0, //Inicializado
    this.totalQuestionsAnswered = 0, //Inicializado
    this.correctAnswers = 0, //Inicializado
  });

  factory UserBook.fromFirestore(Map<String, dynamic> json, String documentId) {
    return UserBook(
      id: documentId,
      userId: json['userId'] ?? '',
      bookId: json['bookId'] ?? '',
      book: Book.fromFirestore(json['book'] ?? {}, json['bookId'] ?? ''),
      status: BookStatus.values.firstWhere(
        (s) => s.toString() == json['status'],
        orElse: () => BookStatus.inProgress,
      ),
      currentChapter: json['currentChapter'] ?? 0,
      totalChapters: json['totalChapters'] ?? 15,
      startDate: DateTime.parse(json['startDate']),
      completedDate: json['completedDate'] != null
          ? DateTime.parse(json['completedDate'])
          : null,
      lastReadDate: DateTime.parse(json['lastReadDate']),
      readingPlan: json['readingPlan'] ?? 1,
      comprehensionScore: (json['comprehensionScore'] ?? 0).toDouble(), //Nuevo
      totalQuestionsAnswered: json['totalQuestionsAnswered'] ?? 0, //Nuevo
      correctAnswers: json['correctAnswers'] ?? 0, //Nuevo
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'bookId': bookId,
      'book': book.toFirestore(),
      'status': status.toString(),
      'currentChapter': currentChapter,
      'totalChapters': totalChapters,
      'startDate': startDate.toIso8601String(),
      'completedDate': completedDate?.toIso8601String(),
      'lastReadDate': lastReadDate.toIso8601String(),
      'readingPlan': readingPlan,
      'comprehensionScore': comprehensionScore, //Nuevo
      'totalQuestionsAnswered': totalQuestionsAnswered, // Nuevo
      'correctAnswers': correctAnswers, // Nuevo
    };
  }

  UserBook copyWith({
    BookStatus? status,
    int? currentChapter,
    DateTime? completedDate,
    DateTime? lastReadDate,
    int? readingPlan,
    double? comprehensionScore, //Nuevo
    int? totalQuestionsAnswered, // Nuevo
    int? correctAnswers, //Nuevo
  }) {
    return UserBook(
      id: id,
      userId: userId,
      bookId: bookId,
      book: book,
      status: status ?? this.status,
      currentChapter: currentChapter ?? this.currentChapter,
      totalChapters: totalChapters,
      startDate: startDate,
      completedDate: completedDate ?? this.completedDate,
      lastReadDate: lastReadDate ?? this.lastReadDate,
      readingPlan: readingPlan ?? this.readingPlan,
      comprehensionScore: comprehensionScore ?? this.comprehensionScore, // ✅ Nuevo
      totalQuestionsAnswered: totalQuestionsAnswered ?? this.totalQuestionsAnswered, // ✅ Nuevo
      correctAnswers: correctAnswers ?? this.correctAnswers, // ✅ Nuevo
    );
  }

  // ✅ NUEVO: Método para actualizar stats de comprensión
  UserBook updateComprehensionStats(int newCorrectAnswers, int newTotalQuestions) {
    final updatedCorrectAnswers = correctAnswers + newCorrectAnswers;
    final updatedTotalQuestions = totalQuestionsAnswered + newTotalQuestions;
    final updatedScore = updatedTotalQuestions > 0 
        ? (updatedCorrectAnswers / updatedTotalQuestions) * 100 
        : 0.0;

    return copyWith(
      comprehensionScore: updatedScore,
      totalQuestionsAnswered: updatedTotalQuestions,
      correctAnswers: updatedCorrectAnswers,
    );
  }

  // Cálculos útiles
  double get progressPercentage =>
      totalChapters > 0 ? (currentChapter / totalChapters * 100) : 0;

  int get remainingChapters => totalChapters - currentChapter;

  int get daysReading => DateTime.now().difference(startDate).inDays + 1;

  int get weeksReading => (daysReading / 7).ceil();

  int get estimatedDaysToFinish {
    if (readingPlan <= 0 || remainingChapters <= 0) return 0;
    return (remainingChapters / readingPlan).ceil();
  }

  String get statusText {
    switch (status) {
      case BookStatus.inProgress:
        return 'En progreso';
      case BookStatus.completed:
        return 'Completado';
      case BookStatus.abandoned:
        return 'Abandonado';
    }
  }

  // NUEVO: Getter para nivel de comprensión
  String get comprehensionLevel {
    if (comprehensionScore >= 90) return 'Excelente';
    if (comprehensionScore >= 70) return 'Bueno';
    if (comprehensionScore >= 50) return 'Regular';
    return 'Necesita mejorar';
  }
}