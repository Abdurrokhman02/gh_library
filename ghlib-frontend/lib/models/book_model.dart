// lib/models/book_model.dart
class Book {
  // final int id;
  final String id;
  final String title;
  final String author;
  final String category;
  final String coverUrl;
  final String description;
  final bool isSaved; 

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.category,
    required this.coverUrl,
    this.description = 'Deskripsi buku ini masih kosong.',
    this.isSaved = false,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    // 1. Safe parsing ID: konversi apapun ke string dulu, lalu ke int.
    final String bookIdString = json['id']?.toString() ?? '0';
    
    // 2. Safe parsing isSaved: anggap tersimpan jika nilainya '1' atau 'true' (case-insensitive).
    final bool isBookSaved = (json['is_saved']?.toString().toLowerCase() == '1' || json['is_saved']?.toString().toLowerCase() == 'true');
    
    return Book(
      id: json['id'].toString(),
      title: json['title'] as String,
      author: json['author'] as String,
      category: json['category_name'] as String,
      coverUrl: json['cover_url'] as String,
      description: json['description'] as String,
      isSaved: isBookSaved, 
    );
  }

  Book copyWith({bool? isSaved}) {
    return Book(
      id: id,
      title: title,
      author: author,
      category: category,
      coverUrl: coverUrl,
      description: description,
      isSaved: isSaved ?? this.isSaved,
    );
  }
}