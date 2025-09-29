// lib/providers/reading_provider.dart - ACTUALIZADO CON SISTEMA DE RACHA COMPLETO
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/reading_service.dart';

class ReadingProvider with ChangeNotifier {
  final ReadingService _readingService = ReadingService();
  final String _userId;

  bool _isLoading = false;
  String? _errorMessage;
  bool _hasCompletedToday = false;
  int _currentStreak = 0;
  int _longestStreak = 0;
  DateTime? _lastReadingDate;
  List<Map<String, dynamic>> _booksInProgress = [];
  bool _hasWeeklyPauseAvailable = true;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasCompletedToday => _hasCompletedToday;
  int get currentStreak => _currentStreak;
  int get longestStreak => _longestStreak;
  DateTime? get lastReadingDate => _lastReadingDate;
  List<Map<String, dynamic>> get booksInProgress => _booksInProgress;
  bool get hasWeeklyPauseAvailable => _hasWeeklyPauseAvailable;

  ReadingProvider(this._userId) {
    _loadUserData();
  }

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
        _currentStreak = userData['currentStreak'] ?? 0;
        _longestStreak = userData['longestStreak'] ?? 0;

        if (userData['lastReadingDate'] != null) {
          _lastReadingDate = DateTime.tryParse(userData['lastReadingDate']);
        }
      } else {
        // Si el usuario no existe, crear documento inicial
        await _createUserDocument();
      }
    } catch (e) {
      print('Error loading streak data: $e');
    }
  }

  Future<void> _createUserDocument() async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(_userId).set({
        'currentStreak': 0,
        'longestStreak': 0,
        'lastReadingDate': null,
        'weeklyPausesUsed': 0,
        'lastWeeklyPauseReset': DateTime.now().toIso8601String(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error creating user document: $e');
    }
  }

  Future<void> _loadBooksInProgress() async {
    try {
      _booksInProgress = await _readingService.getBooksInProgress(_userId);
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

          // Resetear pausas semanales si ha pasado una semana
          if (now.difference(lastReset).inDays >= 7) {
            await _resetWeeklyPauses();
            _hasWeeklyPauseAvailable = true;
          } else {
            _hasWeeklyPauseAvailable =
                weeklyPausesUsed < 1; // Máximo 1 pausa por semana
          }
        } else {
          _hasWeeklyPauseAvailable = true;
        }
      }
    } catch (e) {
      print('Error checking weekly pause: $e');
      _hasWeeklyPauseAvailable = false;
    }
  }

  Future<void> _resetWeeklyPauses() async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(_userId).update({
        'weeklyPausesUsed': 0,
        'lastWeeklyPauseReset': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error resetting weekly pauses: $e');
    }
  }

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
        _hasWeeklyPauseAvailable = false;

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

  // Método para refrescar datos desde el home
  Future<void> refreshData() async {
    await _loadUserData();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
