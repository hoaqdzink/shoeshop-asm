DROP DATABASE ShoeStore_Management_System;
--Xóa db 

CREATE DATABASE ShoeStore_Management_System;

USE ShoeStore_Management_System;


CREATE TABLE NguoiDung (
    ID INT PRIMARY KEY,
    HoVaTen VARCHAR(100) NOT NULL, 
    DiaChi VARCHAR(255), 
    NgaySinh DATE, 
    GioiTinh TINYINT(1) NOT NULL,  -- Thay BIT bằng TINYINT(1)
    Email VARCHAR(100) UNIQUE, 
    SoDienThoai VARCHAR(15) UNIQUE,
    CCCD VARCHAR(12) UNIQUE,
    TaiKhoan VARCHAR(30) UNIQUE,
    MatKhau VARCHAR(255) NOT NULL
); -- Đảm bảo có dấu chấm phẩy ở đây

CREATE TABLE QuanLy (
    ID INT PRIMARY KEY,
    BangCap VARCHAR(50),
    FOREIGN KEY (ID) REFERENCES NguoiDung(ID)
);

CREATE TABLE ChiNhanh (
    MaSo INT PRIMARY KEY,
	Ten	VARCHAR(50),
    DiaChi VARCHAR(255) NOT NULL,
    Email VARCHAR(100) NOT NULL,
    SoDienThoai VARCHAR(15) NOT NULL,
    QuanLyID INT UNIQUE,
    FOREIGN KEY (QuanLyID) REFERENCES QuanLy(ID)
);

CREATE TABLE NhanVien (
    ID INT PRIMARY KEY,
    VaiTro VARCHAR(50) NOT NULL,
    NgayNhanViec DATE NOT NULL,
    FOREIGN KEY (ID) REFERENCES NguoiDung(ID)
);

CREATE TABLE HuongDan (
    ID INT PRIMARY KEY,
    SID INT,
    FOREIGN KEY (ID) REFERENCES NhanVien(ID)
);

CREATE TABLE CaLamViec(
	ID INT PRIMARY KEY,
	CaLamViec VARCHAR(20),
	FOREIGN KEY (ID) REFERENCES NhanVien(ID)
);

CREATE TABLE KhachHang (
    ID INT PRIMARY KEY,
    DiemTichLuy INT DEFAULT 0,
    DacQuyen VARCHAR(50),
    FOREIGN KEY (ID) REFERENCES NguoiDung(ID)
);

CREATE TABLE KhoHang (
    MaSo INT PRIMARY KEY,
    DiaChi VARCHAR(255) NOT NULL,
    ChiNhanhID INT UNIQUE,
    FOREIGN KEY (ChiNhanhID) REFERENCES ChiNhanh(MaSo)
);

CREATE TABLE HangSanXuat(
	ID INT PRIMARY KEY,
	TenHang VARCHAR(50) NOT NULL,
	XuatXu VARCHAR(50) NOT NULL
);


CREATE TABLE MauSac(
	ID INT PRIMARY KEY,
	MauSac VARCHAR(20),
	FOREIGN KEY (ID) REFERENCES SanPham(ID)
);

CREATE TABLE KichCoSanPham (
    SanPhamID INT,
    Size CHAR(2),
  	Anh VARCHAR(255),
    SoLuong INT DEFAULT 0,
    GiaBan DECIMAL(18, 2),
    PRIMARY KEY (SanPhamID, Size),
    FOREIGN KEY (SanPhamID) REFERENCES SanPham(ID)
);

CREATE TABLE NhapKho (
    ID INT PRIMARY KEY,
    KhoHangID INT,
    SanPhamID INT,
    Size CHAR(2),
    SoLuongNhap INT NOT NULL,
    GiaNhap DECIMAL(18, 2),
    NgayNhap DATE,
    FOREIGN KEY (KhoHangID) REFERENCES KhoHang(MaSo),
    FOREIGN KEY (SanPhamID, Size) REFERENCES KichCoSanPham(SanPhamID, Size)
);

CREATE TABLE SanPham(
	ID INT PRIMARY KEY,
	Ten VARCHAR(50) NOT NULL UNIQUE,
	ChatLieu VARCHAR(50) NOT NULL,
	Loai VARCHAR(50) NOT NULL,
	MoTa VARCHAR(255),
	HangSanXuatID INT NOT NULL,
	FOREIGN KEY (HangSanXuatID) REFERENCES HangSanXuat(ID)
);


CREATE TABLE DonHang(
	MaSo INT PRIMARY KEY, 
    KhachHangID INT, 
    NgayLap DATE NOT NULL, 
    TrangThai VARCHAR(50) NOT NULL, 
    TongTien DECIMAL(18, 2),
    ChiNhanhID INT UNIQUE,
    FOREIGN KEY (KhachHangID) REFERENCES KhachHang(ID),
    FOREIGN KEY (ChiNhanhID) REFERENCES ChiNhanh(MaSo)
);

