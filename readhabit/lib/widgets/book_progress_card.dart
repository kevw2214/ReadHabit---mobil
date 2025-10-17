import 'package:flutter/material.dart';
import '../models/user_book.dart';

class BookProgressCard extends StatelessWidget {
  final UserBook? userBook;
  final VoidCallback? onContinueReading;
  final VoidCallback? onConfigurePlan;
  final VoidCallback? onMoreOptions;

  final Map<String, dynamic>? bookData;
  final VoidCallback? onTap;

  const BookProgressCard({
    super.key,
    this.userBook,
    this.onContinueReading,
    this.onConfigurePlan,
    this.onMoreOptions,
    this.bookData,
    this.onTap,
  }) : assert(
         (userBook != null && bookData == null) ||
             (userBook == null && bookData != null),
         'Debe proporcionar userBook O bookData, pero no ambos',
       );

  @override
  Widget build(BuildContext context) {
    if (bookData != null) {
      return _buildSimpleCard(context);
    }

    if (userBook != null) {
      return _buildFullCard(context);
    }

    return const SizedBox.shrink();
  }

  Widget _buildSimpleCard(BuildContext context) {
    final book = bookData!['book'] ?? {};
    final currentChapter = bookData!['currentChapter'] ?? 0;
    final totalChapters = bookData!['totalChapters'] ?? 1;
    final progress = totalChapters > 0 ? (currentChapter / totalChapters) : 0.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 160,
              width: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey.shade200,
                image: book['coverUrl'] != null
                    ? DecorationImage(
                        image: NetworkImage(book['coverUrl']),
                        fit: BoxFit.cover,
                      )
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: book['coverUrl'] == null
                  ? Icon(Icons.book, size: 40, color: Colors.grey.shade400)
                  : null,
            ),
            const SizedBox(height: 8),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book['title'] ?? 'Sin título',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    book['author'] ?? 'Autor desconocido',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: progress,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E88E5),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),

                  Text(
                    '$currentChapter / $totalChapters',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFullCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userBook!.book.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        userBook!.book.author,
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

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF1E90FF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                userBook!.book.category,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF1E90FF),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Cap. ${userBook!.currentChapter}/${userBook!.totalChapters}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${userBook!.progressPercentage.round()}%',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),

            const SizedBox(height: 8),

            LinearProgressIndicator(
              value: userBook!.progressPercentage / 100,
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF1E90FF),
              ),
              minHeight: 8,
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Leyendo ${userBook!.weeksReading} semanas',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(width: 16),
                Icon(Icons.trending_up, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Faltan ${userBook!.estimatedDaysToFinish} días',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onContinueReading,
                child: Text('Continuar - Cap. ${userBook!.currentChapter + 1}'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
