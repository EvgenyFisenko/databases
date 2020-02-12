-- Данная БД предназначена для интернет магазина по продаже мобильных телефонов
DROP DATABASE IF EXISTS phone_store;
CREATE DATABASE phone_store;
USE phone_store;

-- Таблица Производители
DROP TABLE IF EXISTS vendors;
CREATE TABLE vendors (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL COMMENT 'Бренд',
    detail VARCHAR(255) NOT NULL DEFAULT '' COMMENT 'Краткое описание',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) COMMENT = 'Производители';

-- Таблица Поставщики
DROP TABLE IF EXISTS suppliers;
CREATE TABLE suppliers (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL COMMENT 'Компания',
    address VARCHAR(255) NOT NULL DEFAULT '' COMMENT 'Адрес',
    phone VARCHAR(32) UNIQUE NOT NULL DEFAULT '' COMMENT 'Телефон',
    email VARCHAR(32) UNIQUE NOT NULL DEFAULT '' COMMENT 'Почта',
    info TEXT NOT NULL COMMENT 'Дополнительная информация',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) COMMENT = 'Поставщики';

-- Таблица Товары
DROP TABLE IF EXISTS products;
CREATE TABLE products (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    vendor_id INT UNSIGNED NOT NULL COMMENT 'Производитель',
    supplier_id INT UNSIGNED COMMENT 'Поставщик',
    name VARCHAR(100) UNIQUE NOT NULL COMMENT 'Название',
    description TEXT NOT NULL COMMENT 'Характеристики',
    price DECIMAL (9,2) COMMENT 'Цена',
    quantity INT UNSIGNED NOT NULL COMMENT 'Количество',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT products_vendor_id_fk
        FOREIGN KEY (vendor_id) REFERENCES vendors(id),
    CONSTRAINT products_supplier_id_fk
        FOREIGN KEY (supplier_id) REFERENCES suppliers(id)
            ON DELETE SET NULL,
    INDEX products_price_idx (price)
) COMMENT = 'Товары';

-- Таблица Пользователи
DROP TABLE IF EXISTS users;
CREATE TABLE users (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(32) NOT NULL UNIQUE COMMENT 'Почта',
    phone VARCHAR(32) NOT NULL UNIQUE COMMENT 'Телефон',
    hashed_password VARCHAR(255) NOT NULL UNIQUE COMMENT 'Хэшированный пароль',
    created_at DATETIME DEFAULT NOW(),
    updated_at DATETIME DEFAULT NOW() ON UPDATE NOW()
) COMMENT = 'Пользователи';

-- Таблица Профили
DROP TABLE IF EXISTS profiles;
CREATE TABLE profiles (
    user_id INT UNSIGNED NOT NULL PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL COMMENT 'Имя',
    last_name VARCHAR(100) NOT NULL COMMENT 'Фамилия',
    birthday DATE COMMENT 'Дата рождения',
    address VARCHAR(255) NOT NULL DEFAULT '' COMMENT 'Адрес',
    CONSTRAINT profiles_user_id_fk
        FOREIGN KEY (user_id) REFERENCES users(id)
            ON DELETE CASCADE,
    INDEX profiles_last_name_idx (last_name),
    INDEX profiles_birthday_idx(birthday)
) COMMENT = 'Профили';

-- Таблица Курьеры
DROP TABLE IF EXISTS couriers;
CREATE TABLE couriers (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL COMMENT 'Имя',
    last_name VARCHAR(100) NOT NULL COMMENT 'Фамилия',
    phone VARCHAR(32) NOT NULL UNIQUE COMMENT 'Телефон',
    created_at DATETIME DEFAULT NOW(),
    INDEX couriers_last_name_idx (last_name)
) COMMENT = 'Курьеры';

-- Таблица комментариев к товару на сайте
DROP TABLE IF EXISTS comments;
CREATE TABLE comments (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    user_id INT UNSIGNED NOT NULL COMMENT 'Пользователь',
    product_id INT UNSIGNED NOT NULL COMMENT 'Товар',
    head VARCHAR(255) NOT NULL DEFAULT '' COMMENT 'Заголовок',
    body TEXT NOT NULL COMMENT 'Комментарий',
    created_at DATETIME DEFAULT NOW(),
    updated_at DATETIME DEFAULT NOW() ON UPDATE NOW(),
    CONSTRAINT comments_user_id_fk
        FOREIGN KEY (user_id) REFERENCES users(id),
    CONSTRAINT comments_product_id_fk
        FOREIGN KEY (product_id) REFERENCES products(id)
            ON DELETE CASCADE,
    INDEX comments_head (head)
)COMMENT = 'Комментарии пользователей';

