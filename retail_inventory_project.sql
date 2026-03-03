CREATE DATABASE retail_inventory_db;
USE retail_inventory_db;
CREATE TABLE suppliers (
    supplier_id INT PRIMARY KEY AUTO_INCREMENT,
    supplier_name VARCHAR(100) NOT NULL,
    phone VARCHAR(15),
    email VARCHAR(100),
    address VARCHAR(255)
);

CREATE TABLE products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(150) NOT NULL,
    category VARCHAR(100),
    price DECIMAL(10,2) NOT NULL,
    supplier_id INT,
    FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id)
);

CREATE TABLE inventory (
    product_id INT PRIMARY KEY,
    quantity_in_stock INT NOT NULL,
    reorder_level INT DEFAULT 10,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP 
        ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

INSERT INTO suppliers (supplier_name, phone, email, address) VALUES
('ABC Wholesale', '9876543210', 'abc@wholesale.com', 'Mumbai'),
('FreshFarm Supplies', '9123456780', 'contact@freshfarm.com', 'Hyderabad'),
('TechSource India', '9988776655', 'sales@techsource.com', 'Bangalore'),
('DailyNeeds Distributor', '9012345678', 'info@dailyneeds.com', 'Chennai'),
('Global Traders', '9090909090', 'support@globaltraders.com', 'Delhi'),
('Prime Electronics', '9345678901', 'prime@electronics.com', 'Pune'),
('HomeCare Products', '9234567890', 'care@homecare.com', 'Kolkata'),
('FoodMart Suppliers', '9567890123', 'sales@foodmart.com', 'Vijayawada'),
('Stationery Hub', '9789012345', 'info@stationeryhub.com', 'Ahmedabad'),
('Mega Distributors', '9871234560', 'contact@mega.com', 'Coimbatore');

INSERT INTO products (product_name, category, price, supplier_id) VALUES
('Rice 1kg', 'Groceries', 60.00, 2),
('Wheat Flour 1kg', 'Groceries', 45.00, 2),
('LED Bulb 9W', 'Electronics', 120.00, 6),
('USB Cable', 'Electronics', 150.00, 3),
('Notebook A4', 'Stationery', 40.00, 9),
('Ball Pen Pack', 'Stationery', 25.00, 9),
('Cooking Oil 1L', 'Groceries', 140.00, 8),
('Shampoo 200ml', 'Personal Care', 180.00, 7),
('Toothpaste', 'Personal Care', 95.00, 7),
('Laptop Mouse', 'Electronics', 350.00, 3),
('Sugar 1kg', 'Groceries', 50.00, 8),
('Salt 1kg', 'Groceries', 20.00, 8),
('Extension Cord', 'Electronics', 250.00, 6),
('Milk Powder', 'Groceries', 320.00, 2),
('Handwash', 'Personal Care', 110.00, 7),
('Stapler', 'Stationery', 85.00, 9),
('Ceiling Light', 'Electronics', 650.00, 6),
('Tea Powder 500g', 'Groceries', 210.00, 8),
('Floor Cleaner', 'Home Care', 160.00, 7),
('Markers Pack', 'Stationery', 120.00, 9);

INSERT INTO inventory (product_id, quantity_in_stock, reorder_level) VALUES
(1, 100, 20),
(2, 80, 20),
(3, 50, 10),
(4, 60, 15),
(5, 120, 30),
(6, 200, 50),
(7, 90, 25),
(8, 70, 15),
(9, 65, 15),
(10, 40, 10),
(11, 110, 20),
(12, 150, 30),
(13, 55, 10),
(14, 45, 10),
(15, 85, 20),
(16, 95, 25),
(17, 35, 10),
(18, 75, 20),
(19, 60, 15),
(20, 130, 40);

SELECT * FROM products;
SELECT * FROM inventory;

SELECT 
    p.product_id,
    p.product_name,
    p.category,
    p.price,
    s.supplier_name
FROM products p
JOIN suppliers s 
    ON p.supplier_id = s.supplier_id;
    

SELECT 
    p.product_name,
    i.quantity_in_stock,
    i.reorder_level
FROM inventory i
JOIN products p 
    ON i.product_id = p.product_id;
    

SELECT 
    p.product_name,
    i.quantity_in_stock,
    i.reorder_level
FROM inventory i
JOIN products p 
    ON i.product_id = p.product_id
WHERE i.quantity_in_stock <= i.reorder_level;


UPDATE inventory 
SET quantity_in_stock = 5 
WHERE product_id = 3;

SELECT 
    SUM(p.price * i.quantity_in_stock) AS total_inventory_value
FROM products p
JOIN inventory i 
    ON p.product_id = i.product_id;
    

SELECT 
    category,
    COUNT(*) AS total_products
FROM products
GROUP BY category;

CREATE TABLE sales (
    sale_id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT,
    quantity_sold INT NOT NULL,
    sale_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE TABLE inventory_log (
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT,
    change_type VARCHAR(20),
    quantity_changed INT,
    change_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);


DELIMITER $$

CREATE TRIGGER after_sale_insert
AFTER INSERT ON sales
FOR EACH ROW
BEGIN
    -- Reduce stock
    UPDATE inventory
    SET quantity_in_stock = quantity_in_stock - NEW.quantity_sold
    WHERE product_id = NEW.product_id;

    -- Insert log record
    INSERT INTO inventory_log(product_id, change_type, quantity_changed)
    VALUES (NEW.product_id, 'SALE', NEW.quantity_sold);
END $$

DELIMITER ;

INSERT INTO sales (product_id, quantity_sold)
VALUES (1, 10);

SELECT * FROM inventory WHERE product_id = 1;

SELECT * FROM inventory_log;

DELIMITER $$

CREATE PROCEDURE sell_product (
    IN p_product_id INT,
    IN p_quantity INT
)
BEGIN
    DECLARE current_stock INT;

    START TRANSACTION;

    -- Get current stock
    SELECT quantity_in_stock 
    INTO current_stock
    FROM inventory
    WHERE product_id = p_product_id
    FOR UPDATE;

    -- Check stock
    IF current_stock >= p_quantity THEN
        
        INSERT INTO sales(product_id, quantity_sold)
        VALUES (p_product_id, p_quantity);

        COMMIT;

    ELSE
        ROLLBACK;
    END IF;

END $$

DELIMITER ;

CALL sell_product(2, 5);

SELECT * FROM inventory WHERE product_id = 2;

CALL sell_product(2, 1000);

CREATE TABLE purchases (
    purchase_id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT,
    supplier_id INT,
    quantity_purchased INT NOT NULL,
    purchase_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id)
);

DELIMITER $$

CREATE TRIGGER after_purchase_insert
AFTER INSERT ON purchases
FOR EACH ROW
BEGIN
    -- Increase stock
    UPDATE inventory
    SET quantity_in_stock = quantity_in_stock + NEW.quantity_purchased
    WHERE product_id = NEW.product_id;

    -- Insert into log
    INSERT INTO inventory_log(product_id, change_type, quantity_changed)
    VALUES (NEW.product_id, 'PURCHASE', NEW.quantity_purchased);
END $$

DELIMITER ;

INSERT INTO purchases (product_id, supplier_id, quantity_purchased)
VALUES (1, 2, 25);

SELECT * FROM inventory WHERE product_id = 1;

SELECT * FROM inventory_log ORDER BY change_date DESC;

CREATE VIEW inventory_status AS
SELECT 
    p.product_id,
    p.product_name,
    p.category,
    i.quantity_in_stock,
    i.reorder_level,
    CASE 
        WHEN i.quantity_in_stock <= i.reorder_level THEN 'LOW STOCK'
        ELSE 'IN STOCK'
    END AS stock_status
FROM products p
JOIN inventory i 
    ON p.product_id = i.product_id;
    

SELECT * FROM inventory_status;

CREATE VIEW sales_report AS
SELECT 
    s.sale_id,
    p.product_name,
    s.quantity_sold,
    s.sale_date,
    (p.price * s.quantity_sold) AS total_sale_amount
FROM sales s
JOIN products p 
    ON s.product_id = p.product_id;
    
SELECT * FROM sales_report;

SELECT 
    DATE_FORMAT(s.sale_date, '%Y-%m') AS sale_month,
    SUM(p.price * s.quantity_sold) AS monthly_revenue
FROM sales s
JOIN products p 
    ON s.product_id = p.product_id
GROUP BY sale_month
ORDER BY sale_month;

SELECT 
    p.product_name,
    SUM(s.quantity_sold) AS total_units_sold
FROM sales s
JOIN products p 
    ON s.product_id = p.product_id
GROUP BY p.product_name
ORDER BY total_units_sold DESC;

SELECT 
    s.supplier_name,
    COUNT(p.product_id) AS total_products
FROM suppliers s
LEFT JOIN products p 
    ON s.supplier_id = p.supplier_id
GROUP BY s.supplier_name;

SELECT 
    s.supplier_name,
    SUM(p.price * sa.quantity_sold) AS total_revenue
FROM sales sa
JOIN products p 
    ON sa.product_id = p.product_id
JOIN suppliers s 
    ON p.supplier_id = s.supplier_id
GROUP BY s.supplier_name
ORDER BY total_revenue DESC;

CREATE INDEX idx_product_name 
ON products(product_name);

CREATE INDEX idx_category 
ON products(category);

CREATE INDEX idx_sale_date 
ON sales(sale_date);

CREATE INDEX idx_supplier_id 
ON products(supplier_id);

SELECT * FROM products 
WHERE product_name = 'Rice 1kg';

CREATE INDEX idx_sales_product_date
ON sales(product_id, sale_date);

CREATE ROLE inventory_admin;
CREATE ROLE sales_staff;
CREATE ROLE report_analyst;

GRANT ALL PRIVILEGES 
ON retail_inventory_db.* 
TO inventory_admin;

GRANT INSERT, SELECT 
ON retail_inventory_db.sales 
TO sales_staff;

GRANT SELECT 
ON retail_inventory_db.products 
TO sales_staff;

GRANT SELECT 
ON retail_inventory_db.inventory 
TO sales_staff;

GRANT SELECT 
ON retail_inventory_db.inventory_status 
TO report_analyst;

GRANT SELECT 
ON retail_inventory_db.sales_report 
TO report_analyst;

GRANT inventory_admin TO 'root'@'localhost';

INSERT INTO sales (product_id, quantity_sold, sale_date)
VALUES
(1, 5, '2026-01-10'),
(2, 8, '2026-02-15'),
(3, 6, '2026-03-20'),
(4, 4, '2026-04-05'),
(5, 10, '2026-05-18');


INSERT INTO sales (product_id, quantity_sold, sale_date)
VALUES
(1, 5, '2026-01-10'),
(2, 8, '2026-02-15'),
(3, 6, '2026-03-20'),
(4, 4, '2026-04-05'),
(5, 10, '2026-05-18');