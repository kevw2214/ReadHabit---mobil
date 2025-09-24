import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:readhabit/screens/home_screen.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'utils/app_routes.dart';
import 'utils/shared_prefs_helper.dart';
import 'screens/auth/welcome_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AuthProvider())],
      child: MaterialApp(
        title: 'ReadHabit',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: const Color(0xFF1E90FF),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1E90FF),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF1E90FF)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            filled: true,
            fillColor: const Color(0xFFF5F5F5),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E90FF),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF1E90FF), width: 2),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          fontFamily: 'Poppins',
        ),
        initialRoute: '/',
        onGenerateRoute: AppRoutes.generateRoute,
        home: const AuthWrapper(),
      ),
    );
  }
}

// Widget que decide qué pantalla mostrar basado en el estado de autenticación
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool? _isLoggedIn;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    bool loggedIn = await SharedPrefsHelper.isLoggedIn();
    setState(() {
      _isLoggedIn = loggedIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoggedIn == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF1E90FF)),
        ),
      );
    }

    return _isLoggedIn!
        ? const HomeScreen()
        : WelcomeScreen(onNavigate: _handleNavigation);
  }

  void _handleNavigation(String screen) {
    Navigator.pushReplacementNamed(context, '/$screen');
  }
}
