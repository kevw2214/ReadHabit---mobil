import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_auth_service.dart';
import '../utils/shared_prefs_helper.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuthService _authService = FirebaseAuthService.instance;

  User? _user;
  bool _isLoading = false;
  String? _errorMessage;
  final StreamController<bool> _authStateController =
      StreamController<bool>.broadcast();

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;
  Stream<bool> get authStateChanges => _authStateController.stream;

  AuthProvider() {
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    _isLoading = true;
    notifyListeners();

    try {
      bool wasLoggedIn = await SharedPrefsHelper.isLoggedIn();

      if (wasLoggedIn) {
        _authService.authStateChanges.listen((User? user) {
          _user = user;
          if (user != null) {
            _saveUserToPrefs(user);
            _notifyAuthStateChange(true);
          } else {
            _clearUserState();
            _notifyAuthStateChange(false);
          }
          _isLoading = false;
          notifyListeners();
        });
      } else {
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error al verificar autenticación: $e';
      notifyListeners();
    }
  }

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
        _notifyAuthStateChange(true);
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
        _notifyAuthStateChange(true);
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

  Future<bool> signOut({BuildContext? context}) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.signOut();

      await SharedPrefsHelper.logout();

      _clearUserState();

      _notifyAuthStateChange(false);

      _isLoading = false;
      notifyListeners();

      if (context != null) {
        Navigator.of(context).pushReplacementNamed('/welcome');
      }

      return true;
    } catch (e) {
      _errorMessage = 'Error al cerrar sesión: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateUserProfile(String name, String email) async {
    if (_user == null) {
      _errorMessage = 'Usuario no autenticado';
      notifyListeners();
      return false;
    }

    try {
      await _user!.updateDisplayName(name);
      if (email != _user!.email) {
        await _user!.updateEmail(email);
      }

      await _user!.reload();
      final updatedUser = _authService.currentUser;

      if (updatedUser != null) {
        _user = updatedUser;
        await _saveUserToPrefs(_user!);
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Error al recargar datos del usuario';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error al actualizar perfil: $e';
      notifyListeners();
      return false;
    }
  }

  void _clearUserState() {
    _user = null;
    _errorMessage = null;
  }

  void _notifyAuthStateChange(bool isAuthenticated) {
    if (!_authStateController.isClosed) {
      _authStateController.add(isAuthenticated);
    }
  }

  Future<void> refreshCurrentUser() async {
    if (_user != null) {
      await _user!.reload();
      _user = _authService.currentUser;
      notifyListeners();
    }
  }

  Future<void> _saveUserToPrefs(User user) async {
    await SharedPrefsHelper.saveUserInfo(
      userId: user.uid,
      email: user.email ?? '',
      name: user.displayName ?? '',
    );
  }

  @override
  void dispose() {
    _authStateController.close();
    super.dispose();
  }
}
