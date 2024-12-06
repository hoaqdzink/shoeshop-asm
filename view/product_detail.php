<main> 
    <?php //var_dump($product) ?>
    <section id="product-detail" class="product-detail">
        <div class="product-image">
            <img src="https://chuphinhquangcao.net/wp-content/uploads/2021/07/ANH-1-3.jpg" alt="Giày Cao Gót">
        </div>
        <div class="product-info">
            <h2><?= $product['TenSanPham'] ?></h2>
            <div class="product-price">
                <strong><?= number_format($product['GiaBan'], 0, ',', '.') ?> VND</strong>
            </div>
            <div class="product-remaining"> 
                <p>Còn lại: <span><?= $product['SoLuong'] ?></span> sản phẩm</p>
                <p>Chất liệu: <?= $product['ChatLieu'] ?></p>
                <p>Loại: <?= $product['Loai'] ?></p>
                <p>Hãng: <?= $product['HangSanXuat'] ?></p>
                <p>Xuất xứ: <?= $product['XuatXu'] ?></p>
                <p>Màu sắc: <?= $product['MauSac'] ?></p>
                <p>Size: <?= $product['Size'] ?></p>
            </div>

            <div class="product-action">
            <form action="your_add_to_cart_endpoint.php" method="POST">
                <!-- Hidden input to store the product ID, assuming you have it -->
                <input type="hidden" name="product_id" value="8">
                
                <!-- Input for quantity -->
                <label for="quantity">Số lượng:</label>
                <input type="number" id="quantity" name="quantity" value="1" min="1" max="100" required>
                <br/>
                <!-- Button to submit the form -->
                <button type="submit" class="btn">Thêm vào giỏ hàng</button>
            </form>
            </div>
        </div>
    </section>
    <div class="product-description">
        <h3>Mô Tả Sản Phẩm:</h3>
        <p>Giày Cao Gót dành cho phái đẹp, sang trọng, thiết kế đẹp mắt, dễ dàng phối với nhiều trang phục.</p>
    </div>
</main>