// lib/screens/home_screen.dart - MODIFICADO con navegación a lectura
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:readhabit/screens/books/mybooks_screen.dart';
import 'package:readhabit/screens/books/reading_screen.dart';
import '../providers/auth_provider.dart';
import '../providers/reading_provider.dart';
import '../providers/user_library_provider.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../models/user_models.dart';
import '../models/user_book.dart';
import '../screens/auth/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeTab(),
    const MyBooksScreen(),
    const CalendarTab(),
    const ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.user == null) {
          return Scaffold(
            body: const Center(
              child: Text('Debes iniciar sesión para usar la app'),
            ),
            bottomNavigationBar: CustomBottomNavBar(
              currentIndex: _currentIndex,
              onTap: (index) {},
            ),
          );
        }

        return MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (context) => ReadingProvider(authProvider.user!.uid),
            ),
            ChangeNotifierProvider(create: (context) => UserLibraryProvider()),
          ],
          child: Scaffold(
            body: _screens[_currentIndex],
            bottomNavigationBar: CustomBottomNavBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
          ),
        );
      },
    );
  }
}

// Pantalla de Inicio - CON NAVEGACIÓN A LECTURA
class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user != null) {
      final libraryProvider = Provider.of<UserLibraryProvider>(
        context,
        listen: false,
      );
      libraryProvider.loadUserLibrary(authProvider.user!.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.user == null) {
          return const Scaffold(
            body: Center(
              child: Text('Debes iniciar sesión para ver el contenido'),
            ),
          );
        }

