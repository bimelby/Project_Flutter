<?php
file_put_contents('debug_post.txt', print_r($_POST, true));
file_put_contents('debug_files.txt', print_r($_FILES, true));
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Max-Age: 3600");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

include_once 'config/database.php';

$database = new Database();
$db = $database->getConnection();

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $email = $_POST['email'] ?? '';
    $password = $_POST['password'] ?? '';
    
    if (empty($email) || empty($password)) {
        http_response_code(400);
        echo json_encode(array("message" => "Email and password are required"));
        exit();
    }
    
    // Get user
    $query = "SELECT id, name, email, password FROM users WHERE email = :email";
    $stmt = $db->prepare($query);
    $stmt->bindParam(":email", $email);
    $stmt->execute();
    
    if ($stmt->rowCount() == 1) {
        $row = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if (password_verify($password, $row['password'])) {
            // Generate new token
            $token = bin2hex(random_bytes(32));
            
            // Update token in database
            $update_query = "UPDATE users SET token = :token WHERE id = :id";
            $update_stmt = $db->prepare($update_query);
            $update_stmt->bindParam(":token", $token);
            $update_stmt->bindParam(":id", $row['id']);
            $update_stmt->execute();
            
            http_response_code(200);
            echo json_encode(array(
                "message" => "Login successful",
                "user_id" => $row['id'],
                "name" => $row['name'],
                "token" => $token
            ));
        } else {
            http_response_code(401);
            echo json_encode(array("message" => "Invalid credentials"));
        }
    } else {
        http_response_code(401);
        echo json_encode(array("message" => "Invalid credentials"));
    }
} else {
    http_response_code(405);
    echo json_encode(array("message" => "Method not allowed"));
}
?>