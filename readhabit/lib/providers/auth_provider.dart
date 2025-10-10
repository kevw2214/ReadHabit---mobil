// lib/providers/auth_provider.dart
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_manager.dart';

class AuthProvider with ChangeNotifier {
  final AuthManager _authManager = AuthManager.instance;

  // Getters
  User? get user => _authManager.currentUser;
  bool get isLoading => _authManager.isLoading;
  String? get errorMessage => _authManager.errorMessage;
  bool get isAuthenticated => _authManager.isAuthenticated;
  Stream<bool> get authStateChanges => _authManager.authStateChanges;

  // Constructor
  AuthProvider() {
    // El AuthManager ya está inicializado como singleton
    // Solo necesitamos escuchar sus cambios para notificar a los listeners de Flutter
    _authManager.userChanges.listen((_) {
      notifyListeners();
    });
  }

  // Iniciar sesión
  Future<bool> signIn(String email, String password) async {
    final result = await _authManager.signIn(email, password);
    notifyListeners();
    return result;
  }

  // Registrarse
  Future<bool> signUp(String name, String email, String password) async {
    final result = await _authManager.signUp(name, email, password);
    notifyListeners();
    return result;
  }

  // Cerrar sesión
  Future<bool> signOut() async {
    final result = await _authManager.signOut();
    notifyListeners();
    return result;
  }

  // Actualizar perfil del usuario
  Future<bool> updateUserProfile(String name, String email) async {
    final result = await _authManager.updateUserProfile(name, email);
    notifyListeners();
    return result;
  }

  // Limpiar error
  void clearError() {
    _authManager.clearError();
    notifyListeners();
  }

  @override
  void dispose() {
    // No necesitamos cerrar streams aquí ya que el AuthManager es singleton
    super.dispose();
  }
}
