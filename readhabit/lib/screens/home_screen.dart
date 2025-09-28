// lib/screens/home_screen.dart actualizado
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:readhabit/screens/books/mybooks_screen.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../models/user_models.dart';
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
    const MyBooksScreen(), // Reemplazamos BooksTab con MyBooksScreen
    const CalendarTab(),
    const ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

// Pantalla de Inicio
class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
        backgroundColor: const Color(0xFF1E88E5),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: const Center(
        child: Text(
          'Pantalla de Inicio\n(Próximamente)',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      ),
    );
  }
}

// Pantalla de Calendario
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

    // Crear usuario desde Firebase Auth
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
      onUpdateUser: (updatedUser) {
        _updateUserInFirebase(context, updatedUser);
      },
      onUpdateSettings: (updatedSettings) {
        _saveUserSettings(context, updatedSettings);
      },
      onLogout: () async {
        _showLogoutConfirmation(context, authProvider);
      },
      onNavigate: (screen) {
        Navigator.pushNamed(context, '/$screen');
      },
    );
  }

  void _showLogoutConfirmation(
    BuildContext context,
    AuthProvider authProvider,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Cerrar sesión'),
          content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop(); // Cerrar diálogo

                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (loadingContext) =>
                      const Center(child: CircularProgressIndicator()),
                );

                // Realizar logout
                bool success = await authProvider.signOut();

                if (context.mounted) {
                  // Cerrar indicador de carga
                  Navigator.of(context).pop();

                  if (!success) {
                    // Mostrar error si el logout falló
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          authProvider.errorMessage ?? 'Error al cerrar sesión',
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text(
                'Cerrar sesión',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _updateUserInFirebase(BuildContext context, AppUser updatedUser) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Perfil actualizado: ${updatedUser.name}'),
        backgroundColor: Colors.green,
      ),
    );
    debugPrint('Usuario actualizado: $updatedUser');
  }

  void _saveUserSettings(BuildContext context, UserSettings settings) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Configuración guardada'),
        backgroundColor: Colors.green,
      ),
    );
    debugPrint('Configuración guardada: $settings');
  }
}
