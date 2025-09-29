// lib/providers/user_library_provider.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../models/user_book.dart';
import '../models/book.dart';
import '../models/reading_statistics.dart';
import '../services/user_book_service.dart';

class UserLibraryProvider with ChangeNotifier {
  final UserBookService _userBookService = UserBookService();

  List<UserBook> _booksInProgress = [];
  List<UserBook> _completedBooks = [];
  ReadingStatistics? _statistics;
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<List<UserBook>>? _booksSubscription;

  // Getters
  List<UserBook> get booksInProgress => _booksInProgress;
  List<UserBook> get completedBooks => _completedBooks;
  ReadingStatistics? get statistics => _statistics;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Cargar biblioteca del usuario
  Future<void> loadUserLibrary(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    _deferNotifyListeners();

    try {
      await Future.wait([
        _loadBooksInProgress(userId),
        _loadCompletedBooks(userId),
        _loadStatistics(userId),
      ]);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      _deferNotifyListeners();
    }
  }

  Future<void> _loadBooksInProgress(String userId) async {
    _booksInProgress = await _userBookService.getBooksInProgress(userId);
  }

  Future<void> _loadCompletedBooks(String userId) async {
    _completedBooks = await _userBookService.getCompletedBooks(userId);
  }

  Future<void> _loadStatistics(String userId) async {
    _statistics = await _userBookService.getReadingStatistics(userId);
  }

  // Escuchar cambios en tiempo real
  void startListeningToUserBooks(String userId) {
    _booksSubscription?.cancel();
    _booksSubscription = _userBookService
        .getUserBooksStream(userId)
        .listen(
          (books) {
            _booksInProgress = books
                .where((b) => b.status == BookStatus.inProgress)
                .toList();
            _completedBooks = books
                .where((b) => b.status == BookStatus.completed)
                .toList();
            _statistics = ReadingStatistics.fromUserBooks(books);
            _deferNotifyListeners();
          },
          onError: (error) {
            _errorMessage = error.toString();
            _deferNotifyListeners();
          },
        );
  }

  // Notificar cambios de forma diferida para evitar conflictos con el build
  void _deferNotifyListeners() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  void stopListeningToUserBooks() {
    _booksSubscription?.cancel();
    _booksSubscription = null;
  }

  // Agregar libro a la biblioteca
  Future<bool> addBookToLibrary({
    required String userId,
    required Book book,
    required int readingPlan,
  }) async {
    try {
      // Verificar si el usuario ya tiene el libro
      final hasBook = await _userBookService.userHasBook(userId, book.id);
      if (hasBook) {
        _errorMessage = 'Ya tienes este libro en tu biblioteca';
        _deferNotifyListeners();
        return false;
      }

      await _userBookService.addBookToLibrary(
        userId: userId,
        book: book,
        readingPlan: readingPlan,
      );

      // Recargar biblioteca
      await loadUserLibrary(userId);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _deferNotifyListeners();
      return false;
    }
  }

  // Actualizar progreso de lectura
  Future<bool> updateReadingProgress({
    required String userBookId,
    required int newChapter,
    required String userId,
  }) async {
    try {
      await _userBookService.updateReadingProgress(
        userBookId: userBookId,
        newChapter: newChapter,
      );

      // Recargar biblioteca
      await loadUserLibrary(userId);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _deferNotifyListeners();
      return false;
    }
  }

  // Continuar leyendo (avanzar un capítulo)
  Future<bool> continueReading({
    required String userBookId,
    required int currentChapter,
    required int totalChapters,
    required String userId,
  }) async {
    final newChapter = currentChapter + 1;

    if (newChapter >= totalChapters) {
      // Marcar como completado
      return await markBookAsCompleted(userBookId: userBookId, userId: userId);
    } else {
      // Actualizar progreso
      return await updateReadingProgress(
        userBookId: userBookId,
        newChapter: newChapter,
        userId: userId,
      );
    }
  }

  // Marcar libro como completado
  Future<bool> markBookAsCompleted({
    required String userBookId,
    required String userId,
  }) async {
    try {
      await _userBookService.markBookAsCompleted(userBookId);
      await loadUserLibrary(userId);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _deferNotifyListeners();
      return false;
    }
  }

  // Abandonar libro
  Future<bool> abandonBook({
    required String userBookId,
    required String userId,
  }) async {
    try {
      await _userBookService.abandonBook(userBookId);
      await loadUserLibrary(userId);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _deferNotifyListeners();
      return false;
    }
  }

  // Eliminar libro de la biblioteca
  Future<bool> removeBookFromLibrary({
    required String userBookId,
    required String userId,
  }) async {
    try {
      await _userBookService.removeBookFromLibrary(userBookId);
      await loadUserLibrary(userId);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _deferNotifyListeners();
      return false;
    }
  }

  // Actualizar plan de lectura
  Future<bool> updateReadingPlan({
    required String userBookId,
    required int chaptersPerDay,
    required String userId,
  }) async {
    try {
      await _userBookService.updateReadingPlan(userBookId, chaptersPerDay);
      await loadUserLibrary(userId);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _deferNotifyListeners();
      return false;
    }
  }

  // Verificar si el usuario tiene un libro
  Future<bool> userHasBook(String userId, String bookId) async {
    try {
      return await _userBookService.userHasBook(userId, bookId);
    } catch (e) {
      _errorMessage = e.toString();
      _deferNotifyListeners();
      return false;
    }
  }

  // Limpiar errores
  void clearError() {
    _errorMessage = null;
    _deferNotifyListeners();
  }

  @override
  void dispose() {
    stopListeningToUserBooks();
    super.dispose();
  }
}
