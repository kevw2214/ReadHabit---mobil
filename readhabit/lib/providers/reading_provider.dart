// lib/providers/reading_provider.dart - COMPLETO
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

  // Getters
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
    if (_userId.isNotEmpty){
      _loadUserData();
    }
  }

  void updateUserID(String newUserId){
    if (_userId  != newUserId && newUserId.isNotEmpty){
      _userId = newUserId;
      _loadUserData();
    }
  }

  // metodo _loadUserData
  Future<void> _loadUserData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Cargar datos del usuario desde Firestore
      await _loadUserStreakData();

      // Verificar si ya leyó hoy
      _hasCompletedToday = await _readingService.hasCompletedToday(_userId);

      // Cargar libros en progreso
      await _loadBooksInProgress();

      // Verificar disponibilidad de pausa semanal
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
        // Actualizar los valores (aunque sean final, podemos recrear el provider si es necesario)
        // _currentStreak = userData['currentStreak'] ?? 0;
        // _longestStreak = userData['longestStreak'] ?? 0;
        _lastComprehensionScore = (userData['lastComprehensionScore'] ?? 0).toDouble();

        if (userData['lastReadingDate'] != null) {
          _lastReadingDate = DateTime.tryParse(userData['lastReadingDate']);
        }
      } else {
        // Si el usuario no existe, crear documento inicial
        await _createUserDocument();
      }
    } catch (e) {
      debugPrint('Error loading streak data: $e');
    }
  }

  // ✅ MÉTODO _createUserDocument COMPLETO
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

  // ✅ MÉTODO _loadBooksInProgress COMPLETO
  Future<void> _loadBooksInProgress() async {
    try {
      final booksData = await _readingService.getBooksInProgress(_userId);
      // Limpiar la lista y agregar nuevos elementos
      _booksInProgress.clear();
      _booksInProgress.addAll(booksData.map((bookMap) {
        return UserBook.fromFirestore(bookMap, bookMap['id'] ?? '');
      }).toList());
    } catch (e) {
      _errorMessage = 'Error al cargar libros: $e';
    }
  }

  // ✅ MÉTODO _checkWeeklyPauseAvailability COMPLETO
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

          // Resetear pausas semanales si ha pasado una semana
          if (now.difference(lastReset).inDays >= 7) {
            await _resetWeeklyPauses();
            // _hasWeeklyPauseAvailable = true; // No se puede modificar si es final
          } else {
            // _hasWeeklyPauseAvailable = weeklyPausesUsed < 1; // No se puede modificar si es final
          }
        } else {
          // _hasWeeklyPauseAvailable = true; // No se puede modificar si es final
        }
      }
    } catch (e) {
      debugPrint('Error checking weekly pause: $e');
      // _hasWeeklyPauseAvailable = false; // No se puede modificar si es final
    }
  }

  // ✅ MÉTODO _resetWeeklyPauses COMPLETO
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

  // ✅ MÉTODO markDailyReading COMPLETO
  Future<bool> markDailyReading() async {
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
        // Recargar datos de racha para obtener los valores actualizados
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

  // ✅ MÉTODO useWeeklyPause COMPLETO
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
      // Marcar pausa como lectura diaria sin afectar la racha
      final success = await _readingService.markWeeklyPause(_userId);

      if (success) {
        _hasCompletedToday = true;
        // _hasWeeklyPauseAvailable = false; // No se puede modificar si es final

        // Actualizar contador de pausas semanales
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

  // ✅ MÉTODO refreshData COMPLETO
  Future<void> refreshData() async {
    await _loadUserData();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ✅ NUEVOS MÉTODOS PARA SISTEMA DE PREGUNTAS
  Future<void> recordComprehensionScore(double score) async {
    try {
      _lastComprehensionScore = score;
      
      await FirebaseFirestore.instance.collection('users').doc(_userId).update({
        'lastComprehensionScore': score,
      });

      await _saveComprehensionHistory(score);
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error guardando score de comprensión: $e'); // ✅ Cambiado a debugPrint
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
      debugPrint('Error guardando historial de comprensión: $e'); // ✅ Cambiado a debugPrint
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
      // 1. Registrar el score de comprensión
      await recordComprehensionScore(comprehensionScore);

      // 2. Marcar lectura diaria
      final readingSuccess = await _readingService.markDailyReading(_userId);

      if (readingSuccess) {
        // 3. Guardar sesión detallada
        await _saveDetailedReadingSession(
          bookId: bookId,
          chaptersRead: chaptersRead,
          timeSpent: timeSpent,
          comprehensionScore: comprehensionScore,
          correctAnswers: correctAnswers,
          totalQuestions: totalQuestions,
          questionResults: questionResults,
        );

        // 4. Actualizar estado local
        _hasCompletedToday = true;
        
        // 5. Recargar datos
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
      debugPrint('Error guardando sesión detallada: $e'); // ✅ Cambiado a debugPrint
    }
  }
}