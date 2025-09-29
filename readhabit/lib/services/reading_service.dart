// lib/services/reading_service.dart - ACTUALIZADO CON PAUSA SEMANAL
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ReadingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> markDailyReading(String userId) async {
    try {
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final todayStart = DateTime.now().toUtc().copyWith(
        hour: 0,
        minute: 0,
        second: 0,
        millisecond: 0,
        microsecond: 0,
      );

      // Verificar si ya existe un registro para hoy
      final existingDoc = await _firestore
          .collection('daily_readings')
          .where('userId', isEqualTo: userId)
          .where('date', isEqualTo: today)
          .limit(1)
          .get();

      if (existingDoc.docs.isNotEmpty) {
        return false; // Ya existe un registro para hoy
      }

      // Crear registro de lectura diaria
      await _firestore.collection('daily_readings').add({
        'userId': userId,
        'date': today,
        'timestamp': FieldValue.serverTimestamp(),
        'createdAt': todayStart,
        'type': 'reading', // Diferencia entre lectura normal y pausa
      });

      // Actualizar racha del usuario
      await _updateUserStreak(userId);

      return true;
    } catch (e) {
      print('Error al marcar lectura diaria: $e');
      return false;
    }
  }

  Future<bool> markWeeklyPause(String userId) async {
    try {
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final todayStart = DateTime.now().toUtc().copyWith(
        hour: 0,
        minute: 0,
        second: 0,
        millisecond: 0,
        microsecond: 0,
      );

      // Verificar si ya existe un registro para hoy
      final existingDoc = await _firestore
          .collection('daily_readings')
          .where('userId', isEqualTo: userId)
          .where('date', isEqualTo: today)
          .limit(1)
          .get();

      if (existingDoc.docs.isNotEmpty) {
        return false; // Ya existe un registro para hoy
      }

      // Crear registro de pausa semanal
      await _firestore.collection('daily_readings').add({
        'userId': userId,
        'date': today,
        'timestamp': FieldValue.serverTimestamp(),
        'createdAt': todayStart,
        'type': 'weekly_pause', // Marca como pausa semanal
      });

      // Actualizar última fecha de lectura sin romper la racha
      await _updateUserStreakWithPause(userId);

      return true;
    } catch (e) {
      print('Error al marcar pausa semanal: $e');
      return false;
    }
  }

  Future<bool> hasCompletedToday(String userId) async {
    try {
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

      final doc = await _firestore
          .collection('daily_readings')
          .where('userId', isEqualTo: userId)
          .where('date', isEqualTo: today)
          .limit(1)
          .get();

      return doc.docs.isNotEmpty;
    } catch (e) {
      print('Error al verificar lectura del día: $e');
      return false;
    }
  }

  Future<void> _updateUserStreak(String userId) async {
    try {
      final userRef = _firestore.collection('users').doc(userId);

      // Obtener datos actuales del usuario
      final userDoc = await userRef.get();
      Map<String, dynamic> userData = {};

      if (userDoc.exists) {
        userData = userDoc.data()!;
      }

      int currentStreak = userData['currentStreak'] ?? 0;
      int longestStreak = userData['longestStreak'] ?? 0;
      String? lastReadingDate = userData['lastReadingDate'];

      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final yesterday = DateFormat(
        'yyyy-MM-dd',
      ).format(DateTime.now().subtract(const Duration(days: 1)));

      // Lógica de racha
      if (lastReadingDate == null || lastReadingDate == yesterday) {
        // Si no hay fecha anterior o leyó ayer, incrementar racha
        currentStreak++;
      } else if (lastReadingDate != today) {
        // Si no leyó ayer (y no es hoy), reiniciar racha
        currentStreak = 1;
      }
      // Si lastReadingDate == today, mantener la racha igual

      // Actualizar racha más larga si es necesario
      if (currentStreak > longestStreak) {
        longestStreak = currentStreak;
      }

      // Actualizar datos del usuario
      await userRef.set({
        'currentStreak': currentStreak,
        'longestStreak': longestStreak,
        'lastReadingDate': today,
        'weeklyPausesUsed': userData['weeklyPausesUsed'] ?? 0,
        'lastWeeklyPauseReset':
            userData['lastWeeklyPauseReset'] ??
            DateTime.now().toIso8601String(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error al actualizar racha: $e');
    }
  }

  Future<void> _updateUserStreakWithPause(String userId) async {
    try {
      final userRef = _firestore.collection('users').doc(userId);
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

      // Solo actualizar la fecha, mantener la racha intacta
      await userRef.update({
        'lastReadingDate': today,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error al actualizar fecha con pausa: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getBooksInProgress(String userId) async {
    try {
      final booksQuery = await _firestore
          .collection('user_books')
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'BookStatus.inProgress')
          .limit(5)
          .get();

      return booksQuery.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'book': data['book'] ?? {},
          'currentChapter': data['currentChapter'] ?? 0,
          'totalChapters': data['totalChapters'] ?? 0,
        };
      }).toList();
    } catch (e) {
      print('Error al cargar libros en progreso: $e');
      return [];
    }
  }

  // Método para obtener estadísticas de lectura del usuario
  Future<Map<String, dynamic>> getUserReadingStats(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();

      if (userDoc.exists) {
        final data = userDoc.data()!;
        return {
          'currentStreak': data['currentStreak'] ?? 0,
          'longestStreak': data['longestStreak'] ?? 0,
          'lastReadingDate': data['lastReadingDate'],
          'weeklyPausesUsed': data['weeklyPausesUsed'] ?? 0,
          'lastWeeklyPauseReset': data['lastWeeklyPauseReset'],
        };
      }

      return {
        'currentStreak': 0,
        'longestStreak': 0,
        'lastReadingDate': null,
        'weeklyPausesUsed': 0,
        'lastWeeklyPauseReset': null,
      };
    } catch (e) {
      print('Error al obtener estadísticas: $e');
      return {
        'currentStreak': 0,
        'longestStreak': 0,
        'lastReadingDate': null,
        'weeklyPausesUsed': 0,
        'lastWeeklyPauseReset': null,
      };
    }
  }

  // Método para obtener histórico de lecturas
  Future<List<Map<String, dynamic>>> getReadingHistory(
    String userId, {
    int limit = 30,
  }) async {
    try {
      final query = await _firestore
          .collection('daily_readings')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return query.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'date': data['date'],
          'type': data['type'] ?? 'reading',
          'timestamp': data['timestamp'],
          'createdAt': data['createdAt'],
        };
      }).toList();
    } catch (e) {
      print('Error al obtener histórico: $e');
      return [];
    }
  }
}
