import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/book_provider.dart';

class SearchBookScreen extends StatefulWidget {
  const SearchBookScreen({super.key});

  @override
  State<SearchBookScreen> createState() => _SearchBookScreenState();
}

class _SearchBookScreenState extends State<SearchBookScreen> {
  final TextEditingController _controller = TextEditingController();

  void _search() {
    final query = _controller.text.trim();
    if (query.isNotEmpty) {
      Provider.of<BookProvider>(context, listen: false).searchBooks(query);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cari Buku Online')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Judul buku...',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _search,
                ),
              ),
            ),
            const SizedBox(height: 20),

            Expanded(
              child: Consumer<BookProvider>(
                builder: (context, provider, _) {
                  if (provider.isSearching) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (provider.searchResults.isEmpty) {
                    return const Center(child: Text("Belum ada hasil pencarian"));
                  }

                  return ListView.builder(
                    itemCount: provider.searchResults.length,
                    itemBuilder: (context, i) {
                      final book = provider.searchResults[i];
                      return ListTile(
                        leading: book.coverUrl != null
                            ? Image.network(book.coverUrl!, width: 50)
                            : const Icon(Icons.book),
                        title: Text(book.title),
                        subtitle: Text(book.author ?? "Tidak diketahui"),
                      );
                    },
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
