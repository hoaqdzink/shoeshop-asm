<main>
    <?php //var_dump($product) ?>
    <section id="product-list" class="product-list">
        <h2>Danh Sách Sản Phẩm</h2>

        <form class="filter" method="POST" action="index.php?act=product-filter">
            <label for="max_price">Nhập giá tối đa:</label>
            <input type="number" id="max_price" name="max_price" step="0.01" min="0" placeholder="Nhập giá tối đa">
            <button type="submit" name="product-filter" value="submit">Lọc</button>
        </form>
        <div class="product-grid">
            <!-- Product 1 -->
            <?php 
                if(isset($product) && count($product)){
                    foreach($product as $item){
                        echo '

                        <div class="product">
                            <div class="product-image">
                                <img src="'.$item['Anh'].'" alt="'.$item['Ten'].'">
                            </div>
                            <div class="product-details">
                                <h3>'.$item['Ten'].'</h3>
                                <div class="info-row">
                                    <strong>' . number_format($item['GiaBan'], 0, ',', '.') . ' VND</strong>
                                    <p>Còn: <span>'.$item['SoLuong'].'</span></p>
                                </div>
                                <div class="info-row">
                                    <p>Size: <span>'.$item['Size'].'</span></p>
                                    <p>Màu Sắc: <span>'.$item['MauSac'].'</span></p>
                                </div>
                                <a href="index.php?act=product-detail&id='.$item['id'].'" class="btn">Mua Ngay</a>
                            </div>
                        </div>
                        
                        ';
                    }
                }
            ?>
        </div>
    </section>
</main>