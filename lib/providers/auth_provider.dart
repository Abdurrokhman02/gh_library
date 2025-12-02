// lib/providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

enum AuthStatus { uninitialized, authenticated, unauthenticated }

class AuthProvider with ChangeNotifier {
    AuthStatus _status = AuthStatus.uninitialized;
    final ApiService _apiService = ApiService();
    
    AuthStatus get status => _status;

    AuthProvider() {
        _checkIfLoggedIn();
    }

    // Cek token di SharedPreferences saat aplikasi mulai
    Future<void> _checkIfLoggedIn() async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('auth_token');
        
        if (token != null) {
            _status = AuthStatus.authenticated;
        } else {
            _status = AuthStatus.unauthenticated;
        }
        notifyListeners();
    }
    
    Future<bool> signIn(String email, String password) async {
        final token = await _apiService.login(email, password);
        
        if (token != null) {
            _status = AuthStatus.authenticated;
            notifyListeners();
            return true;
        }
        return false;
    }

    Future<void> signOut() async {
        final prefs = await SharedPreferences.getInstance();
        // Hapus token dan user ID
        await prefs.remove('auth_token');
        await prefs.remove('user_id'); 
        _status = AuthStatus.unauthenticated;
        notifyListeners();
    }
}