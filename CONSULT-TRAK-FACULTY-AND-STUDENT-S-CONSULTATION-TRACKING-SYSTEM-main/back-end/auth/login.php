<?php
session_start();
require_once __DIR__ . '/../config/db.php';
header('Content-Type: application/json');

// Simple CSRF token generation for session if not present
if (empty($_SESSION['csrf_token'])) {
    $_SESSION['csrf_token'] = bin2hex(random_bytes(32));
}

// Only accept POST with JSON or form
$raw = file_get_contents('php://input');
$data = json_decode($raw, true) ?: ($_POST ?: []);
$email = trim($data['email'] ?? '');
$password = $data['password'] ?? '';

if (empty($email) || empty($password)) {
    echo json_encode(["status" => "error", "message" => "Email and password required."]);
    exit;
}

try {
    $stmt = $pdo->prepare("SELECT user_id, role, email, password_hash, account_status FROM USER_ACCOUNT WHERE email = ? LIMIT 1");
    $stmt->execute([$email]);
    $user = $stmt->fetch();

    if (!$user) {
        echo json_encode(["status" => "error", "message" => "Invalid credentials."]);
        exit;
    }

    if ($user['account_status'] !== 'Active') {
        echo json_encode(["status" => "error", "message" => "Account is not active."]);
        exit;
    }

    if (!password_verify($password, $user['password_hash'])) {
        echo json_encode(["status" => "error", "message" => "Invalid credentials."]);
        exit;
    }

    $_SESSION['user_id'] = $user['user_id'];
    $_SESSION['role'] = $user['role'];
    $_SESSION['email'] = $user['email'];

    echo json_encode([
        "status" => "success",
        "message" => "Login successful.",
        "user" => [
            "user_id" => $user['user_id'],
            "role" => $user['role'],
            "email" => $user['email']
        ]
    ]);
} catch (PDOException $e) {
    error_log("Login error: " . $e->getMessage());
    echo json_encode(["status" => "error", "message" => "Login failed."]);
}
