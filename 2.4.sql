---Function 1

CREATE OR ALTER FUNCTION TimGiayGiaThapHon(@MaxPrice DECIMAL(10, 2))
RETURNS @ResultTable TABLE
(
    id INT,
    Ten NVARCHAR(255),
    HangSanXuat NVARCHAR(255),
    MauSac NVARCHAR(50),
    Size NVARCHAR(10),
    GiaBan DECIMAL(10, 2),
    Anh NVARCHAR(255),
    SoLuong INT
)
AS
BEGIN
    IF @MaxPrice <= 0
    BEGIN
        RETURN;
    END;

    -- Sử dụng con trỏ để duyệt qua danh sách sản phẩm
    DECLARE @SanPhamID INT, 
            @TenSanPham NVARCHAR(255), 
            @HangSanXuat NVARCHAR(255), 
            @MauSac NVARCHAR(50), 
            @KichCo NVARCHAR(10), 
            @GiaBan DECIMAL(10, 2),
            @Anh NVARCHAR(255),
            @SoLuong INT;  -- Thêm trường SoLuong

    DECLARE SanPhamCursor CURSOR FOR
    SELECT 
        sp.ID AS id,  -- Đổi tên trường thành 'id'
        sp.Ten AS Ten,  -- Đổi tên trường thành 'Ten'
        hsx.TenHang AS HangSanXuat,  -- Đổi tên trường thành 'HangSanXuat'
        ms.MauSac AS MauSac,  -- Đổi tên trường thành 'MauSac'
        kcsp.Size AS Size,  -- Đổi tên trường thành 'Size'
        kcsp.GiaBan,
        kcsp.Anh,
        kcsp.SoLuong  -- Thêm trường SoLuong
    FROM 
        SanPham sp
        JOIN KichCoSanPham kcsp ON sp.ID = kcsp.SanPhamID
        JOIN HangSanXuat hsx ON sp.HangSanXuatID = hsx.ID
        JOIN MauSac ms ON sp.ID = ms.ID
    WHERE 
        kcsp.GiaBan < @MaxPrice;
    
    OPEN SanPhamCursor;

    -- Lấy dữ liệu từng hàng
    FETCH NEXT FROM SanPhamCursor INTO @SanPhamID, @TenSanPham, @HangSanXuat, @MauSac, @KichCo, @GiaBan, @Anh, @SoLuong;

    -- Lặp qua các sản phẩm
    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Thêm dữ liệu vào bảng kết quả
        INSERT INTO @ResultTable (id, Ten, HangSanXuat, MauSac, Size, GiaBan, Anh, SoLuong)
        VALUES (@SanPhamID, @TenSanPham, @HangSanXuat, @MauSac, @KichCo, @GiaBan, @Anh, @SoLuong);

        -- Tiếp tục lặp
        FETCH NEXT FROM SanPhamCursor INTO @SanPhamID, @TenSanPham, @HangSanXuat, @MauSac, @KichCo, @GiaBan, @Anh, @SoLuong;
    END;

    -- Đóng và hủy con trỏ
    CLOSE SanPhamCursor;
    DEALLOCATE SanPhamCursor;

    RETURN;
END;

SELECT * FROM dbo.TimGiayGiaThapHon(500000)


---Function 2
CREATE OR ALTER FUNCTION TinhTongTienThanhToan(@DonHangID INT)
RETURNS DECIMAL(18, 2)
AS
BEGIN
    DECLARE @TongTien DECIMAL(18, 2) = 0.0;
    DECLARE @SanPhamID INT, @Size CHAR(2), @SoLuong INT, @GiaBan DECIMAL(18, 2);
    DECLARE @MaKhuyenMai NVARCHAR(20), @LoaiGiamGia NVARCHAR(10), @MucGiam DECIMAL(18, 2), @TienGiamGia DECIMAL(18, 2) = 0.0;

    IF @DonHangID IS NULL OR @DonHangID <= 0
    BEGIN
        RETURN 0.0; --
    END;

    -- Con trỏ để duyệt qua chi tiết đơn hàng
    DECLARE ChiTietDonHangCursor CURSOR FOR
    SELECT SanPhamID, Size, SoLuong, GiaBan
    FROM ChiTietDonHang
    WHERE DonHangID = @DonHangID;

    -- Mở con trỏ
    OPEN ChiTietDonHangCursor;
    FETCH NEXT FROM ChiTietDonHangCursor INTO @SanPhamID, @Size, @SoLuong, @GiaBan;
    -- Lặp qua từng sản phẩm trong đơn hàng
    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Tính tổng tiền dựa vào số lượng và giá bán
        SET @TongTien += @SoLuong * @GiaBan;
        FETCH NEXT FROM ChiTietDonHangCursor INTO @SanPhamID, @Size, @SoLuong, @GiaBan;
    END;

    -- Đóng và hủy con trỏ
    CLOSE ChiTietDonHangCursor;
    DEALLOCATE ChiTietDonHangCursor;

    -- Lấy thông tin khuyến mãi
    DECLARE KhuyenMaiCursor CURSOR FOR
    SELECT hk.MaKhuyenMai, pk.LoaiGiamGia, pk.MucGiam
    FROM HoaDon_KhuyenMai hk
    JOIN PhieuKhuyenMai pk ON hk.MaKhuyenMai = pk.MaKhuyenMai
    JOIN HoaDon h ON hk.HoaDonID = h.MaSo
    WHERE h.DonHangID = @DonHangID;

    -- Mở con trỏ
    OPEN KhuyenMaiCursor;

    -- Lặp qua từng phiếu giảm giá
    FETCH NEXT FROM KhuyenMaiCursor INTO @MaKhuyenMai, @LoaiGiamGia, @MucGiam;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Tính tiền giảm giá
        IF @LoaiGiamGia = '%'
        BEGIN
            SET @TienGiamGia += (@MucGiam / 100) * @TongTien;
        END
        ELSE IF @LoaiGiamGia = 'VND'
        BEGIN
            SET @TienGiamGia += @MucGiam;
        END

        FETCH NEXT FROM KhuyenMaiCursor INTO @MaKhuyenMai, @LoaiGiamGia, @MucGiam;
    END;

    -- Đóng và hủy con trỏ
    CLOSE KhuyenMaiCursor;
    DEALLOCATE KhuyenMaiCursor;

    -- Áp dụng giảm giá vào tổng tiền
    SET @TongTien -= ISNULL(@TienGiamGia, 0.0);

    -- Đảm bảo tổng tiền không âm
    IF @TongTien < 0
        SET @TongTien = 0.0;

    RETURN @TongTien;
END;
