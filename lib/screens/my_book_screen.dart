// lib/screens/my_book_screen.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/book_provider.dart';
import 'home_screen.dart';

class MyBookScreen extends StatefulWidget {
  const MyBookScreen({super.key});

  @override
  State<MyBookScreen> createState() => _MyBookScreenState();
}

class _MyBookScreenState extends State<MyBookScreen> {
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BookProvider>(context, listen: false).fetchMyBooks();
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
      provider.fetchMyBooks();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bookProvider = Provider.of<BookProvider>(context);
    final myBooks = bookProvider.myBooks;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buku Tersimpan'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => bookProvider.fetchMyBooks(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Input Pencarian
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cari Judul atau Penulis di Koleksimu...',
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

          // Daftar Buku
          Expanded(
            child: bookProvider.isLoadingMy
                ? const Center(child: CircularProgressIndicator())
                : myBooks.isEmpty
                ? const Center(child: Text('Kamu belum menyimpan buku apapun.'))
                : ListView.builder(
                    itemCount: myBooks.length,
                    itemBuilder: (context, index) {
                      final book = myBooks[index];
                      return BookTile(
                        book: book.copyWith(isSaved: true),
                        onSaveToggle: () {
                          bookProvider.toggleBookSaveStatus(book);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${book.title} dihapus dari daftar.',
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
