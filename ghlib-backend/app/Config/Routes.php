<?php

use CodeIgniter\Router\RouteCollection;

/**
 * @var RouteCollection $routes
 */
$routes->get('/', 'Home::index');

// ==========================================================
// FIX ROUTING UNTUK API (DILINDUNGI DAN PUBLIK)
// ==========================================================

$routes->group('api', function ($routes) {
    
    // 1. RUTE PUBLIK (TIDAK DILINDUNGI OLEH TOKEN)
    // Login dan Registrasi harus di sini agar bisa diakses tanpa token.
    $routes->post('auth/register', 'Api\AuthController::register');
    $routes->post('auth/login', 'Api\AuthController::login'); // <=== FIX UTAMA

    
    // 2. RUTE YANG DILINDUNGI (PERLU TOKEN)
    // Semua endpoint buku dan user harus melewati Filter Auth.
    $routes->group('/', ['filter' => 'auth'], function ($routes) { 
        // Endpoint Buku
        $routes->get('books', 'Api\BookController::index'); 
        $routes->get('my-books', 'Api\MyBookController::index');
        $routes->post('my-books', 'Api\MyBookController::toggle'); 

        // Endpoint User Profile
        $routes->get('user/profile', 'Api\UserController::show');
        $routes->post('user/update', 'Api\UserController::update'); 
    });
});