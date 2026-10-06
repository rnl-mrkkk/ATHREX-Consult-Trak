<?php
require_once __DIR__ . '/../config/db.php';
header('Content-Type: application/json');
$raw = file_get_contents('php://input');
$data = json_decode($raw, true) ?: ($_POST ?: []);
$email = trim($data['email'] ?? '');
$password = $data['password'] ?? '';
$role = $data['role'] ?? 'Student';

if (empty($email) || empty($password)) {
    echo json_encode(["status" => "error", "message" => "Missing fields."]);
    exit;
}

// Validate role
if (!in_array($role, ['Student','Faculty','Admin'])) {
    echo json_encode(["status" => "error", "message" => "Invalid role."]);
    exit;
}

// Check duplicate
$stmt = $pdo->prepare("SELECT user_id FROM USER_ACCOUNT WHERE email = ?");
$stmt->execute([$email]);
if ($stmt->fetch()) {
    echo json_encode(["status" => "error", "message" => "Email already registered."]);
    exit;
}

$hash = password_hash($password, PASSWORD_DEFAULT);
$stmt = $pdo->prepare("INSERT INTO USER_ACCOUNT (role, email, password_hash, account_status) VALUES (?, ?, ?, 'Active')");
try {
    $stmt->execute([$role, $email, $hash]);
    echo json_encode(["status" => "success", "message" => "Registered.", "user_id" => $pdo->lastInsertId()]);
} catch (PDOException $e) {
    error_log("Register error: " . $e->getMessage());
    echo json_encode(["status" => "error", "message" => "Registration failed."]);
}
