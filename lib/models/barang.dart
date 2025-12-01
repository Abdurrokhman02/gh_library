class Barang {
  String? id;
  String kodeBarang;
  String namaBarang;
  String kategori;
  int hargaSatuan;
  int hargaPak;
  int stok;

  Barang({
    this.id,
    required this.kodeBarang,
    required this.namaBarang,
    required this.kategori,
    required this.hargaSatuan,
    required this.hargaPak,
    required this.stok,
  });

  factory Barang.fromJson(Map<String, dynamic> json) {
    return Barang(
      // PERBAIKAN DI SINI: Tambahkan .toString()
      // Ini memaksa angka (int) dari MySQL berubah jadi teks (String)
      id: (json['id'] ?? json['_id'])?.toString(), 
      
      kodeBarang: json['kode_barang'] ?? '',
      namaBarang: json['nama_barang'] ?? '',
      kategori: json['kategori'] ?? '',
      // Pastikan harga dan stok tetap int (karena di modelnya int)
      hargaSatuan: json['harga_satuan'] is String 
          ? int.tryParse(json['harga_satuan']) ?? 0 
          : json['harga_satuan'] ?? 0,
      hargaPak: json['harga_pak'] is String 
          ? int.tryParse(json['harga_pak']) ?? 0 
          : json['harga_pak'] ?? 0,
      stok: json['stok'] is String 
          ? int.tryParse(json['stok']) ?? 0 
          : json['stok'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'kode_barang': kodeBarang,
      'nama_barang': namaBarang,
      'kategori': kategori,
      'harga_satuan': hargaSatuan,
      'harga_pak': hargaPak,
      'stok': stok,
      // Tambahkan field tgljam jika diperlukan
      'tgljam': DateTime.now().toIso8601String(),
    };
  }
}
