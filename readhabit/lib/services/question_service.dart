import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/book.dart';
import '../models/question.dart';

class QuestionService {
  static const String _baseUrl = 'https://api.openai.com/v1/chat/completions';
  final String? apiKey;

  QuestionService([this.apiKey]);

  Future<List<Question>> generateQuestions({
    required Book book,
    required int chaptersRead,
    required int totalChapters,
    int questionCount = 3,
  }) async {
    if (apiKey == null || apiKey!.isEmpty) {
      debugPrint('No hay API key - Usando preguntas mock');
      return _generateMockQuestions(book, chaptersRead, questionCount);
    }

    try {
      debugPrint(
        '🔄 Generando preguntas con IA para capítulo $chaptersRead...',
      );
      return await _generateQuestionsWithAI(
        book: book,
        chaptersRead: chaptersRead,
        totalChapters: totalChapters,
        questionCount: questionCount,
      );
    } catch (e) {
      debugPrint('Error con API de IA: $e - Usando fallback');
      return _generateMockQuestions(book, chaptersRead, questionCount);
    }
  }

  Future<List<Question>> _generateQuestionsWithAI({
    required Book book,
    required int chaptersRead,
    required int totalChapters,
    required int questionCount,
  }) async {
    final prompt =
        '''
    Genera $questionCount preguntas de comprensión lectora ESPECÍFICAS del CAPÍTULO $chaptersRead 
    del libro "${book.title}" del autor ${book.author}. 
    
    Información del capítulo:
    - Número de capítulo: $chaptersRead de $totalChapters
    - Género del libro: ${book.category}
    - Contexto general: ${book.description ?? 'No disponible'}
    
    REQUISITOS CRÍTICOS:
    1. Las preguntas deben ser ESPECÍFICAS del capítulo $chaptersRead
    2. NO hagas preguntas generales sobre el libro completo
    3. Enfócate en eventos, personajes o detalles específicos de ESTE capítulo
    4. 4 opciones de respuesta (A, B, C, D) con solo UNA correcta
    5. Incluir explicación breve de la respuesta correcta
    6. Dificultad variada (easy, medium, hard)
    
    Formato JSON EXACTO:
    {
      "questions": [
        {
          "id": "1",
          "questionText": "pregunta específica del capítulo $chaptersRead aquí",
          "options": ["A", "B", "C", "D"],
          "correctIndex": 0,
          "explanation": "explicación específica aquí",
          "difficulty": "medium"
        }
      ]
    }
    
    Devuelve SOLO el JSON, sin texto adicional.
    ''';

    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': 'gpt-3.5-turbo',
        'messages': [
          {'role': 'user', 'content': prompt},
        ],
        'temperature': 0.7,
        'max_tokens': 2000,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final content = data['choices'][0]['message']['content'];
      debugPrint('✅ Respuesta de IA recibida: ${content.length} caracteres');

      final questionsData = jsonDecode(content);
      return _parseQuestions(questionsData, book.id, chaptersRead);
    } else {
      debugPrint('❌ Error HTTP: ${response.statusCode} - ${response.body}');
      throw Exception('Error de API: ${response.statusCode}');
    }
  }

  List<Question> _parseQuestions(
    Map<String, dynamic> data,
    String bookId,
    int chapter,
  ) {
    final List<dynamic> questionsJson = data['questions'];
    debugPrint(
      '✅ Parseando ${questionsJson.length} preguntas para capítulo $chapter',
    );

    return questionsJson.asMap().entries.map((entry) {
      final index = entry.key;
      final q = entry.value;

      return Question(
        id: '${bookId}_ch${chapter}_q${index + 1}',
        bookId: bookId,
        chapter: chapter,
        questionText: q['questionText'],
        options: List<String>.from(q['options']),
        correctIndex: q['correctIndex'],
        explanation: q['explanation'],
        difficulty: q['difficulty'],
        createdAt: DateTime.now(),
      );
    }).toList();
  }

  List<Question> _generateMockQuestions(Book book, int chapter, int count) {
    final mockQuestions = [
      {
        'text':
            '¿Qué evento importante ocurre en el capítulo $chapter de "${book.title}"?',
        'options': [
          'Se revela un secreto crucial',
          'Un personaje toma una decisión difícil',
          'Ocurre un enfrentamiento clave',
          'Se introduce un nuevo personaje',
        ],
        'correct': 0,
        'explanation':
            'Este capítulo contiene una revelación que cambia el curso de la historia.',
        'difficulty': 'medium',
      },
      {
        'text':
            '¿Cómo evoluciona el personaje principal en el capítulo $chapter?',
        'options': [
          'Aprende una lección importante',
          'Enfrenta sus miedos',
          'Toma una acción decisiva',
          'Reflexiona sobre sus errores',
        ],
        'correct': 2,
        'explanation':
            'El protagonista demuestra crecimiento al tomar una acción crucial.',
        'difficulty': 'hard',
      },
      {
        'text': '¿Qué ambiente predomina en el capítulo $chapter?',
        'options': [
          'De suspense y misterio',
          'De acción y movimiento',
          'De reflexión interna',
          'De diálogo y desarrollo',
        ],
        'correct': 0,
        'explanation':
            'El capítulo mantiene un tono de suspense que mantiene al lector intrigado.',
        'difficulty': 'easy',
      },
    ];

    return List.generate(count, (index) {
      final mock = mockQuestions[index % mockQuestions.length];

      return Question(
        id: '${book.id}_ch${chapter}_mock_${index + 1}',
        bookId: book.id,
        chapter: chapter,
        questionText: mock['text'] as String,
        options: List<String>.from(mock['options'] as List),
        correctIndex: mock['correct'] as int,
        explanation: mock['explanation'] as String,
        difficulty: mock['difficulty'] as String,
        createdAt: DateTime.now(),
      );
    });
  }
}
