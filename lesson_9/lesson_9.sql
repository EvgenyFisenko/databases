-- Практическое задание по теме “Транзакции, переменные, представления”

/*
В базе данных shop и sample присутствуют одни и те же таблицы, учебной базы данных.
Переместите запись id = 1 из таблицы shop.users в таблицу sample.users. Используйте транзакции.
 */

DROP DATABASE IF EXISTS sample;
CREATE DATABASE sample;
USE sample;
DROP TABLE IF EXISTS users;
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) COMMENT 'Имя покупателя',
  birthday_at DATE COMMENT 'Дата рождения',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) COMMENT = 'Покупатели';

START TRANSACTION;
SELECT * FROM shop.users WHERE id = 1;
INSERT INTO sample.users (SELECT * FROM shop.users WHERE id = 1);
SELECT * FROM sample.users WHERE id = 1;
DELETE FROM shop.users WHERE id = 1;
SELECT * FROM shop.users WHERE id = 1;
COMMIT;

/*
Создайте представление, которое выводит название name товарной позиции из таблицы products и соответствующее
название каталога name из таблицы catalogs.
 */
USE shop;

CREATE OR REPLACE VIEW products_catalogs_view (product_name, catalog_name) AS
SELECT p.name, c.name
FROM products p
LEFT JOIN catalogs c
    on p.catalog_id = c.id;

SELECT * FROM products_catalogs_view;

-- Практическое задание по теме “Хранимые процедуры и функции, триггеры"

/*
Создайте хранимую функцию hello(), которая будет возвращать приветствие, в зависимости от текущего времени суток.
С 6:00 до 12:00 функция должна возвращать фразу "Доброе утро", с 12:00 до 18:00 функция должна возвращать фразу
"Добрый день", с 18:00 до 00:00 — "Добрый вечер", с 00:00 до 6:00 — "Доброй ночи".
 */

SHOW VARIABLES LIKE 'log_bin_trust_function_creators';
SET GLOBAL log_bin_trust_function_creators = 1;

DROP FUNCTION IF EXISTS hello;
CREATE FUNCTION hello()
RETURNS VARCHAR(16) NOT DETERMINISTIC
BEGIN
    DECLARE hn TINYINT DEFAULT hour(now());

    CASE
        WHEN hn >= 0 and hn < 6 THEN RETURN 'Доброй ночи';
        WHEN hn >= 6 and hn < 12 THEN RETURN 'Доброе утро';
        WHEN hn >= 12 and hn < 18 THEN RETURN 'Добрый день';
        ELSE RETURN 'Добрый вечер';
    END CASE;
END;

SHOW FUNCTION STATUS LIKE 'hello';
SELECT hello();

/*
В таблице products есть два текстовых поля: name с названием товара и description с его описанием.
Допустимо присутствие обоих полей или одно из них. Ситуация, когда оба поля принимают неопределенное значение
NULL неприемлема. Используя триггеры, добейтесь того, чтобы одно из этих полей или оба поля были заполнены.
При попытке присвоить полям NULL-значение необходимо отменить операцию.
 */

-- insert
DROP TRIGGER IF EXISTS before_insert_products;
CREATE TRIGGER before_insert_products BEFORE INSERT ON products
FOR EACH ROW BEGIN
    IF NEW.name IS NULL AND NEW.description IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Name & Description cant be NULL';
    END IF;
END;
SHOW TRIGGERS;

SELECT * FROM products;

INSERT INTO products
  (price, catalog_id)
VALUES
  (7890.00, 1);

-- update
DROP TRIGGER IF EXISTS before_update_products;
CREATE TRIGGER before_update_products BEFORE UPDATE ON products
FOR EACH ROW BEGIN
    IF NEW.name IS NULL AND NEW.description IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Name & Description cant be NULL';
    END IF;
END;
SHOW TRIGGERS;

SELECT * FROM products;
UPDATE products SET name = NULL, description = NULL WHERE id = 5;
UPDATE products SET name = NULL WHERE id = 14;
UPDATE products SET description = NULL WHERE id = 13;
