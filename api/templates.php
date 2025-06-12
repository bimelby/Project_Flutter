<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Max-Age: 3600");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

include_once 'config/database.php';

$database = new Database();
$db = $database->getConnection();

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}
if ($_SERVER['REQUEST_METHOD'] == 'GET') {
    // Get all templates
    $query = "SELECT * FROM templates ORDER BY category, name";
    $stmt = $db->prepare($query);
    $stmt->execute();
    
    $templates = array();
    
    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        $template = array(
            "id" => $row['id'],
            "name" => $row['name'],
            "content" => $row['content'],
            "category" => $row['category'],
            "icon" => $row['icon'],
            "description" => $row['description'],
            "is_default" => $row['is_default']
        );
        array_push($templates, $template);
    }
    
    http_response_code(200);
    echo json_encode($templates);
    
} elseif ($_SERVER['REQUEST_METHOD'] == 'POST') {
    // Use template to create entry
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

    $user_data = $user_stmt->fetch(PDO::FETCH_ASSOC);
    $user_id = $user_data['id'];
    
    $template_id = $_POST['template_id'] ?? '';
    $mood = $_POST['mood'] ?? 'Happy';
    
    if (empty($template_id)) {
        http_response_code(400);
        echo json_encode(array("message" => "Template ID is required"));
        exit();
    }
    
    // Get template
    $template_query = "SELECT * FROM templates WHERE id = :template_id";
    $template_stmt = $db->prepare($template_query);
    $template_stmt->bindParam(":template_id", $template_id);
    $template_stmt->execute();
    
    if ($template_stmt->rowCount() == 0) {
        http_response_code(404);
        echo json_encode(array("message" => "Template not found"));
        exit();
    }
    
    $template = $template_stmt->fetch(PDO::FETCH_ASSOC);
    
    // Replace placeholders in template content
    $content = $template['content'];
    $content = str_replace('${date}', date('Y-m-d'), $content);
    $content = str_replace('${mood}', $mood, $content);
    
    // Create entry from template
    $entry_query = "INSERT INTO entries (user_id, title, content, mood, category, template_id, created_at) 
                    VALUES (:user_id, :title, :content, :mood, :category, :template_id, NOW())";
    
    $entry_stmt = $db->prepare($entry_query);
    $entry_stmt->bindParam(":user_id", $user_id);
    $entry_stmt->bindParam(":title", $template['name']);
    $entry_stmt->bindParam(":content", $content);
    $entry_stmt->bindParam(":mood", $mood);
    $entry_stmt->bindParam(":category", $template['category']);
    $entry_stmt->bindParam(":template_id", $template_id);
    
    if ($entry_stmt->execute()) {
        $entry_id = $db->lastInsertId();
        
        http_response_code(201);
        echo json_encode(array(
            "message" => "Entry created from template successfully",
            "entry_id" => $entry_id,
            "template_used" => $template['name']
        ));
    } else {
        http_response_code(500);
        echo json_encode(array("message" => "Failed to create entry from template"));
    }
} else {
    http_response_code(405);
    echo json_encode(array("message" => "Method not allowed"));
}
?>
