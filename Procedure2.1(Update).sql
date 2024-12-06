---Insert
CREATE OR ALTER PROCEDURE InsertChiTietDonHang 
    @DonHangID INT, 
    @SanPhamID INT, 
    @Size CHAR(2), 
    @SoLuong INT, 
    @GiaBan DECIMAL(18, 2) 
AS
BEGIN
    BEGIN TRY
        -- Kiểm tra đơn hàng có tồn tại không
        IF NOT EXISTS (SELECT 1 FROM DonHang WHERE MaSo = @DonHangID)
        BEGIN
            RAISERROR ('Đơn hàng không tồn tại.', 16, 1);
            RETURN;
        END 

        -- Kiểm tra trạng thái đơn hàngß
        IF NOT EXISTS (SELECT 1 FROM DonHang WHERE MaSo = @DonHangID AND TrangThai = N'Chờ xử lý')
        BEGIN
            RAISERROR ('Trạng thái đơn hàng không hợp lệ', 16, 1);
            RETURN;
        END

        -- Kiểm tra sản phẩm có tồn tại không
        IF NOT EXISTS (SELECT 1 FROM KichCoSanPham WHERE SanPhamID = @SanPhamID AND Size = @Size)
        BEGIN
            RAISERROR ('Sản phẩm hoặc kích cỡ không tồn tại.', 16, 1);
            RETURN;
        END 
		-- Kiểm tra số lượng và giá bán phải lớn hơn 0
        IF @SoLuong <= 0
        BEGIN
            RAISERROR ('Số lượng phải lớn hơn 0.', 16, 1);
            RETURN;
        END

        IF @GiaBan <= 0
        BEGIN
            RAISERROR ('Giá bán phải lớn hơn 0.', 16, 1);
            RETURN;
        END
        -- Kiểm tra sản phẩm đã có trong đơn hàng chưa
        IF EXISTS (SELECT 1 FROM ChiTietDonHang WHERE DonHangID = @DonHangID AND SanPhamID = @SanPhamID AND Size = @Size)
        BEGIN
            -- Cập nhật số lượng nếu sản phẩm đã tồn tại
            UPDATE ChiTietDonHang
            SET SoLuong = SoLuong + @SoLuong
            WHERE DonHangID = @DonHangID AND SanPhamID = @SanPhamID AND Size = @Size;

            PRINT 'Cập nhật số lượng sản phẩm trong đơn hàng thành công!';
        END
        ELSE
        BEGIN
            -- Thêm bản ghi mới nếu sản phẩm chưa tồn tại
            INSERT INTO ChiTietDonHang (DonHangID, SanPhamID, Size, SoLuong, GiaBan)
            VALUES (@DonHangID, @SanPhamID, @Size, @SoLuong, @GiaBan);

            PRINT 'Thêm sản phẩm mới vào đơn hàng thành công!';
        END
    END TRY
    BEGIN CATCH
        -- Exception
        DECLARE @ErrorMessage NVARCHAR(4000), @ErrorSeverity INT, @ErrorState INT;
        SELECT @ErrorMessage = ERROR_MESSAGE(),
               @ErrorSeverity = ERROR_SEVERITY(),
               @ErrorState = ERROR_STATE();

        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;



---UPDATE
CREATE OR ALTER PROCEDURE UpdateChiTietDonHang
    @DonHangID INT,
    @SanPhamID INT,
    @OldSize CHAR(2),
    @NewSize CHAR(2) = NULL,
    @SoLuong INT = NULL
