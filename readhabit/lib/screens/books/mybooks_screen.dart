// lib/screens/books/my_books_screen.dart COMPLETO
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:readhabit/screens/books/reading_plan_screens.dart';
import '../../providers/user_library_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_book.dart';
import '../../widgets/book_progress_card.dart';
import '../../widgets/book_completed_card.dart';
import 'book_catalog_screen.dart';

class MyBooksScreen extends StatefulWidget {
  const MyBooksScreen({super.key});

  @override
  State<MyBooksScreen> createState() => _MyBooksScreenState();
}

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

          if (libraryProvider.errorMessage != null) {
            return _buildErrorState(libraryProvider.errorMessage!);
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

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Error al cargar la biblioteca',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                _loadUserLibrary();
              },
              child: const Text('Reintentar'),
            ),
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
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            userBook.book.title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
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
          const SizedBox(height: 16),
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

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Marcar como completado'),
        content: Text(
          '¿Estás seguro de marcar "${userBook.book.title}" como completado?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              if (authProvider.user != null) {
                libraryProvider.markBookAsCompleted(
                  userBookId: userBook.id,
                  userId: authProvider.user!.uid,
                );
              }
            },
            child: const Text('Completar'),
          ),
        ],
      ),
    );
  }

  void _abandonBook(UserBook userBook) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final libraryProvider = Provider.of<UserLibraryProvider>(
      context,
      listen: false,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Abandonar libro'),
        content: Text(
          '¿Estás seguro de abandonar "${userBook.book.title}"? Podrás retomarlo más tarde.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              if (authProvider.user != null) {
                libraryProvider.abandonBook(
                  userBookId: userBook.id,
                  userId: authProvider.user!.uid,
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Abandonar'),
          ),
        ],
      ),
    );
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
          '¿Estás seguro de eliminar "${userBook.book.title}" de tu biblioteca? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              if (authProvider.user != null) {
                libraryProvider.removeBookFromLibrary(
                  userBookId: userBook.id,
                  userId: authProvider.user!.uid,
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