-- Таблица статусов заказа
DROP TABLE IF EXISTS order_statuses;
CREATE TABLE order_statuses (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE
)COMMENT = 'Статус заказа';

-- Таблица заказов
DROP TABLE IF EXISTS orders;
CREATE TABLE orders (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    user_id INT UNSIGNED NOT NULL COMMENT 'Пользователь',
    courier_id INT UNSIGNED NOT NULL COMMENT 'Курьер',
    status_id INT UNSIGNED NOT NULL COMMENT 'Статус',
    created_at DATETIME DEFAULT NOW(),
    updated_at DATETIME DEFAULT NOW() ON UPDATE NOW(),
    CONSTRAINT orders_user_id_fk
        FOREIGN KEY (user_id) REFERENCES users(id),
    CONSTRAINT orders_courier_id_fk
        FOREIGN KEY (courier_id) REFERENCES couriers(id),
    CONSTRAINT orders_status_id_fk
        FOREIGN KEY (status_id) REFERENCES order_statuses(id)
)COMMENT = 'Заказ';

-- Таблица Состав заказа
DROP TABLE IF EXISTS order_details;
CREATE TABLE order_details (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    order_id INT UNSIGNED NOT NULL COMMENT 'Заказ',
    product_id INT UNSIGNED NOT NULL COMMENT 'Товар',
    quantity INT UNSIGNED NOT NULL COMMENT 'Количество',
    CONSTRAINT order_detail_order_id_fk
        FOREIGN KEY (order_id) REFERENCES orders(id)
            ON DELETE RESTRICT,
    CONSTRAINT order_detail_product_id_fk
        FOREIGN KEY (product_id) REFERENCES products(id)
)COMMENT = 'Состав заказа';

-- Представление Количество единиц товара каждого бренда на складе
CREATE OR REPLACE VIEW vendors_products_count AS
SELECT v.name vendor, sum(p.quantity) in_stock
FROM products p
LEFT JOIN vendors v
    on p.vendor_id = v.id
GROUP BY v.name
ORDER BY v.name;

-- Представление Заказы на доставке, пользователь и его адрес, курьер и его контактный номер
CREATE OR REPLACE VIEW orders_profiles_couriers_in_delivery AS
SELECT  o.id, o.created_at, CONCAT(p.first_name,' ', p.last_name) order_user, p.address order_user_address,
       CONCAT(c.first_name,' ', c.last_name) courier_name, c.phone courier_phone
FROM orders o
JOIN order_statuses os
    on o.status_id = os.id
JOIN profiles p
    on o.user_id = p.user_id
JOIN couriers c
    on o.courier_id = c.id
WHERE os.name LIKE 'in_delivery'
ORDER BY created_at;

-- Процедура применения скидки на определенный товар
DROP PROCEDURE IF EXISTS set_discount;
CREATE PROCEDURE set_discount (item_id INT, discount INT)
BEGIN
    UPDATE products SET price = price * (1 - discount / 100) where id = item_id;
END;

-- Таблица для сохранения тригером удаленных коментариев
DROP TABLE IF EXISTS logs;
CREATE TABLE logs (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    user_email VARCHAR(255) NOT NULL COMMENT 'Email для связи с пользователем',
    product_name VARCHAR(255) NOT NULL COMMENT 'Товар',
    head VARCHAR(255) NOT NULL DEFAULT '' COMMENT 'Заголовок',
    body TEXT NOT NULL COMMENT 'Комментарий',
    deleted_at DATETIME DEFAULT NOW()
) COMMENT = 'archive comments' ENGINE=Archive;

-- Тригер для сохранения удаленных комментариев
DROP TRIGGER IF EXISTS before_delete_comments;
CREATE TRIGGER before_delete_comments BEFORE DELETE ON comments
FOR EACH ROW BEGIN
    INSERT INTO logs(user_email, product_name, head, body)
    VALUES(
        (SELECT email FROM users WHERE id = OLD.user_id),
        (SELECT name FROM products WHERE id = OLD.product_id),
        OLD.head,
        OLD.body
    );
END;
