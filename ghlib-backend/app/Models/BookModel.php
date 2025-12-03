<?php

namespace App\Models;

use CodeIgniter\Model;
use App\Models\CategoryModel;

class BookModel extends Model
{
    protected $table            = 'books';
    protected $primaryKey       = 'id';
    protected $useAutoIncrement = true;
    protected $allowedFields    = ['title', 'author', 'category_id', 'cover_url', 'description', 'created_at'];

    // 1. Method untuk mencari ID Kategori (Helper)
    protected function getCategoryIdByName($categoryName) {
        $categoryModel = new CategoryModel();
        $cat = $categoryModel->where('name', $categoryName)->first();
        return $cat ? $cat['id'] : 1; // Default ke ID 1 jika tidak ditemukan
    }

    // 2. METHOD UTAMA: Cari atau Buat Buku Eksternal (INI YANG HILANG!)
    public function findOrCreateExternal($data)
    {
        // Cek apakah buku sudah ada berdasarkan Judul dan Penulis
        $existingBook = $this->where('title', $data['title'])
                             ->where('author', $data['author'])
                             ->first();

        if ($existingBook) {
            // Jika ada, kembalikan ID-nya
            return $existingBook['id'];
        }

        // Jika belum ada, kita buat baru
        $newBookData = [
            'title'       => $data['title'],
            'author'      => $data['author'],
            'cover_url'   => $data['cover_url'],
            'description' => $data['description'] ?? 'Deskripsi dari OpenLibrary',
            // Kita set kategori default (misal "Umum" atau ID 1) karena OpenLib kategorinya string acak
            'category_id' => 1, 
        ];

        $this->insert($newBookData);
        return $this->insertID(); // Kembalikan ID baru
    }

    // 3. Fetch Buku untuk Home (dengan Search & Filter)
    public function getBooksWithCategoryAndSavedStatus(int $userId, ?string $categoryName = null, string $sort = 'latest', ?string $search = null): array
    {
        $selectFields = [
            'books.id',
            'books.title',
            'books.author',
            'books.cover_url',
            'books.description',
            'categories.name AS category_name',
            'CASE WHEN usb.book_id IS NOT NULL THEN 1 ELSE 0 END AS is_saved',
        ];

        $builder = $this->select(implode(', ', $selectFields));
        // Fix Raw SQL Select
        $builder->select('CASE WHEN usb.book_id IS NOT NULL THEN 1 ELSE 0 END AS is_saved', false);

        $builder->join('categories', 'categories.id = books.category_id', 'left')
                ->join('user_saved_books usb', 'usb.book_id = books.id AND usb.user_id = ' . $this->db->escape($userId), 'left');

        // Filter Kategori
        if (!empty($categoryName) && $categoryName !== 'Semua') {
             $categoryModel = new CategoryModel();
             $category = $categoryModel->getCategoryByName($categoryName);
             if ($category) {
                 $builder->where('books.category_id', $category['id']);
             } else {
                 $builder->where('books.id', 0);
             }
        }

        // Search
        if (!empty($search)) {
            $builder->groupStart()
                    ->like('books.title', $search, 'both')
                    ->orLike('books.author', $search, 'both')
                    ->groupEnd();
        }

        // Sort
        switch ($sort) {
            case 'title_asc':
                $builder->orderBy('books.title', 'ASC');
                break;
            default:
                $builder->orderBy('books.created_at', 'DESC');
                break;
        }

        return $builder->get()->getResultArray();
    }

    // 4. Fetch My Books
    public function getSavedBooks(int $userId, ?string $search = null): array
    {
        $selectFields = [
            'books.id',
            'books.title',
            'books.author',
            'books.cover_url',
            'books.description',
            'categories.name AS category_name',
            '1 AS is_saved',
        ];

        $builder = $this->select(implode(', ', $selectFields));
        $builder->select('1 AS is_saved', false); // Fix Raw SQL

        $builder->join('user_saved_books usb', 'usb.book_id = books.id', 'inner')
                ->where('usb.user_id', $userId)
                ->join('categories', 'categories.id = books.category_id', 'left');

        if (!empty($search)) {
            $builder->groupStart()
                    ->like('books.title', $search, 'both')
                    ->orLike('books.author', $search, 'both')
                    ->groupEnd();
        }

        return $builder->get()->getResultArray();
    }
}