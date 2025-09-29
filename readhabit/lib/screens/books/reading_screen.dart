// lib/screens/books/reading_screen.dart - ACTUALIZADA CON SISTEMA DE RACHA
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:readhabit/models/user_book.dart';
import 'package:readhabit/providers/user_library_provider.dart';
import 'package:readhabit/providers/auth_provider.dart';
import 'package:readhabit/providers/reading_provider.dart';
import 'package:readhabit/services/chapter_service.dart';

class ReadingScreen extends StatefulWidget {
  final UserBook userBook;

  const ReadingScreen({super.key, required this.userBook});

  @override
  State<ReadingScreen> createState() => _ReadingScreenState();
}

class _ReadingScreenState extends State<ReadingScreen> {
  bool _isLoading = false;
  late UserBook _currentUserBook;

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
        actions: [_buildPauseButton(), _buildFinishButton()],
      ),
      body: Container(
        color: const Color(0xFFF5F5F5),
        child: Column(
          children: [
            // Progress bar
            _buildProgressBar(),

            // Chapter content
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
                      // Chapter title
                      Text(
                        'Capítulo ${_currentUserBook.currentChapter + 1}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E90FF),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Chapter content
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
                            return Text(
                              snapshot.data!,
                              style: const TextStyle(
                                fontSize: 16,
                                height: 1.6,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.justify,
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

            // Bottom controls
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

  Widget _buildPauseButton() {
    return IconButton(
      onPressed: _isLoading ? null : _pauseReading,
      icon: const Icon(Icons.pause),
      tooltip: 'Pausar lectura',
    );
  }

  Widget _buildFinishButton() {
    return IconButton(
      onPressed: _isLoading ? null : _finishChapter,
      icon: const Icon(Icons.check),
      tooltip: 'Terminar capítulo',
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
              onPressed: _isLoading ? null : _pauseReading,
              icon: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.pause),
              label: const Text('Pausar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
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
              onPressed: _isLoading ? null : _finishChapter,
              icon: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.check),
              label: const Text('Terminar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E90FF),
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

  Future<void> _pauseReading() async {
    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final libraryProvider = Provider.of<UserLibraryProvider>(
        context,
        listen: false,
      );

      if (authProvider.user != null) {
        // Guardar progreso actual
        await libraryProvider.updateReadingProgress(
          userBookId: _currentUserBook.id,
          newChapter: _currentUserBook.currentChapter,
          userId: authProvider.user!.uid,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Progreso guardado'),
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

  Future<void> _finishChapter() async {
    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final libraryProvider = Provider.of<UserLibraryProvider>(
        context,
        listen: false,
      );
      final readingProvider = Provider.of<ReadingProvider>(
        context,
        listen: false,
      );

      if (authProvider.user != null) {
        // Avanzar al siguiente capítulo
        final newChapter = _currentUserBook.currentChapter + 1;

        // Si llegamos al final del libro
        if (newChapter >= _currentUserBook.totalChapters) {
          await libraryProvider.markBookAsCompleted(
            userBookId: _currentUserBook.id,
            userId: authProvider.user!.uid,
          );

          // Marcar lectura diaria y activar racha
          await readingProvider.markDailyReading();

          if (mounted) {
            _showCompletionDialog();
          }
        } else {
          // Continuar al siguiente capítulo
          await libraryProvider.updateReadingProgress(
            userBookId: _currentUserBook.id,
            newChapter: newChapter,
            userId: authProvider.user!.uid,
          );

          // Marcar lectura diaria y activar racha
          await readingProvider.markDailyReading();

          // Actualizar el estado local para mostrar el nuevo capítulo
          setState(() {
            _currentUserBook = _currentUserBook.copyWith(
              currentChapter: newChapter,
              lastReadDate: DateTime.now(),
            );
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Capítulo completado. ${readingProvider.hasCompletedToday ? "¡Racha activada!" : "Continuando..."}',
                ),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.celebration, color: Colors.orange, size: 28),
            SizedBox(width: 8),
            Text('¡Felicidades!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '¡Has completado el libro!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '"${_currentUserBook.book.title}"',
              style: const TextStyle(fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.local_fire_department,
                    color: Colors.orange.shade600,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Tu racha ha sido activada',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Cerrar diálogo
              Navigator.pop(context, true); // Volver al home con resultado
            },
            child: const Text('¡Genial!'),
          ),
        ],
      ),
    );
  }
}
