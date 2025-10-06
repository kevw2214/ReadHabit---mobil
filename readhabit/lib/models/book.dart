// lib/models/book.dart
import 'dart:math'; // ✅ Agregar esta importación

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
  final int? pageCount;

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
    this.pageCount,
  });

  // Constructor desde Google Books API
  factory Book.fromGoogleBooks(Map<String, dynamic> json) {
    final volumeInfo = json['volumeInfo'] ?? {};
    
    // Extraer autor
    String author = 'Autor desconocido';
    if (volumeInfo['authors'] != null) {
      if (volumeInfo['authors'] is List && volumeInfo['authors'].isNotEmpty) {
        author = volumeInfo['authors'].join(', ');
      }
    }
    
    // Extraer portada
    String? coverUrl;
    final imageLinks = volumeInfo['imageLinks'];
    if (imageLinks != null) {
      coverUrl = imageLinks['thumbnail']?.replaceAll('http:', 'https:') ??
                imageLinks['smallThumbnail']?.replaceAll('http:', 'https:');
    }
    
    // Extraer año de publicación
    int? publishYear;
    if (volumeInfo['publishedDate'] != null) {
      try {
        final dateString = volumeInfo['publishedDate'];
        if (dateString.length >= 4) {
          publishYear = int.tryParse(dateString.substring(0, 4));
        }
      } catch (e) {
        publishYear = null;
      }
    }
    
    // Extraer categoría
    String category = 'General';
    if (volumeInfo['categories'] != null && volumeInfo['categories'].isNotEmpty) {
      final firstCategory = volumeInfo['categories'][0].toString().toLowerCase();
      category = _mapCategory(firstCategory);
    }
    
    // Calcular capítulos estimados basados en páginas
    int? totalChapters;
    final pageCount = volumeInfo['pageCount'];
    if (pageCount != null) {
      totalChapters = _estimateChaptersFromPages(pageCount);
    }

    return Book(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: volumeInfo['title'] ?? 'Sin título',
      author: author,
      description: _cleanDescription(volumeInfo['description']),
      coverUrl: coverUrl,
      publishYear: publishYear,
      rating: volumeInfo['averageRating']?.toDouble() ?? _generateRandomRating(),
      category: category,
      totalChapters: totalChapters ?? _generateChapterCount(),
      pageCount: pageCount,
      startDate: DateTime.now(),
    );
  }

  // Mantener tu constructor original de Open Library
  factory Book.fromOpenLibrary(Map<String, dynamic> json) {
    return Book(
      id: json['key']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
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

  // Mantener tu constructor de Firestore
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
      description: json['description'],
      coverUrl: json['coverUrl'],
      publishYear: json['publishYear'],
      rating: json['rating']?.toDouble(),
      pageCount: json['pageCount'],
    );
  }

  // Método toFirestore actualizado
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'author': author,
      'description': description,
      'coverUrl': coverUrl,
      'publishYear': publishYear,
      'rating': rating,
      'category': category,
      'totalChapters': totalChapters,
      'currentChapter': currentChapter,
      'completed': completed,
      'startDate': startDate.toIso8601String(),
      'pageCount': pageCount,
    };
  }

  // Métodos auxiliares - HACERLOS STATIC
  static String _extractFirstAuthor(dynamic authorName) {
    if (authorName == null) return 'Autor desconocido';
    if (authorName is List && authorName.isNotEmpty) {
      return authorName.first.toString();
    }
    return authorName.toString();
  }

  static double _generateRandomRating() {
    final random = Random(); // ✅ Ahora funciona con la importación
    return 3.5 + (random.nextDouble() * 1.5);
  }

  static String _extractCategory(dynamic subjects) {
    if (subjects == null) return 'General';
    if (subjects is List && subjects.isNotEmpty) {
      final subject = subjects.first.toString().toLowerCase();
      return _mapCategory(subject);
    }
    return 'General';
  }

  static String _mapCategory(String subject) {
    if (subject.contains('history') || subject.contains('historia')) return 'Historia';
    if (subject.contains('science') || subject.contains('ciencia')) return 'Ciencia';
    if (subject.contains('fiction') || subject.contains('ficción')) return 'Ficción';
    if (subject.contains('philosophy') || subject.contains('filosofía')) return 'Filosofía';
    if (subject.contains('biography') || subject.contains('biografía')) return 'Biografía';
    if (subject.contains('art') || subject.contains('arte')) return 'Arte';
    if (subject.contains('religion') || subject.contains('religión')) return 'Religión';
    return 'General';
  }

  static int _generateChapterCount() {
    final random = Random(); // ✅ Ahora funciona
    return 10 + random.nextInt(11); // ✅ Retorna int, no double
  }

  static int _estimateChaptersFromPages(int pageCount) {
    // Estimación: aproximadamente 1 capítulo cada 10 páginas
    final estimatedChapters = (pageCount / 10).ceil();
    return estimatedChapters.clamp(5, 50); // Mínimo 5, máximo 50 capítulos
  }

  static String? _cleanDescription(String? description) {
    if (description == null) return null;
    
    return description
        .replaceAll(RegExp(r'<[^>]*>'), '') // Remove HTML tags
        .replaceAll('&#39;', "'")
        .replaceAll('&quot;', '"')
        .replaceAll('&amp;', '&')
        .trim();
  }

  // Getters útiles
  double get progress {
    if (totalChapters == null || totalChapters == 0) return 0.0;
    return (currentChapter / totalChapters!).clamp(0.0, 1.0);
  }

  bool get isReading => currentChapter > 0 && !completed;
  bool get isCompleted => completed;
  bool get isNew => currentChapter == 0;
}