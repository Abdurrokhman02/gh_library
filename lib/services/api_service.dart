// lib/services/api_service.dart
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../models/book_model.dart';
import '../models/user_model.dart';

class ApiService {
  final String _ci4BaseUrl = 'http://192.168.1.13:8080';
  final String _externalUploadUrl =
      'https://api.imgbb.com/1/upload?key=YOUR_IMGBB_API_KEY';
  final int _userId = 1;

  // --- API UNTUK BUKU ---

  Future<List<Book>> fetchAllBooks({
    String? categoryId,
    String? sortBy,
    String? search,
  }) async {
    final Map<String, dynamic> queryParams = {};
    if (categoryId != null) queryParams['category'] = categoryId;
    if (sortBy != null) queryParams['sort'] = sortBy;
    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    queryParams['user_id'] = _userId.toString();

    final uri = Uri.parse(
      '$_ci4BaseUrl/api/books',
    ).replace(queryParameters: queryParams);

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'] as List;
        return data.map((json) => Book.fromJson(json)).toList();
      } else {
        throw Exception('Gagal memuat buku: Status ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetchAllBooks: $e');
      throw Exception(
        'Gagal memuat buku dari server. Cek koneksi atau CI4 API.',
      );
    }
  }

  Future<List<Book>> fetchMyBooks({String? search}) async {
    final Map<String, dynamic> queryParams = {};
    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    queryParams['user_id'] = _userId.toString();

    final uri = Uri.parse(
      '$_ci4BaseUrl/api/my-books',
    ).replace(queryParameters: queryParams);

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'] as List;
        return data.map((json) => Book.fromJson(json)).toList();
      } else {
        throw Exception(
          'Gagal memuat buku simpanan: Status ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error fetchMyBooks: $e');
      throw Exception('Gagal memuat buku simpanan. Cek koneksi atau CI4 API.');
    }
  }

  // <==== INI METHOD YANG HILANG DAN PENYEBAB ERROR KAMU! ====>
  Future<bool> toggleSavedBook(int bookId, bool isSaved) async {
    final Map<String, dynamic> body = {'user_id': _userId, 'book_id': bookId};

    final uri = Uri.parse('$_ci4BaseUrl/api/my-books');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      print('Gagal toggle: ${response.body}');
      return false;
    }
  }
  // <=======================================================>

  // --- API UNTUK PROFILE ---

  Future<User> fetchUserProfile() async {
    final uri = Uri.parse('$_ci4BaseUrl/api/user/profile?user_id=$_userId');

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];
        return User.fromJson(data);
      } else {
        throw Exception('Gagal memuat profil: Status ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetchUserProfile: $e');
      throw Exception('Gagal memuat profil. Cek koneksi atau CI4 API.');
    }
  }

  Future<bool> updateProfile(
    String name,
    String email,
    String? newPhotoUrl,
  ) async {
    final Map<String, dynamic> body = {
      'user_id': _userId,
      'name': name,
      'email': email,
      if (newPhotoUrl != null) 'profile_picture_url': newPhotoUrl,
    };

    final uri = Uri.parse('$_ci4BaseUrl/api/user/update');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
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
}
