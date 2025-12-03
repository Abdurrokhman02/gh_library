<?php

namespace Config;

use CodeIgniter\Config\BaseConfig;

class Cors extends BaseConfig
{
    public array $default = [
        // Izinkan semua Origin untuk Development
        'allowedOrigins' => ['*'], 

        'allowedOriginsPatterns' => [],

        // Kredensial tidak diperlukan dalam kasus ini
        'supportsCredentials' => false,

        // Headers yang diizinkan (Content-Type dan untuk otentikasi)
        'allowedHeaders' => [
            'Content-Type', 
            'Authorization',
            'X-API-KEY',
        ], 

        'exposedHeaders' => [],

        // Methods yang diizinkan, termasuk OPTIONS untuk CORS preflight
        'allowedMethods' => [
            'GET', 
            'POST', 
            'PUT', 
            'DELETE', 
            'OPTIONS' 
        ], 

        'maxAge' => 7200,
    ];
}