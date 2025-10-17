import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:readhabit/models/user_book.dart';
import 'package:readhabit/providers/user_library_provider.dart';
import 'package:readhabit/providers/auth_provider.dart';
import 'package:readhabit/providers/reading_provider.dart';
import 'package:readhabit/services/chapter_service.dart';
import 'package:readhabit/screens/books/question_session_screen.dart'; // ✅ Nueva importación

class ReadingScreen extends StatefulWidget {
  final UserBook userBook;

  const ReadingScreen({super.key, required this.userBook});

  @override
  State<ReadingScreen> createState() => _ReadingScreenState();
}

class _ReadingScreenState extends State<ReadingScreen> {
  bool _isLoading = false;
  late UserBook _currentUserBook;
  int _pagesReadInSession =
      0; // ✅ Nuevo: Contador de páginas leídas en esta sesión

  @override
  void initState() {
    super.initState();
    _currentUserBook = widget.userBook;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${_currentUserBook.book.title} - Capítulo ${_currentUserBook.currentChapter + 1}',
          style: const TextStyle(fontSize: 16),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [_buildPauseButton()],
      ),
      body: Container(
        color: const Color(0xFFF5F5F5),
        child: Column(
          children: [
            _buildProgressBar(),

            _buildSessionProgress(), // ✅ NUEVO: Contador de sesión

            Expanded(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Capítulo ${_currentUserBook.currentChapter + 1}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E90FF),
                        ),
                      ),
                      const SizedBox(height: 16),

                      FutureBuilder<String>(
                        key: ValueKey(
                          '${_currentUserBook.book.id}_${_currentUserBook.currentChapter}',
                        ),
                        future: _getChapterContent(
                          _currentUserBook.currentChapter,
                        ),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(50),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          } else if (snapshot.hasError) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      size: 48,
                                      color: Colors.red.shade400,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Error al cargar el capítulo',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red.shade600,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '${snapshot.error}',
                                      style: TextStyle(
                                        color: Colors.red.shade500,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          } else if (snapshot.hasData) {
                            return Column(
                              children: [
                                Text(
                                  snapshot.data!,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    height: 1.6,
                                    color: Colors.black87,
                                  ),
                                  textAlign: TextAlign.justify,
                                ),
                                const SizedBox(height: 20),

                                _buildPageCounter(),
                              ],
                            );
                          } else {
                            return const Center(
                              child: Text('No se pudo cargar el contenido'),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            _buildBottomControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    final progress =
        (_currentUserBook.currentChapter + 1) / _currentUserBook.totalChapters;

    return Container(
      height: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: LinearProgressIndicator(
        value: progress,
        backgroundColor: Colors.grey.shade300,
        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF1E90FF)),
      ),
    );
  }

  Widget _buildSessionProgress() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Páginas leídas en esta sesión:',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF1E90FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$_pagesReadInSession páginas',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageCounter() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Registrar páginas leídas',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Has leído $_pagesReadInSession páginas en esta sesión',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _isLoading ? null : _addPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E90FF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  child: const Text('+1 Página'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPauseButton() {
    return IconButton(
      onPressed: _isLoading ? null : _pauseReading,
      icon: const Icon(Icons.pause),
      tooltip: 'Pausar lectura',
    );
  }

  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _isLoading || _isLastChapter() ? null : _nextChapter,
              icon: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.skip_next),
              label: Text(
                _isLastChapter() ? 'Último Capítulo' : 'Siguiente Capítulo',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isLastChapter()
                    ? Colors.grey
                    : const Color(0xFF1E90FF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(width: 16),

          Expanded(
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _finishSession,
              icon: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.quiz),
              label: const Text('Terminar y Validar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<String> _getChapterContent(int chapter) async {
    final chapterService = ChapterService();
    return await chapterService.getChapterContent(
      _currentUserBook.book.id,
      chapter,
    );
  }

  void _addPage() {
    setState(() {
      _pagesReadInSession++;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('+1 página registrada'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 1),
      ),
    );
  }

  bool _isLastChapter() {
    return _currentUserBook.currentChapter + 1 >=
        _currentUserBook.totalChapters;
  }

  Future<void> _pauseReading() async {
    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final libraryProvider = Provider.of<UserLibraryProvider>(
        context,
        listen: false,
      );

      if (authProvider.user != null) {
        await libraryProvider.updateReadingProgress(
          userBookId: _currentUserBook.id,
          newChapter: _currentUserBook.currentChapter,
          userId: authProvider.user!.uid,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Progreso guardado - Sesión pausada'),
              backgroundColor: Colors.orange,
            ),
          );

          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al pausar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _nextChapter() async {
    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final libraryProvider = Provider.of<UserLibraryProvider>(
        context,
        listen: false,
      );

      if (authProvider.user != null) {
        final newChapter = _currentUserBook.currentChapter + 1;

        await libraryProvider.updateReadingProgress(
          userBookId: _currentUserBook.id,
          newChapter: newChapter,
          userId: authProvider.user!.uid,
        );

        setState(() {
          _currentUserBook = _currentUserBook.copyWith(
            currentChapter: newChapter,
            lastReadDate: DateTime.now(),
          );
          _pagesReadInSession = 0;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Avanzando al siguiente capítulo'),
              backgroundColor: Colors.blue,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al avanzar capítulo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _finishSession() async {
    if (_pagesReadInSession == 0) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('¿Terminar sesión?'),
          content: const Text(
            'No has registrado páginas leídas en esta sesión. '
            '¿Estás seguro de que quieres terminar?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Sí, Terminar'),
            ),
          ],
        ),
      );

      if (confirmed != true) return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final readingProvider = Provider.of<ReadingProvider>(
        context,
        listen: false,
      );

      if (authProvider.user != null) {
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QuestionSessionScreen(
                book: _currentUserBook.book,
                chaptersRead: _pagesReadInSession > 0
                    ? 1
                    : 0, // 1 capítulo leído
              ),
            ),
          ).then((_) {
            Navigator.pop(context);
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al terminar sesión: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
