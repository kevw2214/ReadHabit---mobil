// lib/providers/book_provider.dart
import 'package:flutter/material.dart';
import '../models/book.dart';
import '../models/book_category.dart';
import '../services/book_api_service.dart'; // Ahora el archivo existe

class BookProvider with ChangeNotifier {
  final GoogleBooksService _apiService = GoogleBooksService(); // Ahora la clase existe

  List<Book> _catalogBooks = [];
  List<Book> _searchResults = [];
  bool _isLoading = false;
  String? _errorMessage;
  BookCategory _selectedCategory = BookCategory.populares;
  String _searchQuery = '';

  // Getters
  List<Book> get catalogBooks => _catalogBooks;
  List<Book> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  BookCategory get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;

  // Cargar libros del catálogo por categoría
  Future<void> loadBooksByCategory(BookCategory category) async {
    _isLoading = true;
    _errorMessage = null;
    _selectedCategory = category;
    notifyListeners();

    try {
      if (category == BookCategory.populares) {
        _catalogBooks = await _apiService.getPopularBooks();
      } else {
        _catalogBooks = await _apiService.getBooksByCategory(category);
      }
    } catch (e) {
      _errorMessage = 'Error al cargar libros: $e';
      _catalogBooks = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Buscar libros
  Future<void> searchBooks(String query) async {
    if (query.trim().isEmpty) {
      _searchResults = [];
      _searchQuery = '';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    _searchQuery = query;
    notifyListeners();

    try {
      _searchResults = await _apiService.searchBooks(query);
    } catch (e) {
      _errorMessage = 'Error en la búsqueda: $e';
      _searchResults = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Limpiar resultados de búsqueda
  void clearSearch() {
    _searchResults = [];
    _searchQuery = '';
    notifyListeners();
  }

  // Limpiar errores
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Cambiar categoría
  void setCategory(BookCategory category) {
    if (_selectedCategory != category) {
      loadBooksByCategory(category);
    }
  }

  // Obtener detalles específicos de un libro
  Future<Book?> getBookDetails(String bookId) async {
    try {
      // Buscar en libros ya cargados primero
      final existingBook = _catalogBooks.firstWhere(
        (book) => book.id == bookId,
        orElse: () => _searchResults.firstWhere(
          (book) => book.id == bookId,
          orElse: () => Book(
            id: '',
            title: '',
            author: '',
            category: '',
            startDate: DateTime.now(),
          ),
        ),
      );
      
      if (existingBook.id.isNotEmpty) {
        return existingBook;
      }
      
      // Si no está en cache, buscar en la API
      return await _apiService.getBookDetails(bookId);
    } catch (e) {
      return null;
    }
  }

  // Inicializar con libros populares al empezar
  Future<void> initialize() async {
    await loadBooksByCategory(BookCategory.populares);
  }
}