CREATE TABLE ChiTietDonHang (
    DonHangID INT, 
    SanPhamID INT,
    Size CHAR(2),
    SoLuong INT NOT NULL CHECK (SoLuong>0),
    GiaBan DECIMAL(18, 2) NOT NULL,
    PRIMARY KEY (DonHangID, SanPhamID, Size),
    FOREIGN KEY (DonHangID) REFERENCES DonHang(MaSo),
    FOREIGN KEY (SanPhamID, Size) REFERENCES KichCoSanPham(SanPhamID, Size)
);

CREATE TABLE PhieuKhuyenMai (
    MaKhuyenMai VARCHAR(20) PRIMARY KEY, 
    NgayBatDau DATE NOT NULL, 
    NgayKetThuc DATE NOT NULL, 
    MucGiam DECIMAL(5, 2) NOT NULL, -- Mức giảm giá (có thể là phần trăm hoặc số tiền)
    LoaiGiamGia VARCHAR(10) CHECK (LoaiGiamGia IN ('%', 'VND')) NOT NULL, -- Loại giảm giá: % hoặc VND
    QuanLyID INT,
    FOREIGN KEY (QuanLyID) REFERENCES QuanLy(ID)
);

CREATE TABLE HoaDon (
    MaSo INT PRIMARY KEY, 
    DonHangID INT,
    PhuongThucThanhToan VARCHAR(50) NOT NULL,
    ThoiGianThanhToan DATETIME NOT NULL,
    TongTien DECIMAL(18, 2),
    FOREIGN KEY (DonHangID) REFERENCES DonHang(MaSo)
);

CREATE TABLE HoaDon_KhuyenMai (
    HoaDonID INT, 
    MaKhuyenMai VARCHAR(20) NOT NULL,
    TienGiamGia DECIMAL(18, 2) NOT NULL,
    PRIMARY KEY (HoaDonID, MaKhuyenMai),
    FOREIGN KEY (HoaDonID) REFERENCES HoaDon(MaSo),
    FOREIGN KEY (MaKhuyenMai) REFERENCES PhieuKhuyenMai(MaKhuyenMai)
);

CREATE TABLE DanhGia (
    ID INT PRIMARY KEY,
    KhachHangID INT,
    SanPhamID INT,
    NgayDanhGia DATE NOT NULL,
    Diem INT CHECK (Diem BETWEEN 1 AND 5) NOT NULL,
    NoiDung VARCHAR(255) NOT NULL,
    FOREIGN KEY (KhachHangID) REFERENCES KhachHang(ID),
    FOREIGN KEY (SanPhamID) REFERENCES SanPham(ID)
);

CREATE TABLE PhanHoiDanhGia (
    ID INT PRIMARY KEY,
    DanhGiaID INT,
    NhanVienID INT,
    NgayPhanHoi DATE NOT NULL,
    NoiDung VARCHAR(255) NOT NULL,
    FOREIGN KEY (DanhGiaID) REFERENCES DanhGia(ID),
    FOREIGN KEY (NhanVienID) REFERENCES NhanVien(ID)
);

CREATE TRIGGER TRG_CheckGiaBan
ON NhapKho
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM KichCoSanPham kc
        INNER JOIN inserted i ON kc.SanPhamID = i.SanPhamID AND kc.Size = i.Size
        WHERE kc.GiaBan <= i.GiaNhap
    )
    BEGIN
        ROLLBACK TRANSACTION;
        THROW 50001, 'Giá bán phải lớn hơn giá nhập', 1;
    END
END;

CREATE TRIGGER TRG_CheckSoLuongXuat
ON ChiTietDonHang
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM ChiTietDonHang ct
        INNER JOIN KichCoSanPham kc
        ON ct.SanPhamID = kc.SanPhamID AND ct.Size = kc.Size
        WHERE ct.SoLuong > kc.SoLuong OR ct.SoLuong <= 0
    )
    BEGIN
        ROLLBACK TRANSACTION;
        THROW 50003, 'Số lượng xuất bán phải nhỏ hơn hoặc bằng số lượng tồn kho', 1;
    END
END;

CREATE TRIGGER TRG_CheckDiscountLimit
ON HoaDon_KhuyenMai
AFTER INSERT, UPDATE
AS
BEGIN
    -- Kiểm tra tổng giảm giá của hóa đơn
    IF EXISTS (
        SELECT 1
        FROM HoaDon h
        JOIN inserted hk ON h.MaSo = hk.HoaDonID
        JOIN (
            SELECT HoaDonID, SUM(TienGiamGia) AS TongGiam
            FROM HoaDon_KhuyenMai
            GROUP BY HoaDonID
        ) agg ON h.MaSo = agg.HoaDonID
        WHERE agg.TongGiam > 0.3 * h.TongTien
    )	
    BEGIN
        ROLLBACK TRANSACTION;
        THROW 50004, 'Tổng tiền giảm giá không được vượt quá 30% giá trị hóa đơn', 1;
    END
END;


ALTER TABLE KichCoSanPham
ADD Anh NVARCHAR(MAX);


SELECT 
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

   
SELECT 
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
    sp.ID = 8 
ORDER BY 
    kc.Size;
