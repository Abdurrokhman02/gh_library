import 'package:flutter/material.dart';

import '../models/book_model.dart';
import '../services/api_service.dart';
import '../services/openlibrary_service.dart';

class BookProvider with ChangeNotifier {
  // --- STATE LOADING ---
  bool _isLoadingAll = false;
  bool _isLoadingMy = false;
  bool _isSearching = false; // <=== KEMBALIKAN INI (Untuk Search Screen)

  // --- STATE DATA ---
  String _selectedCategory = 'Semua';
  String _selectedSort = 'latest';
  String _searchQuery = '';

  List<Book> _allBooks = [];
  List<Book> _myBooks = [];
  List<Book> _searchResults = []; // <=== KEMBALIKAN INI (Untuk Search Screen)

  final ApiService _apiService = ApiService();

  // --- GETTERS ---
  List<Book> get allBooks => _allBooks;
  List<Book> get myBooks => _myBooks;
  List<Book> get searchResults => _searchResults; // <=== Getter Wajib

  bool get isLoadingAll => _isLoadingAll;
  bool get isLoadingMy => _isLoadingMy;
  bool get isSearching => _isSearching; // <=== Getter Wajib

  String get selectedCategory => _selectedCategory;
  String get selectedSort => _selectedSort;
  String get searchQuery => _searchQuery;

  final List<String> availableCategories = [
    'Semua',
    'Teknologi',
    'Fiksi',
    'Sejarah',
    'Komik',
  ];
  final Map<String, String> sortOptions = {
    'Terbaru': 'latest',
    'Terpopuler': 'popular',
    'Judul A-Z': 'title_asc',
  };

  // --- 1. FETCH UNTUK HOME SCREEN ---
  Future<void> fetchAllBooks() async {
    _isLoadingAll = true;
    notifyListeners();

    try {
      // Jika search kosong, ambil topik default dari OpenLibrary
      String query = _searchQuery.isNotEmpty ? _searchQuery : 'trending';

      print("Home: Mengambil dari OpenLibrary: $query");
      _allBooks = await OpenLibraryService.searchBooks(query);
    } catch (e) {
      _allBooks = [];
      print('Error fetching books: $e');
    }

    _isLoadingAll = false;
    notifyListeners();
  }

  // --- 2. FETCH UNTUK MY BOOK SCREEN ---
  Future<void> fetchMyBooks() async {
    _isLoadingMy = true;
    notifyListeners();
    try {
      _myBooks = await _apiService.fetchMyBooks();
    } catch (e) {
      _myBooks = [];
    }
    _isLoadingMy = false;
    notifyListeners();
  }

  // --- 3. FETCH UNTUK SEARCH SCREEN (KHUSUS) ---
  Future<void> searchBooks(String query) async {
    _isSearching = true;
    notifyListeners();

    try {
      // Pencarian khusus untuk halaman SearchBookScreen
      _searchResults = await OpenLibraryService.searchBooks(query);
    } catch (e) {
      _searchResults = [];
      print('Error searching books: $e');
    }

    _isSearching = false;
    notifyListeners();
  }

  // --- HELPER METHODS ---
  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void updateCategoryFilter(String category) {
    _selectedCategory = category;
    fetchAllBooks();
  }

  void updateSortOption(String sort) {
    _selectedSort = sort;
    fetchAllBooks();
  }

  // --- LOGIKA SIMPAN (TOGGLE) ---
  Future<void> toggleBookSaveStatus(Book book) async {
    // Kita kirim seluruh objek book untuk findOrCreate di backend
    final bool success = await _apiService.toggleSavedBook(book);

    if (success) {
      // 1. Update UI di Home (All Books)
      final indexAll = _allBooks.indexWhere((b) => b.id == book.id);
      if (indexAll != -1) {
        _allBooks[indexAll] = book.copyWith(isSaved: !book.isSaved);
      }

      // 2. Update UI di Search Screen (Search Results)
      final indexSearch = _searchResults.indexWhere((b) => b.id == book.id);
      if (indexSearch != -1) {
        _searchResults[indexSearch] = book.copyWith(isSaved: !book.isSaved);
      }

      notifyListeners();

      // 3. Refresh MyBook agar data sinkron dengan ID database
      fetchMyBooks();
    }
  }
}
