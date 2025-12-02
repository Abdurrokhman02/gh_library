import 'dart:io';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

class UserProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  final ApiService _apiService = ApiService();

  User? get user => _user;
  bool get isLoading => _isLoading;

  Future<void> loadUserProfile() async {
    _isLoading = true;
    notifyListeners();
    try {
      _user = await _apiService.fetchUserProfile();
    } catch (e) {
      _user = null;
      print(e);
      // Tampilkan error ke user
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> updateProfile({
    required String name,
    required String email,
    File? newImage,
  }) async {
    if (_user == null) return false;

    _isLoading = true;
    notifyListeners();

    String? newPhotoUrl;
    if (newImage != null) {
      try {
        // 1. Upload foto ke API eksternal
        newPhotoUrl = await _apiService.uploadProfilePicture(newImage);
      } catch (e) {
        _isLoading = false;
        notifyListeners();
        return false; // Gagal upload foto
      }
    }

    try {
      // 2. Update data ke API CodeIgniter
      final bool success = await _apiService.updateProfile(
        name, 
        email, 
        newPhotoUrl
      );

      if (success) {
        // 3. Update state lokal jika sukses
        _user = _user!.copyWith(
          name: name,
          email: email,
          profilePictureUrl: newPhotoUrl ?? _user!.profilePictureUrl,
        );
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      print(e);
    }
    
    _isLoading = false;
    notifyListeners();
    return false;
  }
}