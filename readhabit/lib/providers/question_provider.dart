// lib/providers/question_provider.dart
import 'package:flutter/material.dart';
import '../models/book.dart';
import '../models/question.dart';
import '../models/question_result.dart';
import '../services/question_service.dart';

class QuestionProvider with ChangeNotifier {
  final QuestionService _questionService;
  
  List<Question> _currentQuestions = [];
  int _currentQuestionIndex = 0;
  List<QuestionResult> _questionResults = []; 
  bool _isLoading = false;
  String? _errorMessage;
  bool _sessionCompleted = false;

  QuestionProvider(this._questionService);

  // Getters
  List<Question> get currentQuestions => _currentQuestions;
  Question? get currentQuestion => 
      _currentQuestions.isNotEmpty && _currentQuestionIndex < _currentQuestions.length
          ? _currentQuestions[_currentQuestionIndex]
          : null;
          
  int get currentQuestionIndex => _currentQuestionIndex;
  int get totalQuestions => _currentQuestions.length;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get sessionCompleted => _sessionCompleted;
  bool get hasNextQuestion => _currentQuestionIndex < _currentQuestions.length - 1;

  // Cargar preguntas para una sesión de lectura
  Future<void> loadQuestionsForSession({
    required Book book,
    required int chaptersRead,
    required int totalChapters,
    int questionCount = 3,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentQuestions = await _questionService.generateQuestions(
        book: book,
        chaptersRead: chaptersRead,
        totalChapters: totalChapters,
        questionCount: questionCount,
      );
      
      _currentQuestionIndex = 0;
      _questionResults = [];
      _sessionCompleted = false;
    } catch (e) {
      _errorMessage = 'Error al generar preguntas: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Responder pregunta actual
  void answerQuestion(int selectedIndex, {int timeSpent = 0}) {
    if (currentQuestion == null) return;

    final result = QuestionResult( // ✅ Ahora QuestionResult está definido
      questionId: currentQuestion!.id,
      selectedAnswer: selectedIndex,
      isCorrect: currentQuestion!.validateAnswer(selectedIndex),
      timeSpent: timeSpent,
    );
    
    _questionResults.add(result);

    // Avanzar a siguiente pregunta o terminar
    if (_currentQuestionIndex < _currentQuestions.length - 1) {
      _currentQuestionIndex++;
    } else {
      _sessionCompleted = true;
    }
    
    notifyListeners();
  }

  // Calcular puntuación final
  double get sessionScore {
    if (_questionResults.isEmpty) return 0.0;
    final correctAnswers = _questionResults.where((r) => r.isCorrect).length;
    return (correctAnswers / _questionResults.length) * 100;
  }

  // ✅ CORREGIDO: Método para obtener estadísticas sin errores
  Map<String, dynamic> get sessionStats {
    final totalQuestions = _questionResults.length;
    final correctAnswers = _questionResults.where((r) => r.isCorrect).length;
    final incorrectAnswers = totalQuestions - correctAnswers;
    
    // ✅ CORREGIDO: Manejo seguro de averageTime
    int totalTime = 0;
    for (final result in _questionResults) {
      totalTime += result.timeSpent; // timeSpent es int, no nullable
    }
    
    final averageTime = totalQuestions > 0 ? totalTime / totalQuestions : 0.0;
    
    return {
      'totalQuestions': totalQuestions,
      'correctAnswers': correctAnswers,
      'incorrectAnswers': incorrectAnswers,
      'score': sessionScore,
      'averageTimePerQuestion': averageTime,
      'questionResults': List<QuestionResult>.from(_questionResults),
    };
  }

  // Reiniciar sesión
  void resetSession() {
    _currentQuestions = [];
    _currentQuestionIndex = 0;
    _questionResults = [];
    _sessionCompleted = false;
    _errorMessage = null;
    notifyListeners();
  }

  // ✅ CORREGIDO: Obtener resultados detallados
  List<QuestionResult> get questionResults => List<QuestionResult>.from(_questionResults);

  // ✅ CORREGIDO: Obtener tiempo total de la sesión de preguntas
  int get totalSessionTime {
    return _questionResults.fold<int>(0, (total, result) => total + result.timeSpent);
  }
}