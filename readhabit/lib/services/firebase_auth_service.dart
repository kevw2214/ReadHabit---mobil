import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseAuthService {
  static FirebaseAuthService? _instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Constructor privado para prevenir instancias múltiples
  FirebaseAuthService._internal();

  // Getter para obtener la instancia Singleton
  static FirebaseAuthService get instance {
    _instance ??= FirebaseAuthService._internal();
    return _instance!;
  }

  // Stream para escuchar cambios de estado de autenticación
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Obtener usuario actual
  User? get currentUser => _auth.currentUser;

  // Método para iniciar sesión
  Future<User?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Método para registrarse
  Future<User?> createUserWithEmailAndPassword(
    String name,
    String email,
    String password,
  ) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Crear documento del usuario en Firestore
      await _firestore.collection('users').doc(result.user!.uid).set({
        'name': name,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'streak': 0,
        'totalBooksRead': 0,
        'currentStreak': 0,
        'longestStreak': 0,
      });

      return result.user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Método para cerrar sesión
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Método para obtener estadísticas del usuario desde Firestore
  Future<Map<String, dynamic>> getUserStats(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(uid)
          .get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      } else {
        return {
          'currentStreak': 0,
          'longestStreak': 0,
          'totalBooksRead': 0,
          'totalChaptersRead': 0,
        };
      }
    } catch (e) {
      print('Error al obtener estadísticas del usuario: $e');
      return {
        'currentStreak': 0,
        'longestStreak': 0,
        'totalBooksRead': 0,
        'totalChaptersRead': 0,
      };
    }
  }

  // Método para manejar excepciones de autenticación
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No se encontró un usuario con este correo electrónico.';
      case 'wrong-password':
        return 'Contraseña incorrecta.';
      case 'email-already-in-use':
        return 'Ya existe una cuenta con este correo electrónico.';
      case 'weak-password':
        return 'La contraseña es demasiado débil.';
      case 'invalid-email':
        return 'El correo electrónico no es válido.';
      case 'user-disabled':
        return 'Esta cuenta ha sido deshabilitada.';
      case 'too-many-requests':
        return 'Demasiados intentos fallidos. Intente más tarde.';
      case 'operation-not-allowed':
        return 'Operación no permitida.';
      default:
        return 'Error de autenticación: ${e.message}';
    }
  }
}
