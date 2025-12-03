<?php

namespace App\Models;

use CodeIgniter\Model;

class CategoryModel extends Model
{
    protected $table            = 'categories';
    protected $primaryKey       = 'id';
    protected $useAutoIncrement = true;
    protected $allowedFields    = ['name'];

    // Method untuk mencari kategori berdasarkan nama
    public function getCategoryByName(string $name): ?array
    {
        return $this->where('name', $name)->first();
    }
}