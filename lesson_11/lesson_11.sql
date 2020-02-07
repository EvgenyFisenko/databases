/*
Создайте таблицу logs типа Archive. Пусть при каждом СОЗДАНИИ записи в таблицах users, catalogs и products в таблицу
logs помещается время и дата создания записи, название таблицы, идентификатор первичного ключа и содержимое поля name.
 */

USE shop;

DROP TABLE IF EXISTS logs;
CREATE TABLE logs (
    id SERIAL,
    table_name VARCHAR(255) COMMENT 'Название целевой таблицы',
    type VARCHAR(255) COMMENT 'Тип операции',
    target_table_id INT COMMENT 'Поле id в целевой таблице',
    target_table_name VARCHAR(255) COMMENT 'Поле name целевой таблицы',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) COMMENT = 'insert/update log for users, catalogs, products' ENGINE=Archive;

SHOW TRIGGERS;

DROP TRIGGER IF EXISTS after_insert_users;
CREATE TRIGGER after_insert_users AFTER INSERT ON users
FOR EACH ROW BEGIN
    INSERT INTO logs(table_name, type, target_table_id, target_table_name) VALUES
    ('users','INSERT', NEW.id, NEW.name);
END;

DROP TRIGGER IF EXISTS after_update_users;
CREATE TRIGGER after_update_users AFTER UPDATE ON users
FOR EACH ROW BEGIN
    INSERT INTO logs(table_name, type, target_table_id, target_table_name) VALUES
    ('users','UPDATE', NEW.id, NEW.name);
END;

DROP TRIGGER IF EXISTS after_insert_catalogs;
CREATE TRIGGER after_insert_catalogs AFTER INSERT ON catalogs
FOR EACH ROW BEGIN
    INSERT INTO logs(table_name, type, target_table_id, target_table_name) VALUES
    ('catalogs','INSERT', NEW.id, NEW.name);
END;

DROP TRIGGER IF EXISTS after_update_catalogs;
CREATE TRIGGER after_update_catalogs AFTER UPDATE ON catalogs
FOR EACH ROW BEGIN
    INSERT INTO logs(table_name, type, target_table_id, target_table_name) VALUES
    ('catalogs','UPDATE', NEW.id, NEW.name);
END;

DROP TRIGGER IF EXISTS after_insert_products;
CREATE TRIGGER after_insert_products AFTER INSERT ON products
FOR EACH ROW BEGIN
    INSERT INTO logs(table_name, type, target_table_id, target_table_name) VALUES
    ('products', 'INSERT', NEW.id, NEW.name);
END;

DROP TRIGGER IF EXISTS after_update_products;
CREATE TRIGGER after_update_products AFTER UPDATE ON products
FOR EACH ROW BEGIN
    INSERT INTO logs(table_name, type, target_table_id, target_table_name) VALUES
    ('products', 'UPDATE', NEW.id, NEW.name);
END;

INSERT INTO users (name, birthday_at) VALUES
  ('Геннадий A', '1990-10-05'),
  ('Наталья A', '1984-11-12');

INSERT INTO catalogs (name) VALUES
  ('Звуковые карты');

INSERT INTO products
  (name, description, price, catalog_id)
VALUES
  ('Intel Core i7', 'Процессор для настольных персональных компьютеров, основанных на платформе Intel.', 9999.00, 1);

UPDATE users SET name = 'Новое имя' WHERE id = 5;

SELECT * FROM logs;

/*
 Создайте SQL-запрос, который помещает в таблицу users миллион записей.
*/

-- таблица
DROP TABLE IF EXISTS users1;
CREATE TABLE users1 (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) COMMENT 'Имя покупателя',
  birthday_at DATE COMMENT 'Дата рождения',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) COMMENT = 'Покупатели';

SELECT * FROM users1;

-- не запросом, процедурой(100 записей)
DROP PROCEDURE IF EXISTS generate_data;

CREATE PROCEDURE generate_data()
BEGIN
  DECLARE i INT DEFAULT 0;
  WHILE i < 100 DO
    INSERT INTO users1 (name, birthday_at) VALUES (
      CONCAT('JOHN DOE',' ',FLOOR(RAND()*10000)),
      (SELECT NOW() - INTERVAL FLOOR(RAND() * 30) YEAR )
    );
    SET i = i + 1;
  END WHILE;
END;

CALL generate_data();

SELECT * FROM users1;

/*
В базе данных Redis подберите коллекцию для подсчета посещений с определенных IP-адресов.

SADD login_from 192.168.1.1
SADD login_from 192.168.1.2
SADD login_from 192.168.1.3
SADD login_from 192.168.1.4

> SCARD login_from
4

> SMEMBERS login_from
1) "192.168.1.3"
2) "192.168.1.2"
3) "192.168.1.1"
4) "192.168.1.4"


При помощи базы данных Redis решите задачу поиска имени пользователя по электронному адресу и наоборот,
поиск электронного адреса пользователя по его имени.

> set user_name user_email
OK
> set user_email user_name
OK
> get user_name
"user_email"
> get user_email
"user_name"


*/
