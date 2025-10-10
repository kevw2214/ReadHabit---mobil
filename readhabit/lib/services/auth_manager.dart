// lib/services/auth_manager.dart
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_auth_service.dart';
import '../utils/shared_prefs_helper.dart';

/// Singleton para manejar toda la lógica de autenticación de la aplicación
class AuthManager {
  static AuthManager? _instance;
  static AuthManager get instance {
    _instance ??= AuthManager._internal();
    return _instance!;
  }

  final FirebaseAuthService _authService = FirebaseAuthService();

  // Estado de autenticación
  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  // Stream controllers para notificar cambios de estado
  final StreamController<User?> _userController = StreamController<User?>.broadcast();
  final StreamController<bool> _authStateController = StreamController<bool>.broadcast();

  // Getters
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  // Streams
  Stream<User?> get userChanges => _userController.stream;
  Stream<bool> get authStateChanges => _authStateController.stream;

  // Constructor privado para singleton
  AuthManager._internal() {
    _initializeAuth();
  }

  /// Inicializar la autenticación y escuchar cambios de estado
  Future<void> _initializeAuth() async {
    _isLoading = true;

    try {
      // Verificar si el usuario ya estaba logueado
      bool wasLoggedIn = await SharedPrefsHelper.isLoggedIn();

      if (wasLoggedIn) {
        // Escuchar cambios en el estado de autenticación de Firebase
        _authService.authStateChanges.listen((User? user) {
          _currentUser = user;

          if (user != null) {
            _saveUserToPrefs(user);
            _notifyAuthStateChange(true);
          } else {
            _clearUserState();
            _notifyAuthStateChange(false);
          }

          _userController.add(user);
          _isLoading = false;
        });
      } else {
        _isLoading = false;
        _userController.add(null);
        _notifyAuthStateChange(false);
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error al inicializar autenticación: $e';
      _userController.add(null);
      _notifyAuthStateChange(false);
    }
  }

  /// Iniciar sesión con email y contraseña
  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;

    try {
      User? user = await _authService.signInWithEmailAndPassword(email, password);

      if (user != null) {
        _currentUser = user;
        await _saveUserToPrefs(user);
        await SharedPrefsHelper.setLoggedIn(true);
        _notifyAuthStateChange(true);
        _userController.add(user);
        _isLoading = false;
        return true;
      } else {
        _errorMessage = 'Error al iniciar sesión';
        _isLoading = false;
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      return false;
    }
  }

  /// Registrarse con nombre, email y contraseña
  Future<bool> signUp(String name, String email, String password) async {
    _isLoading = true;
    _errorMessage = null;

    try {
      User? user = await _authService.createUserWithEmailAndPassword(name, email, password);

      if (user != null) {
        _currentUser = user;
        await _saveUserToPrefs(user);
        await SharedPrefsHelper.setLoggedIn(true);
        _notifyAuthStateChange(true);
        _userController.add(user);
        _isLoading = false;
        return true;
      } else {
        _errorMessage = 'Error al registrarse';
        _isLoading = false;
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      return false;
    }
  }

  /// Cerrar sesión
  Future<bool> signOut() async {
    _isLoading = true;

    try {
      // Cerrar sesión en Firebase
      await _authService.signOut();

      // Limpiar SharedPreferences
      await SharedPrefsHelper.logout();

      // Limpiar estado local
      _clearUserState();

      // Notificar cambios
      _notifyAuthStateChange(false);
      _userController.add(null);

      _isLoading = false;
      return true;
    } catch (e) {
      _errorMessage = 'Error al cerrar sesión: $e';
      _isLoading = false;
      return false;
    }
  }

  /// Actualizar perfil del usuario
  Future<bool> updateUserProfile(String name, String email) async {
    if (_currentUser == null) {
      _errorMessage = 'Usuario no autenticado';
      return false;
    }

    try {
      // Actualizar en Firebase Auth
      await _currentUser!.updateDisplayName(name);
      if (email != _currentUser!.email) {
        await _currentUser!.updateEmail(email);
      }

      // Recargar datos del usuario
      await _currentUser!.reload();
      final updatedUser = _authService.currentUser;

      if (updatedUser != null) {
        _currentUser = updatedUser;
        await _saveUserToPrefs(_currentUser!);
        _userController.add(_currentUser);
        return true;
      } else {
        _errorMessage = 'Error al recargar datos del usuario';
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error al actualizar perfil: $e';
      return false;
    }
  }

  /// Limpiar el estado del usuario
  void _clearUserState() {
    _currentUser = null;
    _errorMessage = null;
  }

  /// Notificar cambios en el estado de autenticación
  void _notifyAuthStateChange(bool isAuthenticated) {
    if (!_authStateController.isClosed) {
      _authStateController.add(isAuthenticated);
    }
  }

  /// Guardar información del usuario en SharedPreferences
  Future<void> _saveUserToPrefs(User user) async {
    await SharedPrefsHelper.saveUserInfo(
      userId: user.uid,
      email: user.email ?? '',
      name: user.displayName ?? '',
    );
  }

  /// Limpiar error
  void clearError() {
    _errorMessage = null;
  }

  /// Cerrar streams cuando ya no se necesiten
  void dispose() {
    _userController.close();
    _authStateController.close();
  }
}
