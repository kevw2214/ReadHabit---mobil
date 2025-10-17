import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/book.dart';
import '../models/book_category.dart';

class GoogleBooksService {
  static const String _baseUrl = 'https://www.googleapis.com/books/v1';

  Future<List<Book>> searchBooks(String query, {int limit = 20}) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/volumes?q=${Uri.encodeQueryComponent(query)}&maxResults=$limit&printType=books',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> items = data['items'] ?? [];

        return items.map((item) => Book.fromGoogleBooks(item)).toList();
      } else {
        throw Exception('Error al buscar libros: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<List<Book>> getBooksByCategory(
    BookCategory category, {
    int limit = 20,
  }) async {
    try {
      String subject = _getCategorySubject(category);
      final url = Uri.parse(
        '$_baseUrl/volumes?q=subject:$subject&maxResults=$limit&printType=books&orderBy=relevance',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> items = data['items'] ?? [];

        return items.map((item) => Book.fromGoogleBooks(item)).toList();
      } else {
        throw Exception(
          'Error al obtener libros por categoría: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<List<Book>> getPopularBooks({int limit = 20}) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/volumes?q=subject:fiction&maxResults=$limit&printType=books&orderBy=newest',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> items = data['items'] ?? [];

        return items.map((item) => Book.fromGoogleBooks(item)).toList();
      } else {
        throw Exception(
          'Error al obtener libros populares: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<Book?> getBookDetails(String bookId) async {
    try {
      final url = Uri.parse('$_baseUrl/volumes/$bookId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Book.fromGoogleBooks(data);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  String _getCategorySubject(BookCategory category) {
    switch (category) {
      case BookCategory.ficcion:
        return 'fiction';
      case BookCategory.ciencia:
        return 'science';
      case BookCategory.historia:
        return 'history';
      case BookCategory.filosofia:
        return 'philosophy';
      case BookCategory.biografia:
        return 'biography';
      case BookCategory.arte:
        return 'art';
      case BookCategory.religion:
        return 'religion';
      case BookCategory.populares:
        return 'bestsellers';
    }
  }
}
