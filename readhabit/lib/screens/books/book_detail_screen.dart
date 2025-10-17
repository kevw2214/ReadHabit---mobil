import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/book.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_library_provider.dart';

class BookDetailScreen extends StatefulWidget {
  final Book book;

  const BookDetailScreen({super.key, required this.book});

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  bool _userHasBook = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkIfUserHasBook();
  }

  Future<void> _checkIfUserHasBook() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final libraryProvider = Provider.of<UserLibraryProvider>(
      context,
      listen: false,
    );

    if (authProvider.user != null) {
      final hasBook = await libraryProvider.userHasBook(
        authProvider.user!.uid,
        widget.book.id,
      );

      if (mounted) {
        setState(() {
          _userHasBook = hasBook;
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(child: _buildBookInfo()),
        ],
      ),
      bottomNavigationBar: _buildActionButton(),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: const Color(0xFF1E90FF),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF1E90FF), Color(0xFF4169E1)],
            ),
          ),
          child: Center(
            child: Hero(
              tag: 'book_cover_${widget.book.id}',
              child: Container(
                width: 120,
                height: 180,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: widget.book.coverUrl != null
                      ? Image.network(
                          widget.book.coverUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildDefaultCover(),
                        )
                      : _buildDefaultCover(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultCover() {
    return Container(
      color: Colors.grey[300],
      child: const Icon(Icons.book, size: 50, color: Colors.grey),
    );
  }

  Widget _buildBookInfo() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.book.title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            widget.book.author,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 16),

          Wrap(
            spacing: 16,
            children: [
              if (widget.book.publishYear != null)
                _buildInfoChip(
                  icon: Icons.calendar_today,
                  label: widget.book.publishYear.toString(),
                ),
              if (widget.book.rating != null)
                _buildInfoChip(
                  icon: Icons.star,
                  label: widget.book.rating!.toStringAsFixed(1),
                ),
              _buildInfoChip(icon: Icons.category, label: widget.book.category),
              if (widget.book.totalChapters != null)
                _buildInfoChip(
                  icon: Icons.auto_stories,
                  label: '${widget.book.totalChapters} caps.',
                ),
            ],
          ),

          const SizedBox(height: 24),

          if (widget.book.description != null) ...[
            const Text(
              'Sinopsis',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              widget.book.description!,
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.grey),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'No hay sinopsis disponible para este libro.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoChip({required IconData icon, required String label}) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      backgroundColor: const Color(0xFF1E90FF).withValues(alpha: 0.1),
    );
  }

  Widget _buildActionButton() {
    if (_isLoading) {
      return Container(
        height: 80,
        color: Colors.white,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _userHasBook ? null : _showAddToLibraryDialog,
          style: ElevatedButton.styleFrom(
            backgroundColor: _userHasBook
                ? Colors.grey
                : const Color(0xFF1E90FF),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: Text(
            _userHasBook ? 'Ya tienes este libro' : 'Agregar a mi biblioteca',
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }

  void _showAddToLibraryDialog() {
    int readingPlan = 1;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Configurar Plan de Lectura'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('¿Cuántos capítulos quieres leer por día?'),
              const SizedBox(height: 16),
              Text('Total de capítulos: ${widget.book.totalChapters ?? 15}'),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Capítulos por día: '),
                  Text(
                    readingPlan.toString(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E90FF),
                    ),
                  ),
                ],
              ),
              Slider(
                value: readingPlan.toDouble(),
                min: 1,
                max: 5,
                divisions: 4,
                label: readingPlan.toString(),
                activeColor: const Color(0xFF1E90FF),
                onChanged: (value) {
                  setState(() {
                    readingPlan = value.round();
                  });
                },
              ),
              Text(
                'Terminarás en aproximadamente ${((widget.book.totalChapters ?? 15) / readingPlan).ceil()} días',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await _addBookToLibrary(readingPlan);
              },
              child: const Text('Comenzar a Leer'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addBookToLibrary(int readingPlan) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final libraryProvider = Provider.of<UserLibraryProvider>(
      context,
      listen: false,
    );

    if (authProvider.user != null) {
      final success = await libraryProvider.addBookToLibrary(
        userId: authProvider.user!.uid,
        book: widget.book,
        readingPlan: readingPlan,
      );

      if (mounted) {
        setState(() {
          _userHasBook = success;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? '¡Libro agregado a tu biblioteca!'
                  : libraryProvider.errorMessage ?? 'Error al agregar libro',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }
}
