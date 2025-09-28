// lib/widgets/book_catalog_card.dart
import 'package:flutter/material.dart';
import '../models/book.dart';

class BookCatalogCard extends StatelessWidget {
  final Book book;
  final VoidCallback onTap;
  final VoidCallback onAddToLibrary;

  const BookCatalogCard({
    super.key,
    required this.book,
    required this.onTap,
    required this.onAddToLibrary,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Portada del libro
              Container(
                width: 60,
                height: 90,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: book.coverUrl != null
                      ? Image.network(
                          book.coverUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildDefaultCover(),
                        )
                      : _buildDefaultCover(),
                ),
              ),

              const SizedBox(width: 16),

              // Información del libro
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      book.author,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),

                    // Rating y año
                    Row(
                      children: [
                        if (book.rating != null) ...[
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                size: 16,
                                color: Colors.orange,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                book.rating!.toStringAsFixed(1),
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                          const SizedBox(width: 8),
                        ],
                        if (book.publishYear != null) ...[
                          Text(
                            book.publishYear.toString(),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Categoría
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E90FF).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        book.category,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF1E90FF),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Botón de agregar
              Column(
                children: [
                  IconButton(
                    onPressed: onAddToLibrary,
                    icon: const Icon(Icons.add),
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFF1E90FF),
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const Text(
                    'Leer',
                    style: TextStyle(fontSize: 12, color: Color(0xFF1E90FF)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultCover() {
    return Container(
      color: Colors.grey[300],
      child: const Icon(Icons.book, size: 30, color: Colors.grey),
    );
  }
}
