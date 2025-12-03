import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/book_model.dart';

class OpenLibraryService {
  static const String baseUrl = "https://openlibrary.org/search.json";

  static Future<List<Book>> searchBooks(String? query) async {
    if (query == null || query.isEmpty) return [];

    final response = await http.get(Uri.parse("$baseUrl?q=$query"));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final docs = data["docs"] as List;

      return docs.map((book) {
        return Book(
          id: book["key"] ?? "",
          title: book["title"] ?? "No Title",
          author: (book["author_name"] != null && book["author_name"].isNotEmpty)
              ? book["author_name"][0]
              : "Unknown",
          coverUrl: (book["cover_i"] != null)
              ? "https://covers.openlibrary.org/b/id/${book["cover_i"]}-M.jpg"
              : "",

          category: "Unknown",
          isSaved: false,
        );
      }).toList();
    }

    return [];
  }

}