        return Consumer2<ReadingProvider, UserLibraryProvider>(
          builder: (context, readingProvider, libraryProvider, child) {
            return Scaffold(
              backgroundColor: Colors.white,
              body: SafeArea(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header con título y racha
                        _buildHeader(
                          authProvider.user!.displayName ?? 'Usuario',
                          readingProvider.currentStreak,
                        ),

                        const SizedBox(height: 20),

                        // Saludo y motivación
                        _buildGreetingSection(),

                        const SizedBox(height: 16),

                        // Frase motivacional
                        _buildMotivationalQuote(),

                        const SizedBox(height: 24),

                        // Sección de lectura de hoy
                        _buildTodayReadingSection(
                          libraryProvider,
                          readingProvider,
                        ),

                        const SizedBox(height: 24),

                        // Pausa semanal (si aplica)
                        if (!readingProvider.hasCompletedToday)
                          _buildWeeklyPauseSection(),
                        if (!readingProvider.hasCompletedToday)
                          const SizedBox(height: 24),

                        // Libros en progreso
                        _buildBooksInProgressSection(libraryProvider),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHeader(String userName, int streak) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'ReadHabit',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.orange.shade100,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.local_fire_department,
                color: Colors.orange.shade600,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                '$streak',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGreetingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hola, Usuario ¡Continuemos con tu hábito!',
          style: TextStyle(
            fontSize: 18,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildMotivationalQuote() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Text(
        '"La lectura es el ejercicio de la mente."',
        style: TextStyle(
          fontSize: 16,
          color: Colors.grey.shade600,
          fontStyle: FontStyle.italic,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTodayReadingSection(
    UserLibraryProvider libraryProvider,
    ReadingProvider readingProvider,
  ) {
    // Obtener el primer libro en progreso si existe
    final firstBook = libraryProvider.booksInProgress.isNotEmpty
        ? libraryProvider.booksInProgress.first
        : null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: readingProvider.hasCompletedToday
            ? Colors.green.shade50
            : Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: readingProvider.hasCompletedToday
              ? Colors.green.shade100
              : Colors.blue.shade100,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                readingProvider.hasCompletedToday
                    ? Icons.check_circle
                    : Icons.calendar_today,
                color: readingProvider.hasCompletedToday
                    ? Colors.green.shade600
                    : Colors.blue.shade600,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                readingProvider.hasCompletedToday
                    ? 'Lectura completada hoy'
                    : 'Lectura de hoy',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: readingProvider.hasCompletedToday
                      ? Colors.green.shade800
                      : Colors.blue.shade800,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          if (readingProvider.hasCompletedToday) ...[
            // Estado completado
            Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.green.shade600,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '¡Excelente! Ya completaste tu lectura de hoy y mantuviste tu racha.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ] else if (firstBook != null) ...[
            // Información del libro para leer
            Text(
              firstBook.book.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              firstBook.book.author,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 12),

            // Progreso del capítulo
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Capítulo ${firstBook.currentChapter + 1} de ${firstBook.totalChapters}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                GestureDetector(
                  onTap: () => _navigateToReading(firstBook),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade600,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.menu_book, color: Colors.white, size: 16),
                        SizedBox(width: 4),
                        Text(
                          'Leer ahora',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            // Estado sin libros
            Column(
              children: [
                Icon(
                  Icons.book_outlined,
                  size: 48,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 12),
                Text(
                  'No tienes libros en progreso',
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    // Navegar a la sección de libros (tab index 1)
                    _navigateToBooks();
                  },
                  child: const Text('Agregar libro'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWeeklyPauseSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.pause, color: Colors.orange.shade600, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pausa semanal disponible',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.orange.shade800,
                  ),
                ),
                Text(
                  'Puedes pausar tu racha hoy sin perderla',
                  style: TextStyle(fontSize: 12, color: Colors.orange.shade600),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: _useWeeklyPause,
            style: TextButton.styleFrom(
              backgroundColor: Colors.orange.shade100,
              foregroundColor: Colors.orange.shade700,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            ),
            child: const Text(
              'Pausar',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBooksInProgressSection(UserLibraryProvider libraryProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Libros en progreso',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),

        if (libraryProvider.booksInProgress.isEmpty)
          _buildEmptyBooksState()
        else
          _buildBooksGrid(libraryProvider.booksInProgress),
      ],
    );
  }

  Widget _buildEmptyBooksState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.book_outlined, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            'No tienes libros en progreso',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Agrega un libro desde la biblioteca para empezar',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBooksGrid(List<UserBook> books) {
    return Column(
      children: books
          .map((userBook) => _buildBookProgressItem(userBook))
          .toList(),
    );
  }

  Widget _buildBookProgressItem(UserBook userBook) {
    final progressPercentage = userBook.progressPercentage.round();

    return GestureDetector(
      onTap: () => _navigateToReading(userBook),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userBook.book.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userBook.book.author,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Capítulo ${userBook.currentChapter + 1} de ${userBook.totalChapters}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    userBook.book.category,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$progressPercentage%',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Navegación a la pantalla de lectura
  void _navigateToReading(UserBook userBook) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReadingScreen(userBook: userBook),
      ),
    );

    // Si se completó una lectura, recargar los datos
    if (result == true) {
      _loadData();
      // Recargar el ReadingProvider también
      final readingProvider = Provider.of<ReadingProvider>(
        context,
        listen: false,
      );
      readingProvider.refreshData();
    }
  }

  void _navigateToBooks() {
    // Cambiar al tab de libros (index 1)
    if (mounted) {
      final homeState = context.findAncestorStateOfType<_HomeScreenState>();
      homeState?.setState(() {
        homeState._currentIndex = 1;
      });
    }
  }

  void _useWeeklyPause() async {
    final readingProvider = Provider.of<ReadingProvider>(
      context,
      listen: false,
    );
    final success = await readingProvider.useWeeklyPause();

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pausa semanal aplicada. Tu racha se mantiene.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }
}

// Las demás clases permanecen igual...
class CalendarTab extends StatelessWidget {
  const CalendarTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendario'),
        backgroundColor: const Color(0xFF1E88E5),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: const Center(
        child: Text(
          'Pantalla de Calendario\n(Próximamente)',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      ),
    );
  }
}

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    final user = AppUser(
      uid: authProvider.user?.uid ?? '',
      name: authProvider.user?.displayName ?? 'Usuario',
      email: authProvider.user?.email ?? '',
      bio: 'Apasionado por la lectura',
      currentStreak: 7,
      longestStreak: 15,
      totalBooksCompleted: 3,
      totalChaptersRead: 45,
      joinDate: authProvider.user?.metadata.creationTime ?? DateTime.now(),
    );

    final settings = UserSettings();

    return ProfileScreen(
      user: user,
      settings: settings,
      onUpdateUser: (updatedUser) {},
      onUpdateSettings: (updatedSettings) {},
      onLogout: () async {},
      onNavigate: (screen) {
        Navigator.pushNamed(context, '/$screen');
      },
    );
  }
}
