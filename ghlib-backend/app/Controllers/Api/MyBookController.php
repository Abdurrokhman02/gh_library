<?php

namespace App\Controllers\Api;

use App\Models\BookModel;
use App\Models\UserSavedBookModel;
use CodeIgniter\RESTful\ResourceController;

class MyBookController extends ResourceController
{
    // GET /api/my-books
    public function index()
    {
        $bookModel = new BookModel();
        $userId = (int) $this->request->user_id; // Ambil dari JWT Auth
        $search = $this->request->getGet('search');
        
        $data = $bookModel->getSavedBooks($userId, $search);
        
        return $this->respond([
            'status' => 200,
            'message' => 'Data buku simpanan berhasil dimuat',
            'data' => $data,
        ]);
    }

    // POST /api/my-books (Toggle save/unsave)
    public function toggle()
    {
        $input = $this->request->getJSON(true);
        $userId = (int) $this->request->user_id; // Ambil dari JWT Auth
        
        // Validasi input minimal
        if (empty($input['title'])) {
             return $this->failValidationError('Judul buku wajib ada.');
        }

        // 1. KONVERSI TIPE DATA (Cari atau Buat Buku di DB Lokal)
        $bookModel = new BookModel();
        
        // <=== INI BARIS YANG TADINYA ERROR ===>
        $localBookId = $bookModel->findOrCreateExternal([
            'title'       => $input['title'],
            'author'      => $input['author'],
            'cover_url'   => $input['cover_url'],
            'description' => $input['description'] ?? '',
        ]);

        // 2. TOGGLE SIMPAN (Menggunakan ID Lokal Integer)
        $savedModel = new UserSavedBookModel();
        $key = ['user_id' => $userId, 'book_id' => $localBookId];
        
        $isSaved = $savedModel->where($key)->first();

        if ($isSaved) {
            $savedModel->where($key)->delete();
            $message = 'Buku dihapus dari koleksi.';
            $newStatus = false;
        } else {
            $savedModel->insert($key);
            $message = 'Buku disimpan ke koleksi.';
            $newStatus = true;
        }

        return $this->respondCreated([
            'status' => 200,
            'message' => $message,
            'is_saved' => $newStatus,
        ]);
    }
}