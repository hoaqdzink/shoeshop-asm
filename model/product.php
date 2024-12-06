<?php
    function get_all_product() {
        try {
            $conn = connect(); // Kết nối tới cơ sở dữ liệu
    
            // Truy vấn SQL
            $sql = "
                SELECT 
                    sp.id,
                    sp.Ten,
                    kc.Anh,
                    kc.GiaBan,
                    kc.SoLuong,
                    kc.Size,
                    ms.MauSac
                FROM 
                    SanPham sp
                JOIN 
                    KichCoSanPham kc ON sp.ID = kc.SanPhamID
                JOIN 
                    MauSac ms ON sp.ID = ms.ID
                ORDER BY 
                    sp.Ten, kc.Size;
            ";
    
            // Chuẩn bị và thực thi truy vấn
            $stmt = $conn->prepare($sql);
            $stmt->execute();
    
            // Lấy kết quả
            $products = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
            // Đóng kết nối
            $conn = null;
    
            return $products;
        } catch (PDOException $e) {
            die("Lỗi truy vấn: " . $e->getMessage());
        }
    }

    function get_filter_lower_price($MaxPrice) {
        $conn = connect();
        $stmt = $conn->prepare("SELECT * FROM dbo.TimGiayGiaThapHon(?)");
    
        $stmt->bindParam(1, $MaxPrice, PDO::PARAM_STR); 
        $stmt->execute();
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    function get_product_search($search) {
        $conn = connect();
        
        $stmt = $conn->prepare("EXEC TimKiemSanPham @Search = :search");
        $stmt->bindParam(':search', $search, PDO::PARAM_STR);
        $stmt->execute();
    
        $products = [];
        while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
            $products[] = $row;
        }
        
        $stmt->closeCursor(); 
        $conn = null;
        
        return $products;
    }
    
    function get_product_by_id($id) {
        $conn = connect(); 
        $stmt = $conn->prepare("SELECT 
                                    sp.Ten AS TenSanPham,
                                    kc.GiaBan,
                                    kc.SoLuong,
                                    sp.ChatLieu,
                                    sp.Loai,
                                    hs.TenHang AS HangSanXuat,
                                    hs.XuatXu,
                                    kc.Anh,
                                    kc.Size,
                                    ms.MauSac
                                FROM 
                                    SanPham sp
                                JOIN 
                                    KichCoSanPham kc ON sp.ID = kc.SanPhamID
                                JOIN 
                                    HangSanXuat hs ON sp.HangSanXuatID = hs.ID
                                JOIN 
                                    MauSac ms ON kc.SanPhamID = ms.ID
                                WHERE 
                                    sp.ID = :id
                                ORDER BY 
                                    kc.Size");
    
        // Bind the parameter and execute
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->execute();
        return $stmt->fetch(PDO::FETCH_ASSOC);
    }    
    
    
?>