// lib/models/reading_statistics.dart
import 'package:readhabit/models/user_book.dart';

class ReadingStatistics {
  final int booksInProgress;
  final int booksCompleted;
  final int totalBooks;
  final double averageProgress;
  final int totalChaptersRead;
  final int currentStreak;
  final int longestStreak;

  ReadingStatistics({
    required this.booksInProgress,
    required this.booksCompleted,
    required this.totalBooks,
    required this.averageProgress,
    required this.totalChaptersRead,
    required this.currentStreak,
    required this.longestStreak,
  });

  factory ReadingStatistics.fromUserBooks(List<UserBook> userBooks) {
    final inProgress = userBooks
        .where((b) => b.status == BookStatus.inProgress)
        .length;
    final completed = userBooks
        .where((b) => b.status == BookStatus.completed)
        .length;
    final totalChapters = userBooks.fold<int>(
      0,
      (sum, book) => sum + book.currentChapter,
    );

    double avgProgress = 0;
    if (userBooks.isNotEmpty) {
      avgProgress =
          userBooks
              .map((book) => book.progressPercentage)
              .reduce((a, b) => a + b) /
          userBooks.length;
    }

    return ReadingStatistics(
      booksInProgress: inProgress,
      booksCompleted: completed,
      totalBooks: userBooks.length,
      averageProgress: avgProgress,
      totalChaptersRead: totalChapters,
      currentStreak: 0, // Se calculará desde otra fuente
      longestStreak: 0, // Se calculará desde otra fuente
    );
  }
}
