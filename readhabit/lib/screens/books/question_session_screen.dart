// lib/screens/books/question_session_screen.dart - COMPLETO
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/book.dart';
import '../../providers/question_provider.dart';
import '../../providers/reading_provider.dart';

class QuestionSessionScreen extends StatefulWidget {
  final Book book;
  final int chaptersRead;

  const QuestionSessionScreen({
    super.key,
    required this.book,
    required this.chaptersRead,
  });

  @override
  State<QuestionSessionScreen> createState() => _QuestionSessionScreenState();
}

class _QuestionSessionScreenState extends State<QuestionSessionScreen> {
  late Stopwatch _stopwatch;

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch()..start();
    _loadQuestions();
  }

  void _loadQuestions() {
    final questionProvider = context.read<QuestionProvider>();
    questionProvider.loadQuestionsForSession(
      book: widget.book,
      chaptersRead: widget.chaptersRead,
      totalChapters: widget.book.totalChapters ?? 10,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preguntas de Comprensión'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Consumer<QuestionProvider>(
        builder: (context, questionProvider, child) {
          if (questionProvider.isLoading) {
            return _buildLoadingScreen();
          }

          if (questionProvider.sessionCompleted) {
            return _buildResultsScreen(questionProvider);
          }

          if (questionProvider.currentQuestion == null) {
            return _buildErrorScreen(questionProvider);
          }

          return _buildQuestionScreen(questionProvider);
        },
      ),
    );
  }

  // ✅ AGREGAR: Método para pantalla de carga
  Widget _buildLoadingScreen() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 20),
          Text(
            'Generando preguntas...',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  // ✅ AGREGAR: Método para pantalla de pregunta
  Widget _buildQuestionScreen(QuestionProvider provider) {
    final question = provider.currentQuestion!;
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progreso
          LinearProgressIndicator(
            value: (provider.currentQuestionIndex + 1) / provider.totalQuestions,
          ),
          const SizedBox(height: 10),
          Text(
            'Pregunta ${provider.currentQuestionIndex + 1} de ${provider.totalQuestions}',
            style: const TextStyle(color: Colors.grey),
          ),
          
          const SizedBox(height: 20),
          
          // Pregunta
          Text(
            question.questionText,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          
          const SizedBox(height: 30),
          
          // Opciones
          Expanded(
            child: ListView.builder(
              itemCount: question.options.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    title: Text(question.options[index]),
                    onTap: () {
                      _stopwatch.stop();
                      provider.answerQuestion(
                        index,
                        timeSpent: _stopwatch.elapsed.inSeconds,
                      );
                      _stopwatch
                        ..reset()
                        ..start();
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ✅ AGREGAR: Método para pantalla de resultados
  Widget _buildResultsScreen(QuestionProvider provider) {
    final stats = provider.sessionStats;
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            stats['score'] >= 70 ? Icons.celebration : Icons.school,
            size: 80,
            color: stats['score'] >= 70 ? Colors.green : Colors.orange,
          ),
          
          const SizedBox(height: 20),
          
          Text(
            '¡Sesión Completada!',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          
          const SizedBox(height: 30),
          
          Text(
            'Puntuación: ${stats['score'].toStringAsFixed(1)}%',
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          
          const SizedBox(height: 20),
          
          Text(
            'Correctas: ${stats['correctAnswers']} / ${stats['totalQuestions']}',
            style: const TextStyle(fontSize: 18),
          ),
          
          const SizedBox(height: 40),
          
          ElevatedButton(
            onPressed: () {
              _saveSessionResults(provider);
              Navigator.pop(context, stats['score']);
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            ),
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
  }

  // ✅ AGREGAR: Método para pantalla de error
  Widget _buildErrorScreen(QuestionProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, size: 60, color: Colors.red),
          const SizedBox(height: 20),
          const Text(
            'Error al cargar preguntas',
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 10),
          Text(provider.errorMessage ?? 'Error desconocido'),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _loadQuestions,
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  // ✅ CORREGIR: Este método SÍ se usa en _buildResultsScreen
  void _saveSessionResults(QuestionProvider provider) {
    final readingProvider = context.read<ReadingProvider>();
    
    // Usar el método que ahora existe
    readingProvider.recordComprehensionScore(provider.sessionScore);
    
    // En lugar de print, puedes usar debugPrint o logging
    debugPrint('Score de comprensión guardado: ${provider.sessionScore}%');
  }

  @override
  void dispose() {
    _stopwatch.stop();
    super.dispose();
  }
}