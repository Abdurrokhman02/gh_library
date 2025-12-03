<?php

namespace App\Controllers\Api;

use App\Models\UserModel;
use CodeIgniter\RESTful\ResourceController;
use Firebase\JWT\JWT;

class AuthController extends ResourceController
{
    /**
     * POST /api/auth/register
     */
    public function register()
    {
        // Aturan validasi minimal
        $rules = [
            'name'     => 'required|min_length[3]',
            'email'    => 'required|valid_email|is_unique[users.email]',
            'password' => 'required|min_length[6]',
        ];

        if (! $this->validate($rules)) {
            return $this->failValidationErrors($this->validator->getErrors()); //
        }

        $userModel = new UserModel();
        $input = $this->request->getJSON(true);

        $data = [
            'name'     => $input['name'],
            'email'    => $input['email'],
            'password_hash' => password_hash($input['password'], PASSWORD_DEFAULT), 
            'profile_picture_url' => 'https://i.imgur.com/3jGZp3u.png',
        ];

        if ($userModel->insert($data)) {
            return $this->respondCreated(['status' => 201, 'message' => 'Registrasi berhasil!']); //
        }

        return $this->failServerError('Gagal melakukan registrasi.');
    }

    /**
     * POST /api/auth/login
     */
    public function login()
    {
        $input = $this->request->getJSON(true);
        $email = $input['email'] ?? '';
        $password = $input['password'] ?? '';

        $userModel = new UserModel();
        $user = $userModel->where('email', $email)->first();

        if (empty($user) || ! password_verify($password, $user['password_hash'])) {
            return $this->failUnauthorized('Email atau password salah.'); //
        }

        // Buat JWT Payload
        $key = getenv('JWT_SECRET_KEY');
        if (empty($key)) {
             // Beri tahu user untuk mengisi .env
             return $this->failServerError('Server error: JWT Key tidak ditemukan di .env.'); 
        }
        $key = trim($key, "'\"");
        $iat = time();
        $exp = $iat + 3600 * 24 * 7; 

        $payload = [
            'iat'     => $iat,
            'exp'     => $exp,
            'user_id' => $user['id'],
            'email'   => $user['email'],
        ];

        $token = JWT::encode($payload, $key, 'HS256');

        return $this->respond([
            'status'  => 200,
            'message' => 'Login berhasil',
            'token'   => $token,
            'user_id' => $user['id'],
        ]);
    }
}