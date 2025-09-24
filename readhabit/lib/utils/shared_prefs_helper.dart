import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsHelper {
  static const String _isLoggedInKey = 'isLoggedIn';
  static const String _userEmailKey = 'userEmail';
  static const String _userNameKey = 'userName';
  static const String _userIdKey = 'userId';

  // Guardar estado de login
  static Future<void> setLoggedIn(bool isLoggedIn) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, isLoggedIn);
  }

  // Obtener estado de login
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  // Guardar información del usuario
  static Future<void> saveUserInfo({
    required String userId,
    required String email,
    required String name,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, userId);
    await prefs.setString(_userEmailKey, email);
    await prefs.setString(_userNameKey, name);
  }

  // Obtener información del usuario
  static Future<Map<String, String?>> getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'userId': prefs.getString(_userIdKey),
      'email': prefs.getString(_userEmailKey),
      'name': prefs.getString(_userNameKey),
    };
  }

  // Limpiar toda la información guardada
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // Cerrar sesión
  static Future<void> logout() async {
    await setLoggedIn(false);
    await clearAll();
  }
}
