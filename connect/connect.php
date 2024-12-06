<?php
function connect(){
    // Địa chỉ và thông tin kết nối tới SQL Server
    $servername = "localhost,1433"; // Sử dụng "host.docker.internal" khi dùng Docker
    $username = "SA";
    $password = "Hoangvinh2312@";
    $database = "ShoeStore_Management_System";

    try {
        // Kết nối sử dụng PDO_SQLSRV
        $conn = new PDO("sqlsrv:server=$servername;Database=$database", $username, $password);
        
        // Set chế độ lỗi của PDO
        $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

        // In ra thông báo nếu kết nối thành công
        //echo "Kết nối thành công!";
    } catch (PDOException $e) {
        // Hiển thị thông tin chi tiết lỗi
        echo "Kết nối thất bại: ";
        echo "Thông báo lỗi: " . $e->getMessage() . "<br>";
        echo "Mã lỗi: " . $e->getCode() . "<br>";
        echo "File: " . $e->getFile() . "<br>";
        echo "Dòng: " . $e->getLine() . "<br>";
    }

    return $conn;
}
?>
