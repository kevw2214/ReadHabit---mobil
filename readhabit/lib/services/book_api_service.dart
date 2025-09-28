// lib/services/book_api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/book.dart';
import '../models/book_category.dart';

class BookApiService {
  static const String _baseUrl = 'https://openlibrary.org';

  // Buscar libros por término
  Future<List<Book>> searchBooks(String query, {int limit = 20}) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/search.json?q=${Uri.encodeQueryComponent(query)}&limit=$limit',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> docs = data['docs'] ?? [];

        return docs.map((doc) => Book.fromOpenLibrary(doc)).toList();
      } else {
        throw Exception('Error al buscar libros: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener libros por categoría
  Future<List<Book>> getBooksByCategory(
    BookCategory category, {
    int limit = 20,
  }) async {
    try {
      String subject = _getCategorySubject(category);
      final url = Uri.parse(
        '$_baseUrl/search.json?subject=$subject&limit=$limit&sort=rating',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> docs = data['docs'] ?? [];

        return docs.map((doc) => Book.fromOpenLibrary(doc)).toList();
      } else {
        throw Exception(
          'Error al obtener libros por categoría: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener libros populares
  Future<List<Book>> getPopularBooks({int limit = 20}) async {
    try {
      final url = Uri.parse('$_baseUrl/search.json?sort=rating&limit=$limit');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> docs = data['docs'] ?? [];

        return docs.map((doc) => Book.fromOpenLibrary(doc)).toList();
      } else {
        throw Exception(
          'Error al obtener libros populares: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
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
      default:
        return 'popular';
    }
  }
}
