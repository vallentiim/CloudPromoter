<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST");

require_once '../config/database.php';

$database = new Database();
$db = $database->getConnection();

$data = json_decode(file_get_contents("php://input"));

if(!empty($data->email) && !empty($data->senha)) {
    
    $query = "SELECT id, name, email, company_name FROM users WHERE email = :email AND password_hash = :senha AND is_active = 1";
    $stmt = $db->prepare($query);
    
    $email = $data->email;
    $senha = md5($data->senha); // Em produção, use password_hash() e password_verify()
    
    $stmt->bindParam(":email", $email);
    $stmt->bindParam(":senha", $senha);
    
    if($stmt->execute()) {
        if($stmt->rowCount() > 0) {
            $user = $stmt->fetch(PDO::FETCH_ASSOC);
            
            // Registrar log de acesso
            $logQuery = "INSERT INTO access_logs (user_id, ip_address, user_agent, action) VALUES (:user_id, :ip, :ua, 'login')";
            $logStmt = $db->prepare($logQuery);
            $logStmt->bindParam(":user_id", $user['id']);
            $logStmt->bindParam(":ip", $_SERVER['REMOTE_ADDR']);
            $logStmt->bindParam(":ua", $_SERVER['HTTP_USER_AGENT']);
            $logStmt->execute();
            
            http_response_code(200);
            echo json_encode([
                "success" => true,
                "message" => "Login realizado com sucesso",
                "user" => $user
            ]);
        } else {
            http_response_code(401);
            echo json_encode(["success" => false, "message" => "Email ou senha inválidos"]);
        }
    }
} else {
    http_response_code(400);
    echo json_encode(["success" => false, "message" => "Dados incompletos"]);
}
?>