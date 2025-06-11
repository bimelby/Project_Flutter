<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
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
    if (!isset($_FILES['profile_image_']) || $_FILES['profile_image']['error'] != 0) {
        http_response_code(400);
        echo json_encode(array("message" => "No image file uploaded or upload error"));
        exit();
    }
    
    $upload_dir = 'uploads/profiles/';
    if (!file_exists($upload_dir)) {
        mkdir($upload_dir, 0777, true);
    }
    
    $file_extension = pathinfo($_FILES['profile_image']['name'], PATHINFO_EXTENSION);
    $allowed_extensions = array('jpg', 'jpeg', 'png', 'gif');
    
    if (!in_array(strtolower($file_extension), $allowed_extensions)) {
        http_response_code(400);
        echo json_encode(array("message" => "Invalid file type. Only JPG, JPEG, PNG, and GIF are allowed."));
        exit();
    }
    
    // Check file size (max 5MB)
    if ($_FILES['profile_image']['size'] > 5 * 1024 * 1024) {
        http_response_code(400);
        echo json_encode(array("message" => "File size too large. Maximum 5MB allowed."));
        exit();
    }
    
    $file_name = 'profile_' . $user_id . '_' . time() . '.' . $file_extension;
    $file_path = $upload_dir . $file_name;
    
    if (move_uploaded_file($_FILES['profile_image']['tmp_name'], $file_path)) {
        $image_url = 'http://' . $_SERVER['HTTP_HOST'] . '/foshmed/api/' . $file_path;
        
        // Update user profile image in database
        $update_query = "UPDATE users SET profile_image_url = :profile_image_url, updated_at = NOW() WHERE id = :user_id";
        $update_stmt = $db->prepare($update_query);
        $update_stmt->bindParam(":profile_image_url", $image_url);
        $update_stmt->bindParam(":user_id", $user_id);
        
        if ($update_stmt->execute()) {
            http_response_code(200);
            echo json_encode(array(
                "message" => "Profile image uploaded successfully",
                "profile_image_url" => $image_url
            ));
        } else {
            // Delete uploaded file if database update fails
            unlink($file_path);
            http_response_code(500);
            echo json_encode(array("message" => "Failed to update profile image in database"));
        }
    } else {
        http_response_code(500);
        echo json_encode(array("message" => "Failed to upload image file"));
    }
} else {
    http_response_code(405);
    echo json_encode(array("message" => "Method not allowed"));
}
?>
