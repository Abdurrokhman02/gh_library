<?php

namespace App\Controllers\Api;

use App\Models\UserModel;
use CodeIgniter\Controller;
use CodeIgniter\API\ResponseTrait;

class UserController extends Controller
{
    use ResponseTrait;

    // GET /api/user/profile
    public function show()
    {
        // AMBIL user_id DARI JWT FILTER
        $userId = $this->request->user_id; // <=== PERUBAHAN UTAMA

        $userModel = new UserModel();
        $user = $userModel->find($userId);

        if (empty($user)) {
            return $this->failNotFound('Pengguna tidak ditemukan.');
        }

        // Hapus password hash sebelum merespons
        unset($user['password_hash']);

        return $this->respond(['status' => 200, 'message' => 'Data profil berhasil dimuat', 'data' => $user]);
    }

    // POST /api/user/update
    public function update()
    {
        // AMBIL user_id DARI JWT FILTER
        $userId = $this->request->user_id; // <=== PERUBAHAN UTAMA

        $input = $this->request->getJSON(true);
        // ... (rest of update logic)
        
        return $this->respondUpdated(['status' => 200, 'message' => 'Profil berhasil diperbarui.']);
    }
}