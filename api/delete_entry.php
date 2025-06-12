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

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    file_put_contents('debug_post.txt', print_r($_POST, true));
    file_put_contents('debug_files.txt', print_r($_FILES, true));
    $entry_id = $_POST['entry_id'] ?? '';
    
    if (empty($entry_id)) {
        http_response_code(400);
        echo json_encode(array("message" => "Entry ID is required"));
        exit();
    }
    
    // Get entry details first (for image deletion)
    $select_query = "SELECT image_url FROM entries WHERE id = :entry_id";
    $select_stmt = $db->prepare($select_query);
    $select_stmt->bindParam(":entry_id", $entry_id);
    $select_stmt->execute();
    
    if ($select_stmt->rowCount() > 0) {
        $entry_data = $select_stmt->fetch(PDO::FETCH_ASSOC);
        
        // Delete entry from database
        $delete_query = "DELETE FROM entries WHERE id = :entry_id";
        $delete_stmt = $db->prepare($delete_query);
        $delete_stmt->bindParam(":entry_id", $entry_id);
        
        if ($delete_stmt->execute()) {
            // Delete associated image file if exists
            if (!empty($entry_data['image_url'])) {
                $image_path = str_replace('http://' . $_SERVER['HTTP_HOST'] . '/foshmed/api/', '', $entry_data['image_url']);
                if (file_exists($image_path)) {
                    unlink($image_path);
                }
            }
            
            http_response_code(200);
            echo json_encode(array("message" => "Entry deleted successfully"));
        } else {
            http_response_code(500);
            echo json_encode(array("message" => "Failed to delete entry"));
        }
    } else {
        http_response_code(404);
        echo json_encode(array("message" => "Entry not found"));
    }
} else {
    http_response_code(405);
    echo json_encode(array("message" => "Method not allowed"));
}
?>
