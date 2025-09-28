// lib/models/book.dart CORREGIDO
import 'dart:math';

class Book {
  final String id;
  final String title;
  final String author;
  final String? description;
  final String? coverUrl;
  final int? publishYear;
  final double? rating;
  final String category;
  final int? totalChapters;
  final int currentChapter;
  final bool completed;
  final DateTime startDate;

  Book({
    required this.id,
    required this.title,
    required this.author,
    this.description,
    this.coverUrl,
    this.publishYear,
    this.rating,
    required this.category,
    this.totalChapters,
    this.currentChapter = 0,
    this.completed = false,
    required this.startDate,
  });

  factory Book.fromOpenLibrary(Map<String, dynamic> json) {
    return Book(
      id: json['key']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Sin título',
      author: _extractFirstAuthor(json['author_name']),
      description: json['first_sentence']?.join(' '),
      coverUrl: json['cover_i'] != null
          ? 'https://covers.openlibrary.org/b/id/${json['cover_i']}-M.jpg'
          : null,
      publishYear: json['first_publish_year'],
      rating: _generateRandomRating(),
      category: _extractCategory(json['subject']),
      totalChapters: _generateChapterCount(),
      startDate: DateTime.now(),
    );
  }

  factory Book.fromFirestore(Map<String, dynamic> json, String documentId) {
    return Book(
      id: documentId,
      title: json['title'] ?? '',
      author: json['author'] ?? '',
      totalChapters: json['totalChapters'] ?? 0,
      currentChapter: json['currentChapter'] ?? 0,
      completed: json['completed'] ?? false,
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'])
          : DateTime.now(),
      category: json['category'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'author': author,
      'totalChapters': totalChapters,
      'currentChapter': currentChapter,
      'completed': completed,
      'startDate': startDate.toIso8601String(),
    };
  }

  static String _extractFirstAuthor(dynamic authorName) {
    if (authorName == null) return 'Autor desconocido';
    if (authorName is List && authorName.isNotEmpty) {
      return authorName.first.toString();
    }
    return authorName.toString();
  }

  static double _generateRandomRating() {
    final random = Random();
    return 3.5 + (random.nextDouble() * 1.5); // Rating entre 3.5 y 5.0
  }

  static String _extractCategory(dynamic subjects) {
    if (subjects == null) return 'General';
    if (subjects is List && subjects.isNotEmpty) {
      final subject = subjects.first.toString().toLowerCase();
      if (subject.contains('history')) return 'Historia';
      if (subject.contains('science')) return 'Ciencia';
      if (subject.contains('fiction')) return 'Ficción';
      if (subject.contains('philosophy')) return 'Filosofía';
      return 'General';
    }
    return 'General';
  }

  static int _generateChapterCount() {
    final random = Random();
    return 10 + random.nextInt(11); // Entre 10 y 20 capítulos
  }
}
