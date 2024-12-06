USE ShoeStore_Management_System;
GO

---Thủ tục 1: Lấy lịch sử nhập kho của 1 sp tại 1 chi nhánh

CREATE OR ALTER PROCEDURE GetHistory
    @TenSanPham NVARCHAR(50),
    @TenChiNhanh NVARCHAR(50),
    @Size CHAR(2)
AS
BEGIN
    BEGIN TRY
        -- Kiểm tra xem sản phẩm có tồn tại hay không
        IF NOT EXISTS (
            SELECT 1 
            FROM SanPham sp
            WHERE sp.Ten = @TenSanPham
        )
        BEGIN
            RAISERROR (N'Sản phẩm không tồn tại.', 16, 1);
            RETURN;
        END;

        -- Kiểm tra xem chi nhánh có tồn tại hay không
        IF NOT EXISTS (
            SELECT 1 
            FROM ChiNhanh cn
            WHERE cn.Ten = @TenChiNhanh
        )
        BEGIN
            RAISERROR (N'Chi nhánh không tồn tại.', 16, 1);
            RETURN;
        END;

        -- Kiểm tra xem size sản phẩm có hợp lệ hay không
        IF NOT EXISTS (
            SELECT 1 
            FROM KichCoSanPham kcsp
            INNER JOIN SanPham sp ON kcsp.SanPhamID = sp.ID
            WHERE sp.Ten = @TenSanPham AND kcsp.Size = @Size
        )
        BEGIN
            RAISERROR (N'Kích cỡ sản phẩm không tồn tại.', 16, 1);
            RETURN;
        END;

        -- Kiểm tra xem có lịch sử nhập kho cho sản phẩm này hay không
        IF NOT EXISTS (
            SELECT 1
            FROM NhapKho nk
            JOIN KichCoSanPham kcsp ON nk.SanPhamID = kcsp.SanPhamID AND nk.Size = kcsp.Size
            JOIN SanPham sp ON kcsp.SanPhamID = sp.ID
            JOIN KhoHang kh ON nk.KhoHangID = kh.MaSo
            JOIN ChiNhanh cn ON kh.ChiNhanhID = cn.MaSo
            WHERE sp.Ten = @TenSanPham 
              AND cn.Ten = @TenChiNhanh 
              AND kcsp.Size = @Size
        )
        BEGIN
            RAISERROR (N'Không có lịch sử nhập kho cho sản phẩm này.', 16, 1);
            RETURN;
        END;

        -- Hiển thị lịch sử nhập kho
        SELECT 
            nk.NgayNhap,
            nk.SoLuongNhap,
            nk.GiaNhap,
            ms.MauSac,
            sp.Ten AS TenSanPham
        FROM NhapKho nk
        JOIN KichCoSanPham kcsp ON nk.SanPhamID = kcsp.SanPhamID AND nk.Size = kcsp.Size
        JOIN SanPham sp ON kcsp.SanPhamID = sp.ID
        JOIN MauSac ms ON sp.ID = ms.ID
        JOIN KhoHang kh ON nk.KhoHangID = kh.MaSo
        JOIN ChiNhanh cn ON kh.ChiNhanhID = cn.MaSo
        WHERE sp.Ten = @TenSanPham 
          AND cn.Ten = @TenChiNhanh 
          AND kcsp.Size = @Size
        ORDER BY nk.NgayNhap DESC;

    END TRY
    BEGIN CATCH
        -- Xử lý lỗi
        DECLARE @ErrorMessage NVARCHAR(4000), @ErrorSeverity INT, @ErrorState INT;
        SELECT @ErrorMessage = ERROR_MESSAGE(), 
               @ErrorSeverity = ERROR_SEVERITY(), 
               @ErrorState = ERROR_STATE();

        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;


--- Lấy báo cáo về việc mua hàng tại 1 chi nhánh, trả về tên kh, tổng tiền mua trong 1 khoảng tg
CREATE OR ALTER PROCEDURE GetPurchaseInfo
    @TenChiNhanh NVARCHAR(50),
    @NgayBatDau DATE,
    @NgayKetThuc DATE
AS
BEGIN
    BEGIN TRY
        -- Kiểm tra xem chi nhánh có tồn tại hay không
        IF NOT EXISTS (
            SELECT 1 
            FROM ChiNhanh
            WHERE Ten = @TenChiNhanh
        )
        BEGIN
            RAISERROR (N'Chi nhánh không tồn tại.', 16, 1);
            RETURN;
        END;

        -- Lấy thông tin mua hàng của chi nhánh
        SELECT 
            nd.HoVaTen AS TenKhachHang,
            SUM(hd.TongTien) AS TongSoTienDaChiTra,
            SUM(ctdh.SoLuong) AS TongSoLuongSanPham
        FROM HoaDon hd
        JOIN DonHang dh ON hd.DonHangID = dh.MaSo
        JOIN ChiNhanh cn ON dh.ChiNhanhID = cn.MaSo
        JOIN KhachHang kh ON dh.KhachHangID = kh.ID
        JOIN NguoiDung nd ON kh.ID = nd.ID
        JOIN ChiTietDonHang ctdh ON ctdh.DonHangID = dh.MaSo
        WHERE cn.Ten = @TenChiNhanh 
          AND hd.ThoiGianThanhToan BETWEEN @NgayBatDau AND @NgayKetThuc
        GROUP BY nd.HoVaTen
        HAVING SUM(hd.TongTien) > 0 -- Chỉ hiển thị khách hàng có mua hàng
        ORDER BY SUM(hd.TongTien) DESC;

    END TRY
    BEGIN CATCH
        -- Xử lý lỗi
        DECLARE @ErrorMessage NVARCHAR(4000), @ErrorSeverity INT, @ErrorState INT;
        SELECT @ErrorMessage = ERROR_MESSAGE(), 
               @ErrorSeverity = ERROR_SEVERITY(), 
               @ErrorState = ERROR_STATE();

        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;


CREATE OR ALTER PROCEDURE TimKiemSanPham
    @Search NVARCHAR(255) = NULL  -- Biến tìm kiếm chung
AS
BEGIN
    SELECT 
        sp.ID AS id,
        sp.Ten AS Ten,
        sp.ChatLieu,
        sp.Loai,
        sp.MoTa,
        hs.TenHang AS HangSanXuat,
        kc.Size,
        kc.Anh,
        kc.GiaBan,
        kc.SoLuong,
        ms.MauSac
    FROM 
        SanPham sp
    LEFT JOIN 
        HangSanXuat hs ON sp.HangSanXuatID = hs.ID
    LEFT JOIN 
        KichCoSanPham kc ON sp.ID = kc.SanPhamID
    LEFT JOIN 
        MauSac ms ON sp.ID = ms.ID
    WHERE
        (@Search IS NULL OR sp.Ten LIKE '%' + @Search + '%')  -- Tìm kiếm theo tên sản phẩm
        OR (@Search IS NULL OR hs.TenHang LIKE '%' + @Search + '%')  -- Tìm kiếm theo hãng sản xuất
        OR (@Search IS NULL OR sp.Loai LIKE '%' + @Search + '%')  -- Tìm kiếm theo loại sản phẩm
        OR (@Search IS NULL OR ms.MauSac LIKE '%' + @Search + '%')  -- Tìm kiếm theo màu sắc
        OR (@Search IS NULL OR kc.Size LIKE '%' + @Search + '%')  -- Tìm kiếm theo kích cỡ
    ORDER BY 
        sp.Ten, kc.Size;
END;

EXEC TimKiemSanPham @Search ='Adidas';



