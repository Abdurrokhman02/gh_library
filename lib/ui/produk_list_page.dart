import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/produk.dart';
import '../services/api_service.dart';
import 'produk_form_page.dart';

class TokenExpiredException implements Exception {
  final String message = 'Token telah kedaluwarsa';
}

class ProdukListPage extends StatefulWidget {
  const ProdukListPage({super.key});

  @override
  State<ProdukListPage> createState() => _ProdukListPageState();
}

class _ProdukListPageState extends State<ProdukListPage> {
  final ApiService _apiService = ApiService();
  late Future<List<Produk>> _futureProduk;
  List<Produk> _cachedProduk = []; // ⭐️ 1. Cache produk yang sudah diambil

  bool _isGridView = false;
  // ⭐️ 2. STATE BARU untuk fitur Pencarian
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadProduk();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadProduk() {
    setState(() {
      _futureProduk = _apiService.getProduk().then((produkList) {
        // Simpan hasil ke cache setelah berhasil diambil
        _cachedProduk = produkList;
        return produkList;
      });
    });
  }

  // ⭐️ 3. GETTER untuk memfilter produk dari CACHE
  List<Produk> get _filteredProduk {
    if (_searchQuery.isEmpty) return _cachedProduk;

    final query = _searchQuery.toLowerCase();

    return _cachedProduk.where((produk) {
      // Filter berdasarkan Nama Produk atau ID (jika ID di-return sebagai String)
      final namaLower = produk.namaProduk.toLowerCase();
      final idString = produk.id?.toString() ?? ''; // Asumsi ID bisa null

      return namaLower.contains(query) || idString.contains(query);
    }).toList();
  }

  // ⭐️ 4. TOGGLE PENCARIAN
  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        // Bersihkan pencarian saat ditutup
        _searchController.clear();
        _searchQuery = '';
      }
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  Future<void> _navigateToForm({Produk? produk}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProdukFormPage(produk: produk)),
    );
    if (result == true) {
      _loadProduk();
    }
  }

  Future<void> _delete(Produk produk) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Produk?'),
        content: Text('Yakin ingin menghapus ${produk.namaProduk}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final response = await _apiService.deleteProduk(produk.id!.toString());

      if (!mounted) return;

      if (response.status) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produk berhasil dihapus')),
        );
        _loadProduk();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus: ${response.data}')),
        );
      }
    }
  }

  // WIDGET BUILDER UNTUK LIST VIEW
  Widget _buildListView(List<Produk> data) {
    if (data.isEmpty && _searchQuery.isNotEmpty) {
      return Center(
        child: Text('Tidak ada produk yang cocok dengan "$_searchQuery"'),
      );
    }
    if (data.isEmpty && _searchQuery.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(30.0),
          child: Text('Belum ada data produk'),
        ),
      );
    }

    return ListView.builder(
      itemCount: data.length,
      itemBuilder: (context, index) {
        final produk = data[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: ListTile(
            title: Text(
              produk.namaProduk,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('Rp ${produk.harga}'),
            onTap: () => _navigateToForm(produk: produk),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _delete(produk),
            ),
          ),
        );
      },
    );
  }

  // WIDGET BUILDER UNTUK GRID VIEW
  Widget _buildGridView(List<Produk> data) {
    if (data.isEmpty && _searchQuery.isNotEmpty) {
      return Center(
        child: Text('Tidak ada produk yang cocok dengan "$_searchQuery"'),
      );
    }
    if (data.isEmpty && _searchQuery.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(30.0),
          child: Text('Belum ada data produk'),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(10.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: data.length,
      itemBuilder: (context, index) {
        final produk = data[index];
        return GestureDetector(
          onTap: () => _navigateToForm(produk: produk),
          child: Card(
            elevation: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Container(
                    color: Colors.grey[200],
                    child: const Icon(
                      Icons.inventory,
                      size: 50,
                      color: Colors.grey,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        produk.namaProduk,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Rp ${produk.harga}',
                        style: TextStyle(color: Colors.green[700]),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.red,
                            size: 20,
                          ),
                          onPressed: () => _delete(produk),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // ⭐️ 5. TITLE App Bar diubah menjadi TextField saat _isSearching true
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Cari produk...',
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value; // Update query saat teks berubah
                  });
                },
              )
            : const Text('Daftar Produk'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // ⭐️ 6. Tombol SEARCH/CLOSE
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: _toggleSearch,
            tooltip: _isSearching ? 'Tutup Pencarian' : 'Cari Produk',
          ),

          if (!_isSearching) // Tombol view hanya tampil saat tidak mencari
            IconButton(
              icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
              tooltip: _isGridView
                  ? 'Ubah ke Tampilan Daftar'
                  : 'Ubah ke Tampilan Grid',
              onPressed: () {
                setState(() {
                  _isGridView = !_isGridView;
                });
              },
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Keluar',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Apakah Anda yakin ingin keluar?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Batal'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Keluar'),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                _logout();
              }
            },
          ),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: () async {
          // Reset pencarian saat refresh
          _searchController.clear();
          _searchQuery = '';
          _loadProduk();
          try {
            await _futureProduk;
          } catch (_) {}
        },

        child: FutureBuilder<List<Produk>>(
          future: _futureProduk,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              // ... (Logika error handling sama)
              final error = snapshot.error;
              if (error is TokenExpiredException) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(error.message)));
                  _logout();
                });
                return const Center(
                  child: Text('Sesi Habis. Sedang mengarahkan ke Login...'),
                );
              }

              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Error: ${error.toString()}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _loadProduk,
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              );
            }

            // ⭐️ 7. TAMPILKAN DATA HASIL FILTER
            final dataProduk = _filteredProduk;

            // Logika ini sudah dipindahkan ke _buildListView dan _buildGridView, tapi di sini kita cegah
            // tampilan kosong total saat data awal memang kosong
            if (_cachedProduk.isEmpty && _searchQuery.isEmpty) {
              return ListView(
                children: const [
                  Center(
                    child: Padding(
                      padding: EdgeInsets.all(30.0),
                      child: Text('Belum ada data produk'),
                    ),
                  ),
                ],
              );
            }

            // ⭐️ 8. Pilih tampilan berdasarkan state _isGridView dengan data yang sudah di-filter
            return _isGridView
                ? _buildGridView(dataProduk)
                : _buildListView(dataProduk);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
