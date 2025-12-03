import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart'; // Wajib diimport
import '../providers/user_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  File? _pickedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserProvider>(context, listen: false).loadUserProfile();
    });
  }

  // Fungsi untuk memilih gambar
  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _pickedImage = File(image.path);
      });
    }
  }

  // Fungsi untuk update profil
  void _updateProfile() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final bool success = await userProvider.updateProfile(
      name: _nameController.text,
      email: _emailController.text,
      newImage: _pickedImage,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? 'Profil berhasil diperbarui!' : 'Gagal memperbarui profil.',
        ),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
    setState(() {
      _pickedImage = null;
    });
  }

  // Memunculkan dialog edit profil (Logika ini tetap sama)
  void _showEditProfileDialog() {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    if (user == null) return;

    _nameController.text = user.name;
    _emailController.text = user.email;
    _pickedImage = null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SingleChildScrollView(
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setStateModal) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Ubah Profil',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

                  // Area Foto Profil
                  GestureDetector(
                    onTap: () async {
                      await _pickImage();
                      setStateModal(() {});
                    },
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey.shade300,
                      backgroundImage: _pickedImage != null
                          ? FileImage(_pickedImage!)
                          : NetworkImage(user.profilePictureUrl)
                                as ImageProvider,
                      child: Stack(
                        children: [
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: CircleAvatar(
                              radius: 15,
                              backgroundColor: Colors.white,
                              child: Icon(
                                Icons.camera_alt,
                                size: 15,
                                color: Colors.deepPurple,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Form Nama
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Nama'),
                  ),
                  const SizedBox(height: 10),

                  // Form Email
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 30),

                  // Tombol Simpan
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _updateProfile();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Simpan Perubahan'),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  // Method untuk Logout (Sudah ada di kode kamu)
  void _logout() {
    // Memanggil signOut dari AuthProvider untuk menghapus token
    Provider.of<AuthProvider>(context, listen: false).signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Pengguna'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // <=== PERBAIKAN DI SINI: Tombol Logout ditambahkan ===>
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout, // Memanggil method yang sudah kamu buat
            tooltip: 'Logout',
          ),
        ], // <=== Akhir actions ===>
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          if (userProvider.isLoading && userProvider.user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (userProvider.user == null) {
            return const Center(child: Text('Gagal memuat data pengguna.'));
          }

          final user = userProvider.user!;

          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Foto Profil
                CircleAvatar(
                  radius: 70,
                  backgroundColor: Colors.grey.shade300,
                  backgroundImage: NetworkImage(user.profilePictureUrl),
                  onBackgroundImageError: (exception, stackTrace) =>
                      const Icon(Icons.person, size: 80),
                ),
                const SizedBox(height: 20),

                // Nama
                Text(
                  user.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),

                // Email
                Text(
                  user.email,
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 40),

                // Tombol Ubah Profil
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: userProvider.isLoading
                        ? null
                        : _showEditProfileDialog,
                    icon: userProvider.isLoading
                        ? const SizedBox(
                            height: 15,
                            width: 15,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.edit),
                    label: Text(
                      userProvider.isLoading ? 'Memperbarui...' : 'Ubah Profil',
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
