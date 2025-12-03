<?php

namespace App\Models;

use CodeIgniter\Model;

class UserSavedBookModel extends Model
{
    protected $table            = 'user_saved_books';
    protected $primaryKey       = 'id';
    protected $useAutoIncrement = true;
    protected $allowedFields    = ['user_id', 'book_id'];
}