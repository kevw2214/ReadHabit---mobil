// lib/widgets/book_progress_card.dart CORREGIDO
import 'package:flutter/material.dart';
import '../models/user_book.dart';

class BookProgressCard extends StatelessWidget {
  final UserBook userBook;
  final VoidCallback onContinueReading;
  final VoidCallback onConfigurePlan;
  final VoidCallback onMoreOptions;

  const BookProgressCard({
    super.key,
    required this.userBook,
    required this.onContinueReading,
    required this.onConfigurePlan,
    required this.onMoreOptions,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado con título y menú
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userBook.book.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        userBook.book.author,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onMoreOptions,
                  icon: const Icon(Icons.more_vert),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Categoría
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF1E90FF).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                userBook.book.category,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF1E90FF),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Progreso de capítulos
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Cap. ${userBook.currentChapter}/${userBook.totalChapters}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${userBook.progressPercentage.round()}%',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Barra de progreso
            LinearProgressIndicator(
              value: userBook.progressPercentage / 100,
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF1E90FF),
              ),
              minHeight: 8,
            ),

            const SizedBox(height: 16),

            // Estadísticas de lectura
            Row(
              children: [
                Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Leyendo ${userBook.weeksReading} semanas',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(width: 16),
                Icon(Icons.trending_up, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Faltan ${userBook.estimatedDaysToFinish} días',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Botón de continuar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onContinueReading,
                child: Text('Continuar - Cap. ${userBook.currentChapter + 1}'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
