// lib/services/user_book_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_book.dart';
import '../models/book.dart';
import '../models/reading_statistics.dart';

class UserBookService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'user_books';

  // Agregar libro a la biblioteca del usuario
  Future<void> addBookToLibrary({
    required String userId,
    required Book book,
    required int readingPlan,
  }) async {
    try {
      final userBook = UserBook(
        id: '', // Se generará automáticamente
        userId: userId,
        bookId: book.id,
        book: book,
        status: BookStatus.inProgress,
        currentChapter: 0,
        totalChapters: book.totalChapters ?? 15,
        startDate: DateTime.now(),
        lastReadDate: DateTime.now(),
        readingPlan: readingPlan,
      );

      await _firestore.collection(_collection).add(userBook.toFirestore());
    } catch (e) {
      throw Exception('Error al agregar libro: $e');
    }
  }

  // Obtener libros del usuario por estado
  Future<List<UserBook>> getUserBooks(
    String userId, {
    BookStatus? status,
  }) async {
    try {
      Query query = _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId);

      if (status != null) {
        query = query.where('status', isEqualTo: status.toString());
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map(
            (doc) => UserBook.fromFirestore(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ),
          )
          .toList();
    } catch (e) {
      throw Exception('Error al obtener libros del usuario: $e');
    }
  }

  // Obtener libros en progreso
  Future<List<UserBook>> getBooksInProgress(String userId) async {
    return getUserBooks(userId, status: BookStatus.inProgress);
  }

  // Obtener libros completados
  Future<List<UserBook>> getCompletedBooks(String userId) async {
    return getUserBooks(userId, status: BookStatus.completed);
  }

  // Actualizar progreso de lectura
  Future<void> updateReadingProgress({
    required String userBookId,
    required int newChapter,
  }) async {
    try {
      final updates = <String, dynamic>{
        'currentChapter': newChapter,
        'lastReadDate': DateTime.now().toIso8601String(),
      };

      await _firestore.collection(_collection).doc(userBookId).update(updates);
    } catch (e) {
      throw Exception('Error al actualizar progreso: $e');
    }
  }

  // Marcar libro como completado
  Future<void> markBookAsCompleted(String userBookId) async {
    try {
      final updates = <String, dynamic>{
        'status': BookStatus.completed.toString(),
        'completedDate': DateTime.now().toIso8601String(),
        'lastReadDate': DateTime.now().toIso8601String(),
      };

      await _firestore.collection(_collection).doc(userBookId).update(updates);
    } catch (e) {
      throw Exception('Error al marcar libro como completado: $e');
    }
  }

  // Abandonar libro
  Future<void> abandonBook(String userBookId) async {
    try {
      final updates = <String, dynamic>{
        'status': BookStatus.abandoned.toString(),
        'lastReadDate': DateTime.now().toIso8601String(),
      };

      await _firestore.collection(_collection).doc(userBookId).update(updates);
    } catch (e) {
      throw Exception('Error al abandonar libro: $e');
    }
  }

  // Eliminar libro de la biblioteca
  Future<void> removeBookFromLibrary(String userBookId) async {
    try {
      await _firestore.collection(_collection).doc(userBookId).delete();
    } catch (e) {
      throw Exception('Error al eliminar libro: $e');
    }
  }

  // Obtener estadísticas de lectura
  Future<ReadingStatistics> getReadingStatistics(String userId) async {
    try {
      final userBooks = await getUserBooks(userId);
      return ReadingStatistics.fromUserBooks(userBooks);
    } catch (e) {
      throw Exception('Error al obtener estadísticas: $e');
    }
  }

  // Verificar si el usuario ya tiene el libro
  Future<bool> userHasBook(String userId, String bookId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('bookId', isEqualTo: bookId)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      throw Exception('Error al verificar libro: $e');
    }
  }

  // Actualizar plan de lectura
  Future<void> updateReadingPlan(String userBookId, int chaptersPerDay) async {
    try {
      await _firestore.collection(_collection).doc(userBookId).update({
        'readingPlan': chaptersPerDay,
      });
    } catch (e) {
      throw Exception('Error al actualizar plan de lectura: $e');
    }
  }

  // Stream para escuchar cambios en tiempo real
  Stream<List<UserBook>> getUserBooksStream(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => UserBook.fromFirestore(doc.data(), doc.id))
              .toList(),
        );
  }
}
