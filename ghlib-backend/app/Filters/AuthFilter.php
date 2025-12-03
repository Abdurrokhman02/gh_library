<?php

namespace App\Filters;

use CodeIgniter\Filters\FilterInterface;
use CodeIgniter\HTTP\RequestInterface;
use CodeIgniter\HTTP\ResponseInterface;
use Firebase\JWT\JWT;
use Firebase\JWT\Key;

class AuthFilter implements FilterInterface
{
    public function before(RequestInterface $request, $arguments = null)
    {
        $header = $request->getServer('HTTP_AUTHORIZATION');
        
        // Cek jika header Authorization tidak ada
        if (! $header) {
            return service('response')
                ->setStatusCode(401)
                ->setJSON(['status' => 401, 'message' => 'Token akses diperlukan (401 Unauthorized)']); //
        }

        // Ambil token dari header 'Bearer [token]'
        $token = explode(' ', $header)[1];

        try {
            $key = getenv('JWT_SECRET_KEY');
            $decoded = JWT::decode($token, new Key($key, 'HS256'));
            
            // Simpan user ID dari token ke properti request
            $request->user_id = $decoded->user_id; 
        } catch (\Exception $e) {
            // Token tidak valid atau expired
            return service('response')
                ->setStatusCode(401)
                ->setJSON(['status' => 401, 'message' => 'Token tidak valid atau kedaluwarsa']);
        }
    }

    public function after(RequestInterface $request, ResponseInterface $response, $arguments = null)
    {
        // ...
    }
}