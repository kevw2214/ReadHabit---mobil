class Question {
  final String id;
  final String bookId;
  final int chapter;
  final String questionText;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final String difficulty;
  final DateTime createdAt;

  Question({
    required this.id,
    required this.bookId,
    required this.chapter,
    required this.questionText,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    this.difficulty = 'medium',
    required this.createdAt,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      bookId: json['bookId'],
      chapter: json['chapter'],
      questionText: json['questionText'],
      options: List<String>.from(json['options']),
      correctIndex: json['correctIndex'],
      explanation: json['explanation'],
      difficulty: json['difficulty'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookId': bookId,
      'chapter': chapter,
      'questionText': questionText,
      'options': options,
      'correctIndex': correctIndex,
      'explanation': explanation,
      'difficulty': difficulty,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  bool validateAnswer(int selectedIndex) {
    return selectedIndex == correctIndex;
  }
}
