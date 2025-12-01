const express = require('express');
const mysql = require('mysql2');
const cors = require('cors');
const bodyParser = require('body-parser');

const app = express();
app.use(cors());
app.use(bodyParser.json());

// Koneksi ke Database Laragon
const db = mysql.createConnection({
    host: 'localhost',
    user: 'root',      // Default user Laragon
    password: '',      // Default password Laragon kosong
    database: 'flutter_tokobuku'
});

db.connect(err => {
    if (err) console.error('Database connect error:', err);
    else console.log('Connected to MySQL Database!');
});

// --- API ROUTES ---

// 1. Login
app.post('/api/auth/login', (req, res) => {
    const { email, password } = req.body;
    // Query simpel (PERINGATAN: Di production harus pakai hash password!)
    db.query('SELECT * FROM users WHERE email = ? AND password = ?', [email, password], (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        if (results.length === 0) return res.status(401).json({ message: 'Email atau password salah' });
        
        const user = results[0];
        // Kirim response sesuai format Flutter
        res.json({
            token: 'dummy-token-' + user.id, // Token pura-pura
            user: {
                id: user.id,
                nama: user.nama,
                email: user.email,
                verified: user.verified === 1
            }
        });
    });
});

// 2. Get All Barang
app.get('/api/barang', (req, res) => {
    db.query('SELECT * FROM barang ORDER BY id DESC', (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json(results);
    });
});

// 3. Create Barang
app.post('/api/barang', (req, res) => {
    const { kode_barang, nama_barang, kategori, harga_satuan, harga_pak, stok } = req.body;
    const sql = 'INSERT INTO barang (kode_barang, nama_barang, kategori, harga_satuan, harga_pak, stok) VALUES (?, ?, ?, ?, ?, ?)';
    db.query(sql, [kode_barang, nama_barang, kategori, harga_satuan, harga_pak, stok], (err, result) => {
        if (err) return res.status(500).json({ error: err.message });
        res.status(201).json({ id: result.insertId, ...req.body });
    });
});

// 4. Update Barang
app.put('/api/barang/:id', (req, res) => {
    const { kode_barang, nama_barang, kategori, harga_satuan, harga_pak, stok } = req.body;
    const sql = 'UPDATE barang SET kode_barang=?, nama_barang=?, kategori=?, harga_satuan=?, harga_pak=?, stok=? WHERE id=?';
    db.query(sql, [kode_barang, nama_barang, kategori, harga_satuan, harga_pak, stok, req.params.id], (err) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json({ id: req.params.id, ...req.body });
    });
});

// 5. Delete Barang
app.delete('/api/barang/:id', (req, res) => {
    db.query('DELETE FROM barang WHERE id = ?', [req.params.id], (err) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json({ message: 'Deleted successfully' });
    });
});

app.listen(3000, () => {
    console.log('Server berjalan di port 3000');
});