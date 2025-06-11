<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
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

if ($_SERVER['REQUEST_METHOD'] == 'GET') {
    // Get user's quick notes
    $query = "SELECT * FROM entries WHERE user_id = :user_id AND is_quick_note = 1 ORDER BY created_at DESC";
    $stmt = $db->prepare($query);
    $stmt->bindParam(":user_id", $user_id);
    $stmt->execute();
    
    $quick_notes = array();
    
    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        $note = array(
            "id" => $row['id'],
            "title" => $row['title'],
            "content" => $row['content'],
            "mood" => $row['mood'],
            "category" => $row['category'],
            "created_at" => $row['created_at']
        );
        array_push($quick_notes, $note);
    }
    
    http_response_code(200);
    echo json_encode($quick_notes);
    
} elseif ($_SERVER['REQUEST_METHOD'] == 'POST') {
    // Add new quick note
    $content = $_POST['content'] ?? '';
    $mood = $_POST['mood'] ?? 'Happy';
    $title = $_POST['title'] ?? 'Quick Note';
    
    if (empty($content)) {
        http_response_code(400);
        echo json_encode(array("message" => "Content is required"));
        exit();
    }
    
    $query = "INSERT INTO entries (user_id, title, content, mood, category, is_quick_note, created_at) 
              VALUES (:user_id, :title, :content, :mood, 'Personal', 1, NOW())";
    
    $stmt = $db->prepare($query);
    $stmt->bindParam(":user_id", $user_id);
    $stmt->bindParam(":title", $title);
    $stmt->bindParam(":content", $content);
    $stmt->bindParam(":mood", $mood);
    
    if ($stmt->execute()) {
        $note_id = $db->lastInsertId();
        
        http_response_code(201);
        echo json_encode(array(
            "message" => "Quick note saved successfully",
            "note_id" => $note_id
        ));
    } else {
        http_response_code(500);
        echo json_encode(array("message" => "Failed to save quick note"));
    }
} else {
    http_response_code(405);
    echo json_encode(array("message" => "Method not allowed"));
}
?>
