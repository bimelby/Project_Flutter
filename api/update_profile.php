<?php
file_put_contents('debug_post.txt', print_r($_POST, true));
file_put_contents('debug_files.txt', print_r($_FILES, true));
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Max-Age: 3600");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

include_once 'config/database.php';

$database = new Database();
$db = $database->getConnection();

// Verify token
$headers = getallheaders();
$token = isset($headers['Authorization']) ? str_replace('Bearer ', '', $headers['Authorization']) : '';

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

if (empty($token)) {
    http_response_code(401);
    echo json_encode(array("message" => "Access denied. Token required."));
    exit();
}

// Verify user
$user_query = "SELECT id FROM users WHERE token = :token";
$user_stmt = $db->prepare($user_query);
$user_stmt->bindParam(":token", $token);
$user_stmt->execute();

if ($user_stmt->rowCount() == 0) {
    http_response_code(401);
    echo json_encode(array("message" => "Invalid token"));
    exit();
}

$user_data = $user_stmt->fetch(PDO::FETCH_ASSOC);
$user_id = $user_data['id'];

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    file_put_contents('debug_post.txt', print_r($_POST, true));
    file_put_contents('debug_files.txt', print_r($_FILES, true));
    
    $name = $_POST['name'] ?? '';
    $password = $_POST['password'] ?? '';
    
    if (empty($name)) {
        http_response_code(400);
        echo json_encode(array("message" => "Name is required"));
        exit();
    }
    
    // Update profile
    if (!empty($password)) {
        // Update with new password
        $hashed_password = password_hash($password, PASSWORD_DEFAULT);
        $query = "UPDATE users SET name = :name, password = :password, updated_at = NOW() WHERE id = :user_id";
        $stmt = $db->prepare($query);
        $stmt->bindParam(":name", $name);
        $stmt->bindParam(":password", $hashed_password);
        $stmt->bindParam(":user_id", $user_id);
    } else {
        // Update without password change
        $query = "UPDATE users SET name = :name, updated_at = NOW() WHERE id = :user_id";
        $stmt = $db->prepare($query);
        $stmt->bindParam(":name", $name);
        $stmt->bindParam(":user_id", $user_id);
    }
    
    if ($stmt->execute()) {
        http_response_code(200);
        echo json_encode(array("message" => "Profile updated successfully"));
    } else {
        http_response_code(500);
        echo json_encode(array("message" => "Failed to update profile"));
    }
} else {
    http_response_code(405);
    echo json_encode(array("message" => "Method not allowed"));
}
?>
