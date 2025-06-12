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


if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}
// Verify token
$headers = getallheaders();
$token = isset($headers['Authorization']) ? str_replace('Bearer ', '', $headers['Authorization']) : '';

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

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $entry_id = $_POST['entry_id'] ?? '';
    $title = $_POST['title'] ?? '';
    $content = $_POST['content'] ?? '';
    $mood = $_POST['mood'] ?? '';
    $category = $_POST['category'] ?? '';
    
    if (empty($entry_id) || empty($title) || empty($content)) {
        http_response_code(400);
        echo json_encode(array("message" => "Required fields are missing"));
        exit();
    }
    
    $image_url = null;
    
    // Handle image upload
    if (isset($_FILES['image']) && $_FILES['image']['error'] == 0) {
        $upload_dir = 'uploads/';
        if (!file_exists($upload_dir)) {
            mkdir($upload_dir, 0777, true);
        }
        
        $file_extension = pathinfo($_FILES['image']['name'], PATHINFO_EXTENSION);
        $file_name = uniqid() . '.' . $file_extension;
        $file_path = $upload_dir . $file_name;
        
        if (move_uploaded_file($_FILES['image']['tmp_name'], $file_path)) {
            $image_url = 'http://' . $_SERVER['HTTP_HOST'] . '/foshmed/api/' . $file_path;
        }
    }
    
    // Update entry
    if ($image_url) {
        $query = "UPDATE entries SET title = :title, content = :content, mood = :mood, category = :category, image_url = :image_url, updated_at = NOW() WHERE id = :entry_id";
        $stmt = $db->prepare($query);
        $stmt->bindParam(":image_url", $image_url);
    } else {
        $query = "UPDATE entries SET title = :title, content = :content, mood = :mood, category = :category, updated_at = NOW() WHERE id = :entry_id";
        $stmt = $db->prepare($query);
    }
    
    $stmt->bindParam(":title", $title);
    $stmt->bindParam(":content", $content);
    $stmt->bindParam(":mood", $mood);
    $stmt->bindParam(":category", $category);
    $stmt->bindParam(":entry_id", $entry_id);
    
    if ($stmt->execute()) {
        http_response_code(200);
        echo json_encode(array(
            "message" => "Entry updated successfully",
            "image_url" => $image_url
        ));
    } else {
        http_response_code(500);
        echo json_encode(array("message" => "Failed to update entry"));
    }
} else {
    http_response_code(405);
    echo json_encode(array("message" => "Method not allowed"));
}
?>
