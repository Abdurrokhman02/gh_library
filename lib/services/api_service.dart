// lib/services/api_service.dart

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/book_model.dart';
import '../models/user_model.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String _ci4BaseUrl = 'http://10.0.2.2/ghlib-backend/public';
  final String _externalUploadUrl =
      'https://api.imgbb.com/1/upload?key=YOUR_IMGBB_API_KEY';

  // State sementara untuk User ID
  int _currentUserId = 0;

  // --- PRIVATE METHOD: GET JWT HEADERS ---
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
    return headers;
  }

  // --- PRIVATE METHOD: GET USER ID ---
  Future<int> _getUserId() async {
    if (_currentUserId == 0) {
      final prefs = await SharedPreferences.getInstance();
      _currentUserId = prefs.getInt('user_id') ?? 0;
    }
    return _currentUserId;
  }

  // --- API AUTHENTIKASI & LOGIC DASAR ---

  Future<String?> login(String email, String password) async {
    final uri = Uri.parse('$_ci4BaseUrl/api/auth/login');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final token = data['token'] as String?;
      final userId = data['user_id'];

      // FIX: Pastikan userId diparse dengan aman
      final int parsedUserId = int.tryParse(userId?.toString() ?? '0') ?? 0;

      if (token != null && parsedUserId != 0) {
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('auth_token', token);
        prefs.setInt('user_id', parsedUserId);
        _currentUserId = parsedUserId;
        return token;
      }
    }
    return null;
  }

  Future<bool> register(String name, String email, String password) async {
    final uri = Uri.parse('$_ci4BaseUrl/api/auth/register');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'name': name, 'email': email, 'password': password}),
    );

    return response.statusCode == 201;
  }

  // --- API FETCH BUKU ---

  Future<List<Book>> fetchAllBooks({
    String? categoryId,
    String? sortBy,
    String? search,
  }) async {
    final Map<String, dynamic> queryParams = {};
    if (categoryId != null) queryParams['category'] = categoryId;
    if (sortBy != null) queryParams['sort'] = sortBy;
    if (search != null && search.isNotEmpty) queryParams['search'] = search;

    final uri = Uri.parse(
      '$_ci4BaseUrl/api/books',
    ).replace(queryParameters: queryParams);

    try {
      final response = await http.get(uri, headers: await _getHeaders());

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'] as List;
        return data
            .map((json) => Book.fromJson(json))
            .toList(); // <=== FIX: RETURN DATA
      } else if (response.statusCode == 401) {
        throw Exception('Token Expired');
      } else {
        throw Exception('Gagal memuat buku: Status ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetchAllBooks: $e');
      rethrow; // Melempar error agar ditangkap Provider
    }
  }

  Future<List<Book>> fetchMyBooks({String? search}) async {
    final Map<String, dynamic> queryParams = {};
    if (search != null && search.isNotEmpty) queryParams['search'] = search;

    final uri = Uri.parse(
      '$_ci4BaseUrl/api/my-books',
    ).replace(queryParameters: queryParams);

    try {
      final response = await http.get(uri, headers: await _getHeaders());

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'] as List;
        return data
            .map((json) => Book.fromJson(json))
            .toList(); // <=== FIX: RETURN DATA
      } else if (response.statusCode == 401) {
        throw Exception('Token Expired');
      } else {
        throw Exception(
          'Gagal memuat buku simpanan: Status ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error fetchMyBooks: $e');
      rethrow; // Melempar error agar ditangkap Provider
    }
  }

  // <==== METHOD YANG HILANG DAN PENYEBAB ERROR KAMU ====>
  Future<bool> toggleSavedBook({
    required Book book,
    required bool isSaved,
  }) async {
    final body = {
      'external_id': book.id,
      'title': book.title,
      'author': book.author,
      'cover_url': book.coverUrl,
      'description': book.description,
    };

    final uri = Uri.parse('$_ci4BaseUrl/api/my-books');
    final response = await http.post(
      uri,
      headers: await _getHeaders(),
      body: json.encode(body),
    );

    return response.statusCode == 200 || response.statusCode == 201;
  }

  // <=======================================================>

  // --- API USER PROFILE ---

  Future<User> fetchUserProfile() async {
    final uri = Uri.parse('$_ci4BaseUrl/api/user/profile');

    try {
      final response = await http.get(uri, headers: await _getHeaders());

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];
        return User.fromJson(data); // <=== FIX: RETURN DATA
      } else if (response.statusCode == 401) {
        throw Exception('Token Expired');
      } else {
        throw Exception('Gagal memuat profil: Status ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetchUserProfile: $e');
      rethrow; // Melempar error agar ditangkap Provider
    }
  }

  Future<bool> updateProfile(
    String name,
    String email,
    String? newPhotoUrl,
  ) async {
    final Map<String, dynamic> body = {
      'user_id': await _getUserId(),
      'name': name,
      'email': email,
      if (newPhotoUrl != null) 'profile_picture_url': newPhotoUrl,
    };

    final uri = Uri.parse('$_ci4BaseUrl/api/user/update');

    final response = await http.post(
      uri,
      headers: await _getHeaders(),
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Gagal update profil: ${response.body}');
      return false;
    }
  }

  Future<String> uploadProfilePicture(File imageFile) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse(_externalUploadUrl),
    );
    request.files.add(
      await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
        contentType: MediaType('image', 'jpeg'),
      ),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final String uploadedUrl = data['data']['url'];
      print('Foto berhasil diupload: $uploadedUrl');
      return uploadedUrl;
    } else {
      print('Gagal upload foto: ${response.statusCode} - ${response.body}');
      throw Exception('Gagal mengupload foto ke API eksternal.');
    }
  }

  // === OPEN LIBRARY EXTERNAL API ===
  Future<List<Map<String, dynamic>>> searchBooksFromOpenLibrary(String query) async {
    final url = Uri.parse('https://openlibrary.org/search.json?q=$query');
    print("🔎 Fetching from: $url");

    final response = await http.get(url);

    print("📥 Status Code: ${response.statusCode}");
    print("📦 Response body: ${response.body}");

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List docs = data['docs'];

      return docs.map((doc) {
        return {
          "id": doc["cover_edition_key"] ?? doc["key"] ?? "",
          "title": doc["title"] ?? "Judul Tidak Tersedia",
          "author": (doc["author_name"] != null && doc["author_name"].isNotEmpty)
              ? doc["author_name"][0]
              : "Tidak diketahui",
          "category_name": (doc["subject"] != null && doc["subject"].isNotEmpty)
              ? doc["subject"][0]
              : "Umum",
          "cover_url": doc["cover_i"] != null
              ? "https://covers.openlibrary.org/b/id/${doc["cover_i"]}-M.jpg"
              : "",
          "description": "Deskripsi belum tersedia.",
          "is_saved": false,
        };
      }).toList();
    } else {
      throw Exception("OpenLibrary API Error: ${response.statusCode}");
    }
  }

  // Future<bool> createBook({
  //   required String title,
  //   required String author,
  //   required String category,
  //   required String coverUrl,
  //   required String description,
  // }) async {
  //   final response = await http.post(
  //     Uri.parse("$baseUrl/books"),
  //     body: {
  //       "title": title,
  //       "author": author,
  //       "category_name": category,
  //       "cover_url": coverUrl,
  //       "description": description,
  //     },
  //   );
  //
  //   return response.statusCode == 200;
  // }


}
