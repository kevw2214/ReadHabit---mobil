// lib/screens/books/book_catalog_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:readhabit/models/user_book.dart';
import 'package:readhabit/screens/books/mybooks_screen.dart';
import 'package:readhabit/screens/books/reading_plan_screens.dart';
import 'package:readhabit/widgets/book_completed_card.dart';
import 'package:readhabit/widgets/book_progress_card.dart';
import '../../providers/book_provider.dart';
import '../../providers/user_library_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/book_category.dart';
import '../../models/book.dart';
import '../../widgets/book_catalog_card.dart';
import '../books/book_detail_screen.dart';

class BookCatalogScreen extends StatefulWidget {
  const BookCatalogScreen({super.key});

  @override
  State<BookCatalogScreen> createState() => _BookCatalogScreenState();
}

class _BookCatalogScreenState extends State<BookCatalogScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BookProvider>(
        context,
        listen: false,
      ).loadBooksByCategory(BookCategory.populares);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          // Barra de búsqueda
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar por título o autor...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        onPressed: _clearSearch,
                        icon: const Icon(Icons.clear),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
              ),
              onChanged: _onSearchChanged,
              onSubmitted: _onSearchSubmitted,
            ),
          ),

          // Filtros de categoría
          _buildCategoryFilters(),

          // Lista de libros
          Expanded(
            child: Consumer<BookProvider>(
              builder: (context, bookProvider, child) {
                if (bookProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (bookProvider.errorMessage != null) {
                  return _buildErrorState(bookProvider.errorMessage!);
                }

                final books = bookProvider.searchQuery.isNotEmpty
                    ? bookProvider.searchResults
                    : bookProvider.catalogBooks;

                if (books.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: books.length,
                  itemBuilder: (context, index) {
                    final book = books[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: BookCatalogCard(
                        book: book,
                        onTap: () => _navigateToBookDetail(book),
                        onAddToLibrary: () => _addBookToLibrary(book),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilters() {
    return Container(
      color: Colors.white,
      height: 50,
      child: Consumer<BookProvider>(
        builder: (context, bookProvider, child) {
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: BookCategory.values.length,
            itemBuilder: (context, index) {
              final category = BookCategory.values[index];
              final isSelected = bookProvider.selectedCategory == category;

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(category.displayName),
                  selected: isSelected,
                  onSelected: (_) {
                    _clearSearch();
                    bookProvider.setCategory(category);
                  },
                  selectedColor: const Color(0xFF1E90FF).withOpacity(0.2),
                  checkmarkColor: const Color(0xFF1E90FF),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No se encontraron libros',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Intenta con otros términos de búsqueda',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          const Text(
            'Error al cargar libros',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(error, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              final bookProvider = Provider.of<BookProvider>(
                context,
                listen: false,
              );
              bookProvider.clearError();
              bookProvider.loadBooksByCategory(bookProvider.selectedCategory);
            },
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  void _onSearchChanged(String value) {
    setState(() {});
  }

  void _onSearchSubmitted(String query) {
    if (query.trim().isNotEmpty) {
      Provider.of<BookProvider>(context, listen: false).searchBooks(query);
    }
  }

  void _clearSearch() {
    _searchController.clear();
    Provider.of<BookProvider>(context, listen: false).clearSearch();
    setState(() {});
  }

  void _navigateToBookDetail(Book book) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BookDetailScreen(book: book)),
    );
  }

  void _addBookToLibrary(Book book) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final libraryProvider = Provider.of<UserLibraryProvider>(
      context,
      listen: false,
    );

    if (authProvider.user != null) {
      _showAddToLibraryDialog(book);
    }
  }

  void _showAddToLibraryDialog(Book book) {
    int readingPlan = 1;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Configurar Plan de Lectura'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${book.title}\nPor ${book.author}'),
              const SizedBox(height: 16),
              Text('Total de capítulos: ${book.totalChapters ?? 15}'),
              const SizedBox(height: 16),
              const Text('Capítulos por día:'),
              Slider(
                value: readingPlan.toDouble(),
                min: 1,
                max: 5,
                divisions: 4,
                label: readingPlan.toString(),
                onChanged: (value) {
                  setState(() {
                    readingPlan = value.round();
                  });
                },
              ),
              Text(
                '$readingPlan capítulo${readingPlan > 1 ? 's' : ''} por día',
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
                await _confirmAddToLibrary(book, readingPlan);
              },
              child: const Text('Comenzar a Leer'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmAddToLibrary(Book book, int readingPlan) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final libraryProvider = Provider.of<UserLibraryProvider>(
      context,
      listen: false,
    );

    if (authProvider.user != null) {
      final success = await libraryProvider.addBookToLibrary(
        userId: authProvider.user!.uid,
        book: book,
        readingPlan: readingPlan,
      );

      if (mounted) {
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

@override
State<MyBooksScreen> createState() => _MyBooksScreenState();

class _MyBooksScreenState extends State<MyBooksScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadUserLibrary();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadUserLibrary() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final libraryProvider = Provider.of<UserLibraryProvider>(
      context,
      listen: false,
    );

    if (authProvider.user != null) {
      libraryProvider.loadUserLibrary(authProvider.user!.uid);
      libraryProvider.startListeningToUserBooks(authProvider.user!.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mis Libros',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              'Tu biblioteca y progreso',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Consumer<UserLibraryProvider>(
        builder: (context, libraryProvider, child) {
          if (libraryProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              // Estadísticas
              _buildStatisticsSection(libraryProvider),

              // Tabs
              Container(
                color: Colors.white,
                child: TabBar(
                  controller: _tabController,
                  labelColor: const Color(0xFF1E90FF),
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: const Color(0xFF1E90FF),
                  tabs: [
                    Tab(
                      text:
                          'En progreso (${libraryProvider.booksInProgress.length})',
                    ),
                    Tab(
                      text:
                          'Terminados (${libraryProvider.completedBooks.length})',
                    ),
                    const Tab(text: 'Catálogo'),
                  ],
                ),
              ),

              // Contenido de las tabs
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildInProgressTab(libraryProvider),
                    _buildCompletedTab(libraryProvider),
                    const BookCatalogScreen(),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatisticsSection(UserLibraryProvider libraryProvider) {
    final stats = libraryProvider.statistics;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Icons.auto_stories,
            count: stats?.booksInProgress ?? 0,
            label: 'En progreso',
            color: const Color(0xFF1E90FF),
          ),
          _buildStatItem(
            icon: Icons.check_circle,
            count: stats?.booksCompleted ?? 0,
            label: 'Completados',
            color: Colors.green,
          ),
          _buildStatItem(
            icon: Icons.trending_up,
            count: (stats?.averageProgress ?? 0).round(),
            label: 'Progreso\nprom.',
            color: Colors.orange,
            suffix: '%',
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required int count,
    required String label,
    required Color color,
    String suffix = '',
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          '$count$suffix',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildInProgressTab(UserLibraryProvider libraryProvider) {
    if (libraryProvider.booksInProgress.isEmpty) {
      return _buildEmptyState(
        icon: Icons.auto_stories,
        title: 'No tienes libros en progreso',
        subtitle: 'Explora nuestro catálogo y comienza a leer',
        buttonText: 'Ir al catálogo',
        onPressed: () => _tabController.animateTo(2),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: libraryProvider.booksInProgress.length,
      itemBuilder: (context, index) {
        final userBook = libraryProvider.booksInProgress[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: BookProgressCard(
            userBook: userBook,
            onContinueReading: () => _continueReading(userBook),
            onConfigurePlan: () => _configurePlan(userBook),
            onMoreOptions: () => _showMoreOptions(userBook),
          ),
        );
      },
    );
  }

  Widget _buildCompletedTab(UserLibraryProvider libraryProvider) {
    if (libraryProvider.completedBooks.isEmpty) {
      return _buildEmptyState(
        icon: Icons.check_circle_outline,
        title: 'Aún no has completado libros',
        subtitle: 'Completa tu primera lectura y aparecerá aquí',
        buttonText: 'Comenzar a leer',
        onPressed: () => _tabController.animateTo(2),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: libraryProvider.completedBooks.length,
      itemBuilder: (context, index) {
        final userBook = libraryProvider.completedBooks[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: BookCompletedCard(userBook: userBook),
        );
      },
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    required String buttonText,
    required VoidCallback onPressed,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: onPressed, child: Text(buttonText)),
          ],
        ),
      ),
    );
  }

  void _continueReading(UserBook userBook) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final libraryProvider = Provider.of<UserLibraryProvider>(
      context,
      listen: false,
    );

    if (authProvider.user != null) {
      libraryProvider.continueReading(
        userBookId: userBook.id,
        currentChapter: userBook.currentChapter,
        totalChapters: userBook.totalChapters,
        userId: authProvider.user!.uid,
      );
    }
  }

  void _configurePlan(UserBook userBook) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReadingPlanScreen(userBook: userBook),
      ),
    );
  }

  void _showMoreOptions(UserBook userBook) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _buildOptionsBottomSheet(userBook),
    );
  }

  Widget _buildOptionsBottomSheet(UserBook userBook) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Configurar plan de lectura'),
            onTap: () {
              Navigator.pop(context);
              _configurePlan(userBook);
            },
          ),
          ListTile(
            leading: const Icon(Icons.check),
            title: const Text('Marcar como completado'),
            onTap: () {
              Navigator.pop(context);
              _markAsCompleted(userBook);
            },
          ),
          ListTile(
            leading: const Icon(Icons.close, color: Colors.orange),
            title: const Text('Abandonar libro'),
            onTap: () {
              Navigator.pop(context);
              _abandonBook(userBook);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('Eliminar de biblioteca'),
            onTap: () {
              Navigator.pop(context);
              _removeBook(userBook);
            },
          ),
        ],
      ),
    );
  }

  void _markAsCompleted(UserBook userBook) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final libraryProvider = Provider.of<UserLibraryProvider>(
      context,
      listen: false,
    );

    if (authProvider.user != null) {
      libraryProvider.markBookAsCompleted(
        userBookId: userBook.id,
        userId: authProvider.user!.uid,
      );
    }
  }

  void _abandonBook(UserBook userBook) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final libraryProvider = Provider.of<UserLibraryProvider>(
      context,
      listen: false,
    );

    if (authProvider.user != null) {
      libraryProvider.abandonBook(
        userBookId: userBook.id,
        userId: authProvider.user!.uid,
      );
    }
  }

  void _removeBook(UserBook userBook) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final libraryProvider = Provider.of<UserLibraryProvider>(
      context,
      listen: false,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar libro'),
        content: Text(
          '¿Estás seguro de eliminar "${userBook.book.title}" de tu biblioteca?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (authProvider.user != null) {
                libraryProvider.removeBookFromLibrary(
                  userBookId: userBook.id,
                  userId: authProvider.user!.uid,
                );
              }
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
