import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'screens/dashboard/barang_list.dart';
import 'screens/auth/login.dart';
import 'screens/auth/verify_otp.dart'; // Tambahkan import

void main() {
final httpClient = http.Client();
  
  // PERUBAHAN: Deteksi otomatis IP Emulator vs Web/iOS
  String baseUrl = 'https://api.tokobuku.com'; // Default production
  if (kDebugMode) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      baseUrl = 'http://10.0.2.2:3000'; // IP khusus Emulator Android
    } else {
      baseUrl = 'http://localhost:3000'; // Untuk iOS Simulator atau Web
    }
  }

  final apiService = ApiService(
    baseUrl: baseUrl,
    client: httpClient,
  );

  runApp(
    MultiProvider(
      providers: [
        Provider<ApiService>(create: (_) => apiService),
        ChangeNotifierProvider<AuthService>(
          create: (_) => AuthService(apiService: apiService),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Toko Buku',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      routes: {
        '/login': (context) => LoginScreen(),
        '/verify-otp': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map;
          return VerifyOtpScreen(email: args['email']);
        },
        '/barang_list': (context) => BarangListScreen(),
      },
      home: FutureBuilder(
        future: Provider.of<AuthService>(context, listen: false).initialize(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasError) {
            return Scaffold(
              body: Center(child: Text('Error: ${snapshot.error}')),
            );
          }

          return Consumer<AuthService>(
            builder: (context, auth, _) {
              if (auth.isAuthenticated) {
                return BarangListScreen();
              } else {
                return LoginScreen();
              }
            },
          );
        },
      ),
    );
  }
}
