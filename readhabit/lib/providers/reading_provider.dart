import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/reading_service.dart';
import '../models/user_book.dart';
import '../models/reading_session.dart';
import '../models/question_result.dart';

class ReadingProvider with ChangeNotifier {
  final ReadingService _readingService = ReadingService();
  String _userId;

  bool _isLoading = false;
  String? _errorMessage;
  bool _hasCompletedToday = false;
  final int _currentStreak = 0;
  final int _longestStreak = 0;
  DateTime? _lastReadingDate;
  final List<UserBook> _booksInProgress = [];
  final bool _hasWeeklyPauseAvailable = true;
  double _lastComprehensionScore = 0.0;

  String get userId => _userId;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasCompletedToday => _hasCompletedToday;
  int get currentStreak => _currentStreak;
  int get longestStreak => _longestStreak;
  DateTime? get lastReadingDate => _lastReadingDate;
  List<UserBook> get booksInProgress => _booksInProgress;
  bool get hasWeeklyPauseAvailable => _hasWeeklyPauseAvailable;
  double get lastComprehensionScore => _lastComprehensionScore;

  ReadingProvider(this._userId) {
    if (_userId.isNotEmpty) {
      _loadUserData();
    }
  }

  void updateUserID(String newUserId) {
    if (_userId != newUserId && newUserId.isNotEmpty) {
      _userId = newUserId;
      _loadUserData();
    }
  }

  Future<void> _loadUserData() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _loadUserStreakData();

      _hasCompletedToday = await _readingService.hasCompletedToday(_userId);

      await _loadBooksInProgress();

      await _checkWeeklyPauseAvailability();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error al cargar datos: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadUserStreakData() async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_userId)
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data()!;

        _lastComprehensionScore = (userData['lastComprehensionScore'] ?? 0)
            .toDouble();

        if (userData['lastReadingDate'] != null) {
          _lastReadingDate = DateTime.tryParse(userData['lastReadingDate']);
        }
      } else {
        await _createUserDocument();
      }
    } catch (e) {
      debugPrint('Error loading streak data: $e');
    }
  }

  Future<void> _createUserDocument() async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(_userId).set({
        'currentStreak': 0,
        'longestStreak': 0,
        'lastReadingDate': null,
        'lastComprehensionScore': 0.0,
        'weeklyPausesUsed': 0,
        'lastWeeklyPauseReset': DateTime.now().toIso8601String(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error creating user document: $e');
    }
  }

  Future<void> _loadBooksInProgress() async {
    try {
      final booksData = await _readingService.getBooksInProgress(_userId);

      _booksInProgress.clear();
      _booksInProgress.addAll(
        booksData.map((bookMap) {
          return UserBook.fromFirestore(bookMap, bookMap['id'] ?? '');
        }).toList(),
      );
    } catch (e) {
      _errorMessage = 'Error al cargar libros: $e';
    }
  }

  Future<void> _checkWeeklyPauseAvailability() async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_userId)
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data()!;
        final weeklyPausesUsed = userData['weeklyPausesUsed'] ?? 0;
        final lastResetStr = userData['lastWeeklyPauseReset'];

        if (lastResetStr != null) {
          final lastReset = DateTime.parse(lastResetStr);
          final now = DateTime.now();

          if (now.difference(lastReset).inDays >= 7) {
            await _resetWeeklyPauses();
          } else {}
        } else {}
      }
    } catch (e) {
      debugPrint('Error checking weekly pause: $e');
    }
  }

  Future<void> _resetWeeklyPauses() async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(_userId).update({
        'weeklyPausesUsed': 0,
        'lastWeeklyPauseReset': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Error resetting weekly pauses: $e');
    }
  }

  Future<bool> markDailyReading(uid) async {
    if (_hasCompletedToday) {
      _errorMessage = 'Ya has marcado tu lectura de hoy';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final success = await _readingService.markDailyReading(_userId);

      if (success) {
        _hasCompletedToday = true;

        await _loadUserStreakData();
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Error al marcar lectura diaria';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> useWeeklyPause() async {
    if (!_hasWeeklyPauseAvailable) {
      _errorMessage = 'No tienes pausas semanales disponibles';
      notifyListeners();
      return false;
    }

    if (_hasCompletedToday) {
      _errorMessage = 'Ya has completado tu lectura de hoy';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final success = await _readingService.markWeeklyPause(_userId);

      if (success) {
        _hasCompletedToday = true;

        await FirebaseFirestore.instance
            .collection('users')
            .doc(_userId)
            .update({'weeklyPausesUsed': FieldValue.increment(1)});

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Error al aplicar pausa semanal';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> refreshData() async {
    await _loadUserData();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> recordComprehensionScore(double score) async {
    try {
      _lastComprehensionScore = score;

      await FirebaseFirestore.instance.collection('users').doc(_userId).update({
        'lastComprehensionScore': score,
      });

      await _saveComprehensionHistory(score);

      notifyListeners();
    } catch (e) {
      debugPrint(
        'Error guardando score de comprensión: $e',
      ); // ✅ Cambiado a debugPrint
    }
  }

  Future<void> _saveComprehensionHistory(double score) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_userId)
          .collection('comprehensionHistory')
          .add({
            'score': score,
            'date': DateTime.now().toIso8601String(),
            'bookId': _getCurrentBookId(),
          });
    } catch (e) {
      debugPrint(
        'Error guardando historial de comprensión: $e',
      ); // ✅ Cambiado a debugPrint
    }
  }

  String? _getCurrentBookId() {
    if (_booksInProgress.isNotEmpty) {
      return _booksInProgress.first.bookId;
    }
    return null;
  }

  Future<bool> completeReadingSessionWithQuestions({
    required String bookId,
    required int chaptersRead,
    required int timeSpent,
    required double comprehensionScore,
    required int correctAnswers,
    required int totalQuestions,
    List<QuestionResult> questionResults = const [],
  }) async {
    if (_hasCompletedToday) {
      _errorMessage = 'Ya has completado tu lectura de hoy';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      await recordComprehensionScore(comprehensionScore);

      final readingSuccess = await _readingService.markDailyReading(_userId);

      if (readingSuccess) {
        await _saveDetailedReadingSession(
          bookId: bookId,
          chaptersRead: chaptersRead,
          timeSpent: timeSpent,
          comprehensionScore: comprehensionScore,
          correctAnswers: correctAnswers,
          totalQuestions: totalQuestions,
          questionResults: questionResults,
        );

        _hasCompletedToday = true;

        await _loadUserStreakData();
        await _loadBooksInProgress();

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Error al completar la sesión';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> _saveDetailedReadingSession({
    required String bookId,
    required int chaptersRead,
    required int timeSpent,
    required double comprehensionScore,
    required int correctAnswers,
    required int totalQuestions,
    required List<QuestionResult> questionResults,
  }) async {
    try {
      final session = ReadingSession.withQuestions(
        id: '',
        userId: _userId,
        bookId: bookId,
        chaptersRead: chaptersRead,
        pagesRead: 0,
        timeSpent: timeSpent,
        sessionDate: DateTime.now(),
        questionResults: questionResults,
        comprehensionScore: comprehensionScore,
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(_userId)
          .collection('readingSessions')
          .add(session.toFirestore());
    } catch (e) {
      debugPrint(
        'Error guardando sesión detallada: $e',
      ); // ✅ Cambiado a debugPrint
    }
  }
}
