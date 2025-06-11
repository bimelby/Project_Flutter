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
    // Get user's entries
    $page = isset($_GET['page']) ? (int)$_GET['page'] : 1;
    $limit = isset($_GET['limit']) ? (int)$_GET['limit'] : 20;
    $offset = ($page - 1) * $limit;
    
    $category = isset($_GET['category']) ? $_GET['category'] : '';
    $mood = isset($_GET['mood']) ? $_GET['mood'] : '';
    $search = isset($_GET['search']) ? $_GET['search'] : '';
    
    $where_conditions = array("user_id = :user_id");
    $params = array(":user_id" => $user_id);
    
    if (!empty($category)) {
        $where_conditions[] = "category = :category";
        $params[":category"] = $category;
    }
    
    if (!empty($mood)) {
        $where_conditions[] = "mood = :mood";
        $params[":mood"] = $mood;
    }
    
    if (!empty($search)) {
        $where_conditions[] = "(title LIKE :search OR content LIKE :search)";
        $params[":search"] = "%$search%";
    }
    
    $where_clause = implode(" AND ", $where_conditions);
    
    // Get total count
    $count_query = "SELECT COUNT(*) as total FROM entries WHERE $where_clause";
    $count_stmt = $db->prepare($count_query);
    foreach ($params as $key => $value) {
        $count_stmt->bindValue($key, $value);
    }
    $count_stmt->execute();
    $total_count = $count_stmt->fetch(PDO::FETCH_ASSOC)['total'];
    
    // Get entries
    $query = "SELECT id, user_id, title, content, mood, category, image_url, is_quick_note, template_id, created_at as date, updated_at 
              FROM entries 
              WHERE $where_clause 
              ORDER BY created_at DESC 
              LIMIT :limit OFFSET :offset";
    
    $stmt = $db->prepare($query);
    foreach ($params as $key => $value) {
        $stmt->bindValue($key, $value);
    }
    $stmt->bindValue(":limit", $limit, PDO::PARAM_INT);
    $stmt->bindValue(":offset", $offset, PDO::PARAM_INT);
    $stmt->execute();
    
    $entries = array();
    
    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        $entry = array(
            "id" => $row['id'],
            "user_id" => $row['user_id'],
            "title" => $row['title'],
            "content" => $row['content'],
            "mood" => $row['mood'],
            "category" => $row['category'],
            "image_url" => $row['image_url'],
            "is_quick_note" => $row['is_quick_note'],
            "template_id" => $row['template_id'],
            "date" => $row['date'],
            "updated_at" => $row['updated_at']
        );
        array_push($entries, $entry);
    }
    
    http_response_code(200);
    echo json_encode(array(
        "entries" => $entries,
        "pagination" => array(
            "current_page" => $page,
            "total_pages" => ceil($total_count / $limit),
            "total_entries" => $total_count,
            "entries_per_page" => $limit
        )
    ));
    
} elseif ($_SERVER['REQUEST_METHOD'] == 'POST') {
    // Add new entry
    $title = $_POST['title'] ?? '';
    $content = $_POST['content'] ?? '';
    $mood = $_POST['mood'] ?? 'Happy';
    $category = $_POST['category'] ?? 'Personal';
    $is_quick_note = isset($_POST['is_quick_note']) ? (int)$_POST['is_quick_note'] : 0;
    $template_id = $_POST['template_id'] ?? null;
    
    if (empty($title) || empty($content)) {
        http_response_code(400);
        echo json_encode(array("message" => "Title and content are required"));
        exit();
    }
    
    $image_url = null;
    
    // Handle image upload
    if (isset($_FILES['image']) && $_FILES['image']['error'] == 0) {
        $upload_dir = 'uploads/entries/';
        if (!file_exists($upload_dir)) {
            mkdir($upload_dir, 0777, true);
        }
        
        $file_extension = pathinfo($_FILES['image']['name'], PATHINFO_EXTENSION);
        $allowed_extensions = array('jpg', 'jpeg', 'png', 'gif');
        
        if (in_array(strtolower($file_extension), $allowed_extensions)) {
            $file_name = 'entry_' . $user_id . '_' . time() . '.' . $file_extension;
            $file_path = $upload_dir . $file_name;
            
            if (move_uploaded_file($_FILES['image']['tmp_name'], $file_path)) {
                $image_url = 'http://' . $_SERVER['HTTP_HOST'] . '/foshmed/api/' . $file_path;
            }
        }
    }
    
    $query = "INSERT INTO entries (user_id, title, content, mood, category, image_url, is_quick_note, template_id, created_at) 
              VALUES (:user_id, :title, :content, :mood, :category, :image_url, :is_quick_note, :template_id, NOW())";
    
    $stmt = $db->prepare($query);
    $stmt->bindParam(":user_id", $user_id);
    $stmt->bindParam(":title", $title);
    $stmt->bindParam(":content", $content);
    $stmt->bindParam(":mood", $mood);
    $stmt->bindParam(":category", $category);
    $stmt->bindParam(":image_url", $image_url);
    $stmt->bindParam(":is_quick_note", $is_quick_note);
    $stmt->bindParam(":template_id", $template_id);
    
    if ($stmt->execute()) {
        $entry_id = $db->lastInsertId();
        
        // Update user statistics
        $stats_query = "INSERT INTO user_statistics (user_id, total_entries, last_entry_date) 
                        VALUES (:user_id, 1, CURDATE()) 
                        ON DUPLICATE KEY UPDATE 
                        total_entries = total_entries + 1, 
                        last_entry_date = CURDATE()";
        $stats_stmt = $db->prepare($stats_query);
        $stats_stmt->bindParam(":user_id", $user_id);
        $stats_stmt->execute();
        
        http_response_code(201);
        echo json_encode(array(
            "message" => "Entry created successfully",
            "entry_id" => $entry_id,
            "image_url" => $image_url
        ));
    } else {
        http_response_code(500);
        echo json_encode(array("message" => "Failed to create entry"));
    }
    
} elseif ($_SERVER['REQUEST_METHOD'] == 'PUT') {
    // Update entry
    parse_str(file_get_contents("php://input"), $put_data);
    
    $entry_id = $put_data['entry_id'] ?? '';
    $title = $put_data['title'] ?? '';
    $content = $put_data['content'] ?? '';
    $mood = $put_data['mood'] ?? '';
    $category = $put_data['category'] ?? '';
    
    if (empty($entry_id)) {
        http_response_code(400);
        echo json_encode(array("message" => "Entry ID is required"));
        exit();
    }
    
    // Verify entry belongs to user
    $verify_query = "SELECT id FROM entries WHERE id = :entry_id AND user_id = :user_id";
    $verify_stmt = $db->prepare($verify_query);
    $verify_stmt->bindParam(":entry_id", $entry_id);
    $verify_stmt->bindParam(":user_id", $user_id);
    $verify_stmt->execute();
    
    if ($verify_stmt->rowCount() == 0) {
        http_response_code(404);
        echo json_encode(array("message" => "Entry not found or access denied"));
        exit();
    }
    
    $query = "UPDATE entries SET title = :title, content = :content, mood = :mood, category = :category, updated_at = NOW() 
              WHERE id = :entry_id AND user_id = :user_id";
    
    $stmt = $db->prepare($query);
    $stmt->bindParam(":title", $title);
    $stmt->bindParam(":content", $content);
    $stmt->bindParam(":mood", $mood);
    $stmt->bindParam(":category", $category);
    $stmt->bindParam(":entry_id", $entry_id);
    $stmt->bindParam(":user_id", $user_id);
    
    if ($stmt->execute()) {
        http_response_code(200);
        echo json_encode(array("message" => "Entry updated successfully"));
    } else {
        http_response_code(500);
        echo json_encode(array("message" => "Failed to update entry"));
    }
    
} elseif ($_SERVER['REQUEST_METHOD'] == 'DELETE') {
    // Delete entry
    parse_str(file_get_contents("php://input"), $delete_data);
    
    $entry_id = $delete_data['entry_id'] ?? '';
    
    if (empty($entry_id)) {
        http_response_code(400);
        echo json_encode(array("message" => "Entry ID is required"));
        exit();
    }
    
    // Get entry details first (for image deletion and verification)
    $select_query = "SELECT image_url FROM entries WHERE id = :entry_id AND user_id = :user_id";
    $select_stmt = $db->prepare($select_query);
    $select_stmt->bindParam(":entry_id", $entry_id);
    $select_stmt->bindParam(":user_id", $user_id);
    $select_stmt->execute();
    if ($select_stmt->rowCount() > 0) {
        $entry_data = $select_stmt->fetch(PDO::FETCH_ASSOC);
        
        // Delete entry from database
        $delete_query = "DELETE FROM entries WHERE id = :entry_id AND user_id = :user_id";
        $delete_stmt = $db->prepare($delete_query);
        $delete_stmt->bindParam(":entry_id", $entry_id);
        $delete_stmt->bindParam(":user_id", $user_id);
        
        if ($delete_stmt->execute()) {
            // Delete associated image file if exists
            if (!empty($entry_data['image_url'])) {
                $image_path = str_replace('http://' . $_SERVER['HTTP_HOST'] . '/foshmed/api/', '', $entry_data['image_url']);
                if (file_exists($image_path)) {
                    unlink($image_path);
                }
            }
            
            // Update user statistics
            $stats_query = "UPDATE user_statistics SET total_entries = total_entries - 1 WHERE user_id = :user_id";
            $stats_stmt = $db->prepare($stats_query);
            $stats_stmt->bindParam(":user_id", $user_id);
            $stats_stmt->execute();
            
            http_response_code(200);
            echo json_encode(array("message" => "Entry deleted successfully"));
        } else {
            http_response_code(500);
            echo json_encode(array("message" => "Failed to delete entry"));
        }
    } else {
        http_response_code(404);
        echo json_encode(array("message" => "Entry not found or access denied"));
    }
} else {
    http_response_code(405);
    echo json_encode(array("message" => "Method not allowed"));
}
?>
