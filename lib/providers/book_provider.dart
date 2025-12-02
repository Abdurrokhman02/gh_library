import 'package:flutter/material.dart';
import '../models/book_model.dart';
import '../services/api_service.dart';
import '../services/openlibrary_service.dart';

class BookProvider with ChangeNotifier {
  // Loading state
  bool _isSearching = false;
  bool _isLoadingAll = false;
  bool _isLoadingMy = false;

  // Data State
  List<Book> _searchResults = [];
  List<Book> _allBooks = [];
  List<Book> _myBooks = [];
  String _selectedCategory = 'Semua';
  String _selectedSort = 'latest';
  String _searchQuery = '';

  final ApiService _apiService = ApiService();

  // Getters
  bool get isSearching => _isSearching;
  bool get isLoadingAll => _isLoadingAll;
  bool get isLoadingMy => _isLoadingMy;
  List<Book> get searchResults => _searchResults;
  List<Book> get allBooks => _allBooks;
  List<Book> get myBooks => _myBooks;
  String get selectedCategory => _selectedCategory;
  String get selectedSort => _selectedSort;
  String get searchQuery => _searchQuery;

  // Category & Sort
  final List<String> availableCategories = [
    'Semua', 'Teknologi', 'Fiksi', 'Sejarah', 'Komik',
  ];

  final Map<String, String> sortOptions = {
    'Terbaru': 'latest',
    'Terpopuler': 'popular',
    'Judul A-Z': 'title_asc',
  };

  /// --- Fetch Semua Buku (BACKEND KAMU) ---
  Future<void> fetchAllBooks() async {
    _isLoadingAll = true;
    notifyListeners();

    try {
      // Jika user melakukan pencarian → Ambil dari OpenLibrary
      if (_searchQuery.isNotEmpty) {
        _allBooks = await OpenLibraryService.searchBooks(_searchQuery);
      }
      // Jika tidak ada query → Ambil dari backend kamu sendiri
      else {
        final categoryFilter = _selectedCategory == 'Semua' ? null : _selectedCategory;

        _allBooks = await _apiService.fetchAllBooks(
          categoryId: categoryFilter,
          sortBy: _selectedSort,
          search: null,
        );
      }
    } catch (e) {
      _allBooks = [];
      print('Error fetching books: $e');
    }

    _isLoadingAll = false;
    notifyListeners();
  }


  /// --- Pencarian API OpenLibrary ---
  Future<void> searchBooks(String query) async {
    _isSearching = true;
    notifyListeners();

    try {
      _searchResults = await OpenLibraryService.searchBooks(query);
    } catch (_) {
      _searchResults = [];
    }

    _isSearching = false;
    notifyListeners();
  }

  /// Update Search
  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }


  /// Update Filter Category
  void updateCategoryFilter(String category) {
    _selectedCategory = category;
    fetchAllBooks();
  }

  /// Update Sort Option
  void updateSortOption(String sort) {
    _selectedSort = sort;
    fetchAllBooks();
  }

  /// Save Toggle
  Future<void> toggleBookSaveStatus(Book book) async {
    final success = await _apiService.toggleSavedBook(
      book: book,
      isSaved: !book.isSaved,
    );

    if (success) {
      final index = _allBooks.indexWhere((b) => b.id == book.id);
      if (index != -1) {
        _allBooks[index] = book.copyWith(isSaved: !book.isSaved);
      }
      notifyListeners();
      fetchMyBooks();
    }
  }

  /// Fetch My Books (BACKEND)
  Future<void> fetchMyBooks() async {
    _isLoadingMy = true;
    notifyListeners();
    try {
      _myBooks = await _apiService.fetchMyBooks();
    } catch (_) {
      _myBooks = [];
    }
    _isLoadingMy = false;
    notifyListeners();
  }

  // Future<void> saveOpenLibraryBook(Book book) async {
  //   final success = await _apiService.createBook(
  //     title: book.title,
  //     author: book.author,
  //     category: "Umum",  // kategori default kalau tidak ada
  //     coverUrl: book.coverUrl,
  //     description: "Dari OpenLibrary API.",
  //   );
  //
  //   if (success) {
  //     fetchMyBooks();
  //     notifyListeners();
  //   }
  // }

}
