<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
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
    // Get user's reminders
    $query = "SELECT * FROM reminders WHERE user_id = :user_id ORDER BY reminder_datetime ASC";
    $stmt = $db->prepare($query);
    $stmt->bindParam(":user_id", $user_id);
    $stmt->execute();
    
    $reminders = array();
    
    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        $reminder = array(
            "id" => $row['id'],
            "entry_id" => $row['entry_id'],
            "title" => $row['title'],
            "description" => $row['description'],
            "date_time" => $row['reminder_datetime'],
            "is_active" => $row['is_active'],
            "type" => $row['reminder_type']
        );
        array_push($reminders, $reminder);
    }
    
    http_response_code(200);
    echo json_encode($reminders);
    
} elseif ($_SERVER['REQUEST_METHOD'] == 'POST') {
    // Add new reminder
    $title = $_POST['title'] ?? '';
    $description = $_POST['description'] ?? '';
    $reminder_datetime = $_POST['reminder_datetime'] ?? '';
    $reminder_type = $_POST['reminder_type'] ?? 'custom';
    $entry_id = $_POST['entry_id'] ?? null;
    
    if (empty($title) || empty($reminder_datetime)) {
        http_response_code(400);
        echo json_encode(array("message" => "Title and datetime are required"));
        exit();
    }
    
    $query = "INSERT INTO reminders (user_id, entry_id, title, description, reminder_datetime, reminder_type, created_at) 
              VALUES (:user_id, :entry_id, :title, :description, :reminder_datetime, :reminder_type, NOW())";
    
    $stmt = $db->prepare($query);
    $stmt->bindParam(":user_id", $user_id);
    $stmt->bindParam(":entry_id", $entry_id);
    $stmt->bindParam(":title", $title);
    $stmt->bindParam(":description", $description);
    $stmt->bindParam(":reminder_datetime", $reminder_datetime);
    $stmt->bindParam(":reminder_type", $reminder_type);
    
    if ($stmt->execute()) {
        $reminder_id = $db->lastInsertId();
        
        http_response_code(201);
        echo json_encode(array(
            "message" => "Reminder created successfully",
            "reminder_id" => $reminder_id
        ));
    } else {
        http_response_code(500);
        echo json_encode(array("message" => "Failed to create reminder"));
    }
    
} elseif ($_SERVER['REQUEST_METHOD'] == 'PUT') {
    // Update reminder
    parse_str(file_get_contents("php://input"), $put_data);
    
    $reminder_id = $put_data['reminder_id'] ?? '';
    $title = $put_data['title'] ?? '';
    $description = $put_data['description'] ?? '';
    $reminder_datetime = $put_data['reminder_datetime'] ?? '';
    $is_active = $put_data['is_active'] ?? 1;
    
    if (empty($reminder_id)) {
        http_response_code(400);
        echo json_encode(array("message" => "Reminder ID is required"));
        exit();
    }
    
    $query = "UPDATE reminders SET title = :title, description = :description, 
              reminder_datetime = :reminder_datetime, is_active = :is_active, updated_at = NOW() 
              WHERE id = :reminder_id AND user_id = :user_id";
    
    $stmt = $db->prepare($query);
    $stmt->bindParam(":title", $title);
    $stmt->bindParam(":description", $description);
    $stmt->bindParam(":reminder_datetime", $reminder_datetime);
    $stmt->bindParam(":is_active", $is_active);
    $stmt->bindParam(":reminder_id", $reminder_id);
    $stmt->bindParam(":user_id", $user_id);
    
    if ($stmt->execute()) {
        http_response_code(200);
        echo json_encode(array("message" => "Reminder updated successfully"));
    } else {
        http_response_code(500);
        echo json_encode(array("message" => "Failed to update reminder"));
    }
    
} elseif ($_SERVER['REQUEST_METHOD'] == 'DELETE') {
    // Delete reminder
    parse_str(file_get_contents("php://input"), $delete_data);
    
    $reminder_id = $delete_data['reminder_id'] ?? '';
    
    if (empty($reminder_id)) {
        http_response_code(400);
        echo json_encode(array("message" => "Reminder ID is required"));
        exit();
    }
    
    $query = "DELETE FROM reminders WHERE id = :reminder_id AND user_id = :user_id";
    $stmt = $db->prepare($query);
    $stmt->bindParam(":reminder_id", $reminder_id);
    $stmt->bindParam(":user_id", $user_id);
    
    if ($stmt->execute()) {
        http_response_code(200);
        echo json_encode(array("message" => "Reminder deleted successfully"));
    } else {
        http_response_code(500);
        echo json_encode(array("message" => "Failed to delete reminder"));
    }
} else {
    http_response_code(405);
    echo json_encode(array("message" => "Method not allowed"));
}
?>