AS
BEGIN
    BEGIN TRY
        -- Kiểm tra xem sản phẩm có tồn tại trong đơn hàng không
        IF NOT EXISTS (SELECT 1 FROM ChiTietDonHang WHERE DonHangID = @DonHangID AND SanPhamID = @SanPhamID AND Size = @OldSize)
        BEGIN
            RAISERROR ('Sản phẩm không tồn tại trong đơn hàng.', 16, 1);
            RETURN;
        END

        -- Kiểm tra kích cỡ mới không được trùng với kích cỡ đã có của cùng 1 sản phẩm trong đơn hàng
        IF @NewSize IS NOT NULL AND @NewSize != @OldSize
           AND EXISTS (SELECT 1 
                       FROM ChiTietDonHang 
                       WHERE DonHangID = @DonHangID 
                         AND SanPhamID = @SanPhamID 
                         AND Size = @NewSize)
        BEGIN
            RAISERROR ('Kích cỡ mới đã tồn tại trong đơn hàng cho sản phẩm này.', 16, 1);
            RETURN;
        END

        -- Kiểm tra kích cỡ mới có hợp lệ không
        IF @NewSize IS NOT NULL AND NOT EXISTS (SELECT 1 FROM KichCoSanPham WHERE SanPhamID = @SanPhamID AND Size = @NewSize)
        BEGIN
            RAISERROR ('Kích cỡ mới không hợp lệ.', 16, 1);
            RETURN;
        END

        -- Xóa sản phẩm nếu số lượng mới <= 0
        IF @SoLuong IS NOT NULL AND @SoLuong <= 0
        BEGIN
            DELETE FROM ChiTietDonHang
            WHERE DonHangID = @DonHangID AND SanPhamID = @SanPhamID AND Size = @OldSize;

            PRINT 'Sản phẩm đã bị xóa khỏi đơn hàng do số lượng <= 0.';
            RETURN;
        END

        -- Cập nhật thông tin sản phẩm
        UPDATE ChiTietDonHang
        SET Size = ISNULL(@NewSize, Size),
            SoLuong = ISNULL(@SoLuong, SoLuong)
        WHERE DonHangID = @DonHangID AND SanPhamID = @SanPhamID AND Size = @OldSize;

        PRINT 'Cập nhật thông tin sản phẩm thành công!';
    END TRY
    BEGIN CATCH
        -- Exception handling
        DECLARE @ErrorMessage NVARCHAR(4000), @ErrorSeverity INT, @ErrorState INT;
        SELECT @ErrorMessage = ERROR_MESSAGE(), 
               @ErrorSeverity = ERROR_SEVERITY(), 
               @ErrorState = ERROR_STATE();

        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;


---DELETE

CREATE OR ALTER PROCEDURE DeleteChiTietDonHang
    @DonHangID INT,
    @SanPhamID INT,
    @Size CHAR(2)
AS
BEGIN
    BEGIN TRY
        -- Kiểm tra trạng thái đơn hàng
        DECLARE @TrangThai NVARCHAR(50);
        SELECT @TrangThai = TrangThai 
        FROM DonHang 
        WHERE MaSo = @DonHangID;

        -- Nếu không tìm thấy đơn hàng hoặc trạng thái không phải "Đang đặt hàng"
        IF @TrangThai IS NULL
        BEGIN
            RAISERROR ('Đơn hàng không tồn tại.', 16, 1);
            RETURN;
        END
        ELSE IF @TrangThai != N'Đang đặt hàng'
        BEGIN
            RAISERROR (N'Chỉ có thể xóa sản phẩm khi trạng thái đơn hàng là "Đang đặt hàng".', 16, 1);
            RETURN;
        END

        -- Kiểm tra xem sản phẩm có nằm trong đơn hàng không
        IF NOT EXISTS (SELECT 1 FROM ChiTietDonHang WHERE DonHangID = @DonHangID AND SanPhamID = @SanPhamID AND Size = @Size)
        BEGIN
            RAISERROR (N'Sản phẩm không tồn tại trong đơn hàng.', 16, 1);
            RETURN;
        END

        -- Xóa sản phẩm khỏi đơn hàng
        DELETE FROM ChiTietDonHang
        WHERE DonHangID = @DonHangID AND SanPhamID = @SanPhamID AND Size = @Size;

        PRINT N'Xóa sản phẩm khỏi đơn hàng thành công!';
    END TRY
    BEGIN CATCH
        -- Xử lý ngoại lệ
        DECLARE @ErrorMessage NVARCHAR(4000), @ErrorSeverity INT, @ErrorState INT;
        SELECT @ErrorMessage = ERROR_MESSAGE(), 
               @ErrorSeverity = ERROR_SEVERITY(), 
               @ErrorState = ERROR_STATE();

        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;

---Vi du thuc thi
EXEC InsertChiTietDonHang 
    @DonHangID = 2, 
    @SanPhamID = 3, 
    @Size = 42, 
    @SoLuong = 10, 
    @GiaBan = 500000;

EXEC UpdateChiTietDonHang 
    @DonHangID = 2, 
    @SanPhamID = 3, 
    @OldSize = 42, 
    @NewSize = 42, 
    @SoLuong = 0;

EXEC DeleteChiTietDonHang 
    @DonHangID = 1, 
    @SanPhamID = 2, 
    @Size = 38;
