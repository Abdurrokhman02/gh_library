// lib/providers/book_provider.dart
import 'package:flutter/material.dart';

import '../models/book_model.dart';
import '../services/api_service.dart';

class BookProvider with ChangeNotifier {
  List<Book> _allBooks = [];
  List<Book> _myBooks = [];
  bool _isLoadingAll = false;
  bool _isLoadingMy = false;
  String _selectedCategory = 'Semua';
  String _selectedSort = 'latest';
  String _searchQuery = ''; // State untuk query pencarian

  final ApiService _apiService = ApiService();

  List<Book> get allBooks => _allBooks;
  List<Book> get myBooks => _myBooks;
  bool get isLoadingAll => _isLoadingAll;
  bool get isLoadingMy => _isLoadingMy;
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

  // --- Home Screen Logic (Fetch Semua Buku) ---
  Future<void> fetchAllBooks() async {
    _isLoadingAll = true;
    notifyListeners();
    try {
      final categoryFilter = _selectedCategory == 'Semua'
          ? null
          : _selectedCategory;
      _allBooks = await _apiService.fetchAllBooks(
        categoryId: categoryFilter,
        sortBy: _selectedSort,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
      );
    } catch (e) {
      _allBooks = [];
      print('Error fetching all books: $e');
    }
    _isLoadingAll = false;
    notifyListeners();
  }

  // --- My Book Screen Logic (Fetch Buku Tersimpan) ---
  Future<void> fetchMyBooks() async {
    _isLoadingMy = true;
    notifyListeners();
    try {
      _myBooks = await _apiService.fetchMyBooks(
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
      );
    } catch (e) {
      _myBooks = [];
      print('Error fetching my books: $e');
    }
    _isLoadingMy = false;
    notifyListeners();
  }

  // Method untuk mengupdate state search
  void updateSearchQuery(String query) {
    _searchQuery = query;
  }

  void updateCategoryFilter(String category) {
    _selectedCategory = category;
    fetchAllBooks();
  }

  void updateSortOption(String sort) {
    _selectedSort = sort;
    fetchAllBooks();
  }

  // Logic untuk save/delete dari Halaman Home
  Future<void> toggleBookSaveStatus(Book book) async {
    // Baris 97 yang tadinya error, sekarang teratasi karena toggleSavedBook sudah ada di ApiService
    final bool success = await _apiService.toggleSavedBook(
      book.id,
      !book.isSaved,
    );

    if (success) {
      // Update daftar semua buku
      final indexAll = _allBooks.indexWhere((b) => b.id == book.id);
      if (indexAll != -1) {
        _allBooks[indexAll] = book.copyWith(isSaved: !book.isSaved);
      }

      // Panggil ulang fetchMyBooks untuk memastikan MyBook sinkron
      notifyListeners();
      fetchMyBooks();
    }
  }
}
