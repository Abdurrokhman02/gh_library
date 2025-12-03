<?php

namespace App\Controllers\Api;

use App\Models\BookModel;
// Ganti CodeIgniter\RESTful\ResourceController agar bisa akses $request->user_id
use CodeIgniter\Controller; 
use CodeIgniter\API\ResponseTrait;

class BookController extends Controller
{
    use ResponseTrait;

    public function index()
    {
        $bookModel = new BookModel();
        
        // AMBIL user_id DARI JWT FILTER
        $userId = $this->request->user_id; // <=== PERUBAHAN UTAMA

        $category = $this->request->getGet('category');
        $sort = $this->request->getGet('sort') ?? 'latest';
        $search = $this->request->getGet('search');

        $data = $bookModel->getBooksWithCategoryAndSavedStatus($userId, $category, $sort, $search);

        return $this->respond(['status' => 200, 'message' => 'Data buku berhasil dimuat', 'data' => $data]);
    }
}