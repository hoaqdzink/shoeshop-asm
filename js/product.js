const sql = require('mssql');

// Cấu hình kết nối SQL Server
const config = {
    user: 'SA',
    password: 'Hoangvinh2312@', // Thay mật khẩu của bạn ở đây
    server: 'localhost',         // Thay địa chỉ server SQL Server của bạn ở đây
    database: 'ShoeStore_Management_System', // Thay tên cơ sở dữ liệu của bạn ở đây
    options: {
        encrypt: true,           // Dành cho Azure nếu cần
        trustServerCertificate: true, // Bỏ qua chứng chỉ SSL nếu cần
    }
};

// Kết nối với SQL Server và thực hiện truy vấn
async function connectAndQuery() {
    try {
        // Kết nối đến cơ sở dữ liệu
        await sql.connect(config);
        console.log('Kết nối thành công!');

        // Thực hiện truy vấn
        const result = await sql.query(`
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
        `);

        // Hiển thị kết quả truy vấn
        console.log(result.recordset);

    } catch (err) {
        console.error('Lỗi kết nối hoặc truy vấn: ', err);
    } finally {
        // Đảm bảo đóng kết nối
        sql.close();
    }
}

// Gọi hàm kết nối và thực hiện truy vấn
connectAndQuery();
