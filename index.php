<?php
    include './connect/connect.php';
    include './model/product.php'
?>


<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ShoeStore</title>
    <link rel="stylesheet" href="./css/home.css">
    <link rel="stylesheet" href="./css/product.css">
    <link rel="stylesheet" href="./css/product-detail.css">
</head>
<body>
    <?php
        include './view/header.php';
    ?>
    
    <?php
        if(isset($_GET['act'])){
            switch ($_GET['act']){
                case 'home':
                    include './view/home.php';
                    break;
                case 'product':
                    $product = get_all_product();
                    include './view/product.php';
                    break;
                case 'product-detail':
                    if(isset($_GET['id']) && $_GET['id']){
                        $id = $_GET['id'];
                        $product = get_product_by_id(8);
                        include './view/product_detail.php';
                    }
                    break;
                case 'product-filter':
                    if(isset($_POST['product-filter']) && $_POST['product-filter']){
                        $maxprice = $_POST['max_price'];
                        $product = get_filter_lower_price($maxprice);
                        include './view/product.php';
                        break;
                    }
                    $product = get_all_product();
                    include './view/product.php';
                    break;
                case 'search':
                    if(isset($_POST['search']) && $_POST['search']){
                        $tiemkiem = $_POST['timkiem'];
                        $product = get_product_search($tiemkiem);
                        include './view/product.php';
                        break;
                    }
                    $product = get_all_product();
                    include './view/product.php';
                    break;
                default:
                    include './view/home.php';
                    break;
            }
        }else{
            include './view/home.php';
        }
    ?>
    
    <?php
        include './view/footer.php'
    ?>
    <script src="./js/product.js"></script>
</body>
</html>
