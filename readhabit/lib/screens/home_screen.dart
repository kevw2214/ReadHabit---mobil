import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_bottom_nav_bar.dart';
import '../models/user_models.dart';
import '../screens/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeTab(),
    const BooksTab(),
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

// Pantalla de Libros
class BooksTab extends StatelessWidget {
  const BooksTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Libros'),
        backgroundColor: const Color(0xFF1E88E5),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: const Center(
        child: Text(
          'Pantalla de Libros\n(Próximamente)',
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

// Pantalla de Perfil
// Pantalla de Perfil - VERSIÓN MEJORADA
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
      bio: 'Apasionado por la lectura', // Puedes hacer esto editable
      currentStreak: 7, // Estos datos deberían venir de tu base de datos
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
        // Aquí implementas la actualización en Firebase Firestore
        _updateUserInFirebase(context, updatedUser);
      },
      onUpdateSettings: (updatedSettings) {
        // Aquí guardas en SharedPreferences o Firebase
        _saveUserSettings(context, updatedSettings);
      },
      onLogout: () async {
        await authProvider.signOut();
      },
      onNavigate: (screen) {
        // Para navegar a otras pantallas si es necesario
        Navigator.pushNamed(context, '/$screen');
      },
    );
  }

  // Método para actualizar usuario en Firebase
  void _updateUserInFirebase(BuildContext context, AppUser updatedUser) {
    // TODO: Implementar actualización en Firestore
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Perfil actualizado: ${updatedUser.name}'),
        backgroundColor: Colors.green,
      ),
    );
    print('Usuario actualizado: $updatedUser');

    
  }

  // Método para guardar configuración
  void _saveUserSettings(BuildContext context, UserSettings settings) {
    // TODO: Implementar guardado en SharedPreferences o Firestore
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Configuración guardada'),
        backgroundColor: Colors.green,
      ),
    );
    print('Configuración guardada: $settings');

    
  }
}
