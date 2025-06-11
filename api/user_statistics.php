<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: GET, OPTIONS");
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
    // Calculate comprehensive statistics
    
    // Basic counts
    $total_entries_query = "SELECT COUNT(*) as total FROM entries WHERE user_id = :user_id";
    $total_stmt = $db->prepare($total_entries_query);
    $total_stmt->bindParam(":user_id", $user_id);
    $total_stmt->execute();
    $total_entries = $total_stmt->fetch(PDO::FETCH_ASSOC)['total'];
    
    // Mood distribution
    $mood_query = "SELECT mood, COUNT(*) as count FROM entries WHERE user_id = :user_id GROUP BY mood ORDER BY count DESC";
    $mood_stmt = $db->prepare($mood_query);
    $mood_stmt->bindParam(":user_id", $user_id);
    $mood_stmt->execute();
    
    $mood_stats = array();
    $dominant_mood = '';
    $max_mood_count = 0;
    
    while ($row = $mood_stmt->fetch(PDO::FETCH_ASSOC)) {
        $mood_stats[$row['mood']] = $row['count'];
        if ($row['count'] > $max_mood_count) {
            $max_mood_count = $row['count'];
            $dominant_mood = $row['mood'];
        }
    }
    
    // Category distribution
    $category_query = "SELECT category, COUNT(*) as count FROM entries WHERE user_id = :user_id GROUP BY category ORDER BY count DESC";
    $category_stmt = $db->prepare($category_query);
    $category_stmt->bindParam(":user_id", $user_id);
    $category_stmt->execute();
    
    $category_stats = array();
    $favorite_category = '';
    $max_category_count = 0;
    
    while ($row = $category_stmt->fetch(PDO::FETCH_ASSOC)) {
        $category_stats[$row['category']] = $row['count'];
        if ($row['count'] > $max_category_count) {
            $max_category_count = $row['count'];
            $favorite_category = $row['category'];
        }
    }
    
    // Calculate current streak
    $streak_query = "SELECT DATE(created_at) as entry_date FROM entries WHERE user_id = :user_id ORDER BY created_at DESC";
    $streak_stmt = $db->prepare($streak_query);
    $streak_stmt->bindParam(":user_id", $user_id);
    $streak_stmt->execute();
    
    $current_streak = 0;
    $longest_streak = 0;
    $temp_streak = 0;
    $last_date = null;
    $dates = array();
    
    while ($row = $streak_stmt->fetch(PDO::FETCH_ASSOC)) {
        $dates[] = $row['entry_date'];
    }
    
    $unique_dates = array_unique($dates);
    sort($unique_dates);
    
    if (!empty($unique_dates)) {
        $current_date = date('Y-m-d');
        $yesterday = date('Y-m-d', strtotime('-1 day'));
        
        // Check if there's an entry today or yesterday to start streak
        if (in_array($current_date, $unique_dates) || in_array($yesterday, $unique_dates)) {
            $check_date = in_array($current_date, $unique_dates) ? $current_date : $yesterday;
            
            foreach (array_reverse($unique_dates) as $date) {
                if ($date === $check_date) {
                    $current_streak++;
                    $temp_streak++;
                    $check_date = date('Y-m-d', strtotime($check_date . ' -1 day'));
                } else if ($date === $check_date) {
                    $current_streak++;
                    $temp_streak++;
                    $check_date = date('Y-m-d', strtotime($check_date . ' -1 day'));
                } else {
                    break;
                }
            }
        }
        
        // Calculate longest streak
        $temp_streak = 1;
        for ($i = 1; $i < count($unique_dates); $i++) {
            $prev_date = new DateTime($unique_dates[$i-1]);
            $curr_date = new DateTime($unique_dates[$i]);
            $diff = $curr_date->diff($prev_date)->days;
            
            if ($diff === 1) {
                $temp_streak++;
            } else {
                $longest_streak = max($longest_streak, $temp_streak);
                $temp_streak = 1;
            }
        }
        $longest_streak = max($longest_streak, $temp_streak);
    }
    
    // Recent activity (last 30 days)
    $recent_query = "SELECT DATE(created_at) as date, COUNT(*) as count 
                     FROM entries 
                     WHERE user_id = :user_id 
                     AND created_at >= DATE_SUB(NOW(), INTERVAL 30 DAY) 
                     GROUP BY DATE(created_at) 
                     ORDER BY date DESC";
    $recent_stmt = $db->prepare($recent_query);
    $recent_stmt->bindParam(":user_id", $user_id);
    $recent_stmt->execute();
    
    $recent_activity = array();
    while ($row = $recent_stmt->fetch(PDO::FETCH_ASSOC)) {
        $recent_activity[] = array(
            "date" => $row['date'],
            "entries" => $row['count']
        );
    }
    
    // Quick notes count
    $quick_notes_query = "SELECT COUNT(*) as total FROM entries WHERE user_id = :user_id AND is_quick_note = 1";
    $quick_notes_stmt = $db->prepare($quick_notes_query);
    $quick_notes_stmt->bindParam(":user_id", $user_id);
    $quick_notes_stmt->execute();
    $quick_notes_count = $quick_notes_stmt->fetch(PDO::FETCH_ASSOC)['total'];
    
    // Active reminders count
    $reminders_query = "SELECT COUNT(*) as total FROM reminders WHERE user_id = :user_id AND is_active = 1";
    $reminders_stmt = $db->prepare($reminders_query);
    $reminders_stmt->bindParam(":user_id", $user_id);
    $reminders_stmt->execute();
    $active_reminders = $reminders_stmt->fetch(PDO::FETCH_ASSOC)['total'];
    
    // Average entries per week
    $first_entry_query = "SELECT MIN(created_at) as first_entry FROM entries WHERE user_id = :user_id";
    $first_entry_stmt = $db->prepare($first_entry_query);
    $first_entry_stmt->bindParam(":user_id", $user_id);
    $first_entry_stmt->execute();
    $first_entry_result = $first_entry_stmt->fetch(PDO::FETCH_ASSOC);
    
    $avg_per_week = 0;
    if ($first_entry_result['first_entry']) {
        $first_entry_date = new DateTime($first_entry_result['first_entry']);
        $now = new DateTime();
        $weeks = $now->diff($first_entry_date)->days / 7;
        $avg_per_week = $weeks > 0 ? round($total_entries / $weeks, 1) : 0;
    }
    
    $statistics = array(
        "total_entries" => (int)$total_entries,
        "current_streak" => $current_streak,
        "longest_streak" => $longest_streak,
        "dominant_mood" => $dominant_mood,
        "favorite_category" => $favorite_category,
        "mood_distribution" => $mood_stats,
        "category_distribution" => $category_stats,
        "recent_activity" => $recent_activity,
        "quick_notes_count" => (int)$quick_notes_count,
        "active_reminders" => (int)$active_reminders,
        "average_entries_per_week" => $avg_per_week,
        "total_categories" => count($category_stats),
        "total_moods_used" => count($mood_stats)
    );
    
    http_response_code(200);
    echo json_encode($statistics);
} else {
    http_response_code(405);
    echo json_encode(array("message" => "Method not allowed"));
}
?>
