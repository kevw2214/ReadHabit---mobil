// main.dart actualizado CON API KEY
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:readhabit/screens/home_screen.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/book_provider.dart';
import 'providers/user_library_provider.dart';
import 'providers/reading_provider.dart';
import 'providers/question_provider.dart';
import 'services/question_service.dart';
import 'utils/app_routes.dart';
import 'utils/shared_prefs_helper.dart';
import 'screens/auth/welcome_screen.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initializeDateFormatting('es_ES');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => BookProvider()),
        ChangeNotifierProvider(create: (_) => UserLibraryProvider()),
        
        // ReadingProvider con userId dinámico
        ChangeNotifierProxyProvider<AuthProvider, ReadingProvider>(
          create: (context) => ReadingProvider(''),
          update: (context, authProvider, readingProvider) {
            final userId = authProvider.user?.uid ?? '';
            if (readingProvider == null || readingProvider.userId != userId) {
              return ReadingProvider(userId);
            }
            return readingProvider;
          },
        ),
        
        //ACTUALIZADO: QuestionProvider CON API KEY
        ChangeNotifierProvider(
          create: (_) => QuestionProvider(
            QuestionService('--Api Key--'),
          ),
        ),
      ],
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

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool? _isLoggedIn;
  StreamSubscription<bool>? _authSubscription;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _listenToAuthChanges();
    });
  }

  void _listenToAuthChanges() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _authSubscription = authProvider.authStateChanges.listen((
      bool isAuthenticated,
    ) {
      if (mounted) {
        setState(() {
          _isLoggedIn = isAuthenticated;
        });

        if (!isAuthenticated) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && Navigator.canPop(context)) {
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil('/welcome', (route) => false);
            }
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  Future<void> _checkLoginStatus() async {
    try {
      bool loggedIn = await SharedPrefsHelper.isLoggedIn();
      if (mounted) {
        setState(() {
          _isLoggedIn = loggedIn;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoggedIn = false;
        });
      }
    }
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
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/$screen');
    }
  }
}