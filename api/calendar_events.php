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
    // Get calendar events for a specific date range
    $start_date = $_GET['start_date'] ?? date('Y-m-01'); // First day of current month
    $end_date = $_GET['end_date'] ?? date('Y-m-t'); // Last day of current month
    
    // Get entries as events
    $entries_query = "SELECT id, title, content, mood, category, created_at as event_date, 'entry' as event_type 
                      FROM entries 
                      WHERE user_id = :user_id 
                      AND DATE(created_at) BETWEEN :start_date AND :end_date 
                      ORDER BY created_at DESC";
    
    $entries_stmt = $db->prepare($entries_query);
    $entries_stmt->bindParam(":user_id", $user_id);
    $entries_stmt->bindParam(":start_date", $start_date);
    $entries_stmt->bindParam(":end_date", $end_date);
    $entries_stmt->execute();
    
    // Get reminders as events
    $reminders_query = "SELECT id, title, description, reminder_datetime as event_date, reminder_type as event_type 
                        FROM reminders 
                        WHERE user_id = :user_id 
                        AND DATE(reminder_datetime) BETWEEN :start_date AND :end_date 
                        AND is_active = 1 
                        ORDER BY reminder_datetime ASC";
    
    $reminders_stmt = $db->prepare($reminders_query);
    $reminders_stmt->bindParam(":user_id", $user_id);
    $reminders_stmt->bindParam(":start_date", $start_date);
    $reminders_stmt->bindParam(":end_date", $end_date);
    $reminders_stmt->execute();
    
    // Get custom calendar events
    $events_query = "SELECT id, title, description, event_date, event_time, event_type 
                     FROM calendar_events 
                     WHERE user_id = :user_id 
                     AND event_date BETWEEN :start_date AND :end_date 
                     ORDER BY event_date ASC, event_time ASC";
    
    $events_stmt = $db->prepare($events_query);
    $events_stmt->bindParam(":user_id", $user_id);
    $events_stmt->bindParam(":start_date", $start_date);
    $events_stmt->bindParam(":end_date", $end_date);
    $events_stmt->execute();
    
    $events = array();
    
    // Add entries
    while ($row = $entries_stmt->fetch(PDO::FETCH_ASSOC)) {
        $events[] = array(
            "id" => "entry_" . $row['id'],
            "title" => $row['title'],
            "description" => substr($row['content'], 0, 100) . "...",
            "date" => date('Y-m-d', strtotime($row['event_date'])),
            "time" => date('H:i', strtotime($row['event_date'])),
            "type" => "entry",
            "mood" => $row['mood'],
            "category" => $row['category']
        );
    }
    
    // Add reminders
    while ($row = $reminders_stmt->fetch(PDO::FETCH_ASSOC)) {
        $events[] = array(
            "id" => "reminder_" . $row['id'],
            "title" => $row['title'],
            "description" => $row['description'],
            "date" => date('Y-m-d', strtotime($row['event_date'])),
            "time" => date('H:i', strtotime($row['event_date'])),
            "type" => $row['event_type']
        );
    }
    
    // Add custom events
    while ($row = $events_stmt->fetch(PDO::FETCH_ASSOC)) {
        $events[] = array(
            "id" => "event_" . $row['id'],
            "title" => $row['title'],
            "description" => $row['description'],
            "date" => $row['event_date'],
            "time" => $row['event_time'],
            "type" => $row['event_type']
        );
    }
    
    // Sort events by date and time
    usort($events, function($a, $b) {
        $dateCompare = strcmp($a['date'], $b['date']);
        if ($dateCompare === 0) {
            return strcmp($a['time'], $b['time']);
        }
        return $dateCompare;
    });
    
    http_response_code(200);
    echo json_encode($events);
    
} elseif ($_SERVER['REQUEST_METHOD'] == 'POST') {
    // Add custom calendar event
    $title = $_POST['title'] ?? '';
    $description = $_POST['description'] ?? '';
    $event_date = $_POST['event_date'] ?? '';
    $event_time = $_POST['event_time'] ?? null;
    $event_type = $_POST['event_type'] ?? 'custom';
    
    if (empty($title) || empty($event_date)) {
        http_response_code(400);
        echo json_encode(array("message" => "Title and event date are required"));
        exit();
    }
    
    $query = "INSERT INTO calendar_events (user_id, title, description, event_date, event_time, event_type, created_at) 
              VALUES (:user_id, :title, :description, :event_date, :event_time, :event_type, NOW())";
    
    $stmt = $db->prepare($query);
    $stmt->bindParam(":user_id", $user_id);
    $stmt->bindParam(":title", $title);
    $stmt->bindParam(":description", $description);
    $stmt->bindParam(":event_date", $event_date);
    $stmt->bindParam(":event_time", $event_time);
    $stmt->bindParam(":event_type", $event_type);
    
    if ($stmt->execute()) {
        $event_id = $db->lastInsertId();
        
        http_response_code(201);
        echo json_encode(array(
            "message" => "Calendar event created successfully",
            "event_id" => $event_id
        ));
    } else {
        http_response_code(500);
        echo json_encode(array("message" => "Failed to create calendar event"));
    }
} else {
    http_response_code(405);
    echo json_encode(array("message" => "Method not allowed"));
}
?>
