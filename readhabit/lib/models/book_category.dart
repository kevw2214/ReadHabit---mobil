// lib/models/book_category.dart
enum BookCategory {
  populares('Populares'),
  ficcion('Ficción'),
  ciencia('Ciencia'),
  historia('Historia'),
  filosofia('Filosofía'),
  biografia('Biografía'),
  arte('Arte'),
  religion('Religión');

  const BookCategory(this.displayName);
  final String displayName;

  static BookCategory fromString(String value) {
    return BookCategory.values.firstWhere(
      (category) => category.name.toLowerCase() == value.toLowerCase(),
      orElse: () => BookCategory.populares,
    );
  }
}
