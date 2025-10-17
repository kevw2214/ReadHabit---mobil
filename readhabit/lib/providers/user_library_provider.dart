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

  List<UserBook> get booksInProgress => _booksInProgress;
  List<UserBook> get completedBooks => _completedBooks;
  ReadingStatistics? get statistics => _statistics;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

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

  void _deferNotifyListeners() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  void stopListeningToUserBooks() {
    _booksSubscription?.cancel();
    _booksSubscription = null;
  }

  Future<bool> addBookToLibrary({
    required String userId,
    required Book book,
    required int readingPlan,
  }) async {
    try {
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

      await loadUserLibrary(userId);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _deferNotifyListeners();
      return false;
    }
  }

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

      await loadUserLibrary(userId);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _deferNotifyListeners();
      return false;
    }
  }

  Future<bool> continueReading({
    required String userBookId,
    required int currentChapter,
    required int totalChapters,
    required String userId,
  }) async {
    final newChapter = currentChapter + 1;

    if (newChapter >= totalChapters) {
      return await markBookAsCompleted(userBookId: userBookId, userId: userId);
    } else {
      return await updateReadingProgress(
        userBookId: userBookId,
        newChapter: newChapter,
        userId: userId,
      );
    }
  }

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

  Future<bool> userHasBook(String userId, String bookId) async {
    try {
      return await _userBookService.userHasBook(userId, bookId);
    } catch (e) {
      _errorMessage = e.toString();
      _deferNotifyListeners();
      return false;
    }
  }

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
