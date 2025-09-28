// lib/providers/book_provider.dart
import 'package:flutter/material.dart';
import '../models/book.dart';
import '../models/book_category.dart';
import '../services/book_api_service.dart';

class BookProvider with ChangeNotifier {
  final BookApiService _apiService = BookApiService();

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
      _errorMessage = e.toString();
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
      _errorMessage = e.toString();
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
}
