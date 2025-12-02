// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart'; // <=== BARU
import 'providers/book_provider.dart';
import 'providers/user_provider.dart';
import 'screens/login_screen.dart';
import 'screens/main_wrapper.dart';
import 'screens/registration_screen.dart'; // <=== BARU

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ), // <=== Tambahkan AuthProvider
        ChangeNotifierProvider(create: (_) => BookProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MaterialApp(
        title: 'Gh Library',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        // Cek status autentikasi untuk menentukan halaman awal
        home: Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            switch (authProvider.status) {
              case AuthStatus.uninitialized:
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              case AuthStatus.unauthenticated:
                return const LoginScreen(); // Tampilkan halaman Login
              case AuthStatus.authenticated:
                return const MainWrapper(); // Tampilkan Main Wrapper
            }
          },
        ),
      ),
    );
  }
}
