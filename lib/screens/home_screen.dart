// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async'; 
import '../models/book_model.dart';
import '../providers/book_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer? _debounce; 
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BookProvider>(context, listen: false).fetchAllBooks();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel(); 
    super.dispose();
  }

  void _onSearchChanged(String query, BookProvider provider) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    provider.updateSearchQuery(query); 
    
    _debounce = Timer(const Duration(milliseconds: 500), () {
      provider.fetchAllBooks(); 
    });
  }

  @override
  Widget build(BuildContext context) {
    final bookProvider = Provider.of<BookProvider>(context);
    final books = bookProvider.allBooks;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Katalog Buku'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => bookProvider.fetchAllBooks(),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Input Pencarian
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cari Judul atau Penulis...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
              onChanged: (query) => _onSearchChanged(query, bookProvider),
            ),
          ),
          
          // Filter dan Sort
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                DropdownButton<String>(
                  value: bookProvider.selectedCategory,
                  items: bookProvider.availableCategories.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      bookProvider.updateCategoryFilter(newValue);
                    }
                  },
                ),
                DropdownButton<String>(
                  value: bookProvider.sortOptions.keys.firstWhere(
                    (k) => bookProvider.sortOptions[k] == bookProvider.selectedSort,
                    orElse: () => 'Terbaru',
                  ),
                  items: bookProvider.sortOptions.keys.map((String key) {
                    return DropdownMenuItem<String>(
                      value: key,
                      child: Text(key),
                    );
                  }).toList(),
                  onChanged: (String? newKey) {
                    if (newKey != null) {
                      bookProvider.updateSortOption(bookProvider.sortOptions[newKey]!);
                    }
                  },
                ),
              ],
            ),
          ),

          // Daftar Buku
          Expanded(
            child: bookProvider.isLoadingAll
                ? const Center(child: CircularProgressIndicator())
                : books.isEmpty
                    ? const Center(child: Text('Tidak ada buku ditemukan.'))
                    : ListView.builder(
                        itemCount: books.length,
                        itemBuilder: (context, index) {
                          final book = books[index];
                          return BookTile(
                            book: book,
                            onSaveToggle: () => bookProvider.toggleBookSaveStatus(book),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

// ... (BookTile widget remains the same)

// Komponen UI untuk daftar buku
class BookTile extends StatelessWidget {
  final Book book;
  final VoidCallback onSaveToggle;
  const BookTile({super.key, required this.book, required this.onSaveToggle});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Image.network(
        book.coverUrl,
        width: 50,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Icon(Icons.book, size: 50),
      ),
      title: Text(book.title),
      subtitle: Text('${book.author} - ${book.category}'),
      trailing: IconButton(
        icon: Icon(
          book.isSaved ? Icons.bookmark : Icons.bookmark_border,
          color: book.isSaved ? Colors.deepPurple : Colors.grey,
        ),
        onPressed: onSaveToggle,
      ),
      onTap: () {
        // Nanti bisa diarahkan ke detail buku
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Detail buku: ${book.title}')),
        );
      },
    );
  }
}