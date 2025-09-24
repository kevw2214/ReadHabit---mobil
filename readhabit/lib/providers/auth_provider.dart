import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_auth_service.dart';
import '../utils/shared_prefs_helper.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuthService _authService = FirebaseAuthService();

  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  // Constructor
  AuthProvider() {
    _checkAuthState();
  }

  // Verificar estado de autenticación al iniciar
  Future<void> _checkAuthState() async {
    _isLoading = true;
    notifyListeners();

    // Verificar si el usuario ya estaba logueado
    bool wasLoggedIn = await SharedPrefsHelper.isLoggedIn();

    if (wasLoggedIn) {
      // Escuchar cambios en el estado de autenticación
      _authService.authStateChanges.listen((User? user) {
        _user = user;
        if (user != null) {
          _saveUserToPrefs(user);
        }
        _isLoading = false;
        notifyListeners();
      });
    } else {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Iniciar sesión
  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      User? user = await _authService.signInWithEmailAndPassword(
        email,
        password,
      );

      if (user != null) {
        _user = user;
        await _saveUserToPrefs(user);
        await SharedPrefsHelper.setLoggedIn(true);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Error al iniciar sesión';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Registrarse
  Future<bool> signUp(String name, String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      User? user = await _authService.createUserWithEmailAndPassword(
        name,
        email,
        password,
      );

      if (user != null) {
        _user = user;
        await _saveUserToPrefs(user);
        await SharedPrefsHelper.setLoggedIn(true);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Error al registrarse';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Cerrar sesión
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.signOut();
      await SharedPrefsHelper.logout();
      _user = null;
      _errorMessage = null;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error al cerrar sesión';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Limpiar error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Guardar información del usuario en SharedPreferences
  Future<void> _saveUserToPrefs(User user) async {
    await SharedPrefsHelper.saveUserInfo(
      userId: user.uid,
      email: user.email ?? '',
      name: user.displayName ?? '',
    );
  }
}
