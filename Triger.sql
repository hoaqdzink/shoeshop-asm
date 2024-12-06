/* Cập nhật lại số lượng tồn kho của sản phẩm trong bảng KichCoSanPham
khi có bản ghi mới được thêm vào bảng ChiTietDonHang
*/
CREATE TRIGGER trg_UpdateStock
ON ChiTietDonHang
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    -- Xử lý trường hợp DELETE: Hoàn lại số lượng vào tồn kho
    UPDATE k
    SET k.SoLuong = k.SoLuong + d.SoLuong
    FROM KichCoSanPham k
    JOIN deleted d
        ON k.SanPhamID = d.SanPhamID
       AND k.Size = d.Size;

    -- Xử lý trường hợp INSERT: Trừ số lượng từ tồn kho
    UPDATE k
    SET k.SoLuong = k.SoLuong - i.SoLuong
    FROM KichCoSanPham k
    JOIN inserted i
        ON k.SanPhamID = i.SanPhamID
       AND k.Size = i.Size;

    PRINT N'Đã cập nhật số lượng tồn kho sau các thay đổi (INSERT, UPDATE, DELETE).';
END;

--DROP TRIGGER trg_UpdateStockOnInsert;

-- Các câu truy vấn chạy để test
SELECT * FROM SanPham;
SELECT * FROM KichCoSanPham;
SELECT * FROM ChiTietDonHang;
SELECT * FROM DonHang;
SELECT * FROM KhachHang
-- test update nè
UPDATE ChiTietDonHang
SET SoLuong = 1
WHERE DonHangID = 1 AND SanPhamID = 1 AND Size = '40';


/** Cập nhật số lượng trong kho khi nhập kho */
CREATE TRIGGER trg_UpdateStockOnInsertStock
ON NhapKho
AFTER INSERT
AS
BEGIN
    -- Cập nhật số lượng tồn kho khi nhập kho
    UPDATE k
    SET k.SoLuong = k.SoLuong + i.SoLuongNhap
    FROM KichCoSanPham k
    JOIN inserted i
        ON k.SanPhamID = i.SanPhamID
       AND k.Size = i.Size;

    PRINT N'Đã cập nhật số lượng tồn kho sau khi nhập kho.';
END;

/** Cập nhật số lượng tồn kho khi đơn hàng bị hủy */
CREATE TRIGGER trg_UpdateStockOnCancelOrder
ON DonHang
AFTER UPDATE
AS
BEGIN
    -- Cập nhật số lượng tồn kho khi đơn hàng bị hủy
    IF EXISTS (SELECT * FROM inserted WHERE TrangThai = N'Đã hủy')
    BEGIN
        DECLARE @DonHangID INT;
        SELECT @DonHangID = MaSo FROM inserted;

        -- Lấy thông tin chi tiết đơn hàng đã hủy
        UPDATE k
        SET k.SoLuong = k.SoLuong + cd.SoLuong
        FROM KichCoSanPham k
        JOIN ChiTietDonHang cd
            ON k.SanPhamID = cd.SanPhamID
           AND k.Size = cd.Size
        WHERE cd.DonHangID = @DonHangID;

        PRINT N'Đã hoàn lại số lượng tồn kho khi đơn hàng bị hủy.';
    END
END;
