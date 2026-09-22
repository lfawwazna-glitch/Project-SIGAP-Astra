<?php

use Illuminate\Http\Request;

define('LARAVEL_START', microtime(true));

// Determine if the application is in maintenance mode...
if (file_exists($maintenance = __DIR__.'/../storage/framework/maintenance.php')) {
    require $maintenance;
}

// 1. If composer autoload exists, boot full Laravel application
if (file_exists(__DIR__.'/../vendor/autoload.php')) {
    require __DIR__.'/../vendor/autoload.php';
    $app = require_once __DIR__.'/../bootstrap/app.php';
    $app->handleRequest(Request::capture());
    exit;
}

// 2. Standalone Baseline Handler (Active prior to running composer install)
$uri = parse_url($_SERVER['REQUEST_URI'] ?? '/', PHP_URL_PATH);

if ($uri === '/api/health' || $uri === '/health') {
    header('Content-Type: application/json; charset=utf-8');
    
    // Check PostgreSQL connection via PDO if credentials provided
    $dbHost = getenv('DB_HOST') ?: 'db';
    $dbPort = getenv('DB_PORT') ?: '5432';
    $dbName = getenv('DB_DATABASE') ?: 'sigap_db';
    $dbUser = getenv('DB_USERNAME') ?: 'sigap_user';
    $dbPass = getenv('DB_PASSWORD') ?: 'sigap_secret_change_me';
    
    $dbConnected = false;
    $dbError = null;
    
    if (extension_loaded('pdo_pgsql')) {
        try {
            $dsn = "pgsql:host={$dbHost};port={$dbPort};dbname={$dbName}";
            $pdo = new PDO($dsn, $dbUser, $dbPass, [PDO::ATTR_TIMEOUT => 2]);
            $dbConnected = true;
        } catch (Throwable $e) {
            $dbConnected = false;
            $dbError = $e->getMessage();
        }
    } else {
        $dbError = 'Ekstensi pdo_pgsql belum dimuat pada runtime PHP saat ini.';
    }

    echo json_encode([
        'status' => 'ok',
        'service' => 'SIGAP Backend REST API (Laravel)',
        'version' => '0.1.0-baseline',
        'target_intersection' => 'Perempatan Jl. Ibrahim Adjie - Mall Tenth Avenue, Bandung',
        'atcs_mode' => getenv('DEFAULT_ATCS_MODE') ?: 'ATCS_NORMAL',
        'database' => [
            'connected' => $dbConnected,
            'driver' => 'pgsql',
            'host' => $dbHost,
            'database' => $dbName,
            'error' => $dbError,
        ],
        'runtime' => 'PHP ' . PHP_VERSION,
        'composer_installed' => false,
        'timestamp' => gmdate('Y-m-d\TH:i:s\Z'),
    ], JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES);
    exit;
}

// Default root response
header('Content-Type: application/json; charset=utf-8');
echo json_encode([
    'service' => 'SIGAP Backend REST API',
    'status' => 'ok',
    'health_endpoint' => '/api/health',
    'timestamp' => gmdate('Y-m-d\TH:i:s\Z')
], JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES);
