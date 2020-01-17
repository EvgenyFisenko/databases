/*
Практическое задание по теме “Операторы, фильтрация, сортировка и ограничение”
Используется БД shop созданная скриптом source04/shop.sql из 5-го урока.
1. Пусть в таблице users поля created_at и updated_at оказались незаполненными. Заполните их текущими датой и временем.
*/
USE shop;
SELECT * FROM users;
UPDATE users SET created_at=NOW(), updated_at=NOW();

/*
2. Таблица users была неудачно спроектирована. Записи created_at и updated_at были заданы типом VARCHAR
и в них долгое время помещались значения в формате "20.10.2017 8:10".
 */
DROP TABLE IF EXISTS users;
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) COMMENT 'Имя покупателя',
  birthday_at DATE COMMENT 'Дата рождения',
  created_at VARCHAR(255),
  updated_at VARCHAR(255)
) COMMENT = 'Покупатели';

DESCRIBE users;

INSERT INTO users (name, birthday_at, created_at, updated_at) VALUES
    ('Геннадий', '1990-10-05', '20.10.2017 8:10', '20.10.2019 8:10'),
    ('Наталья', '1984-11-12', '21.9.2016 8:10', '20.10.2019 8:10'),
    ('Александр', '1985-05-20', '22.8.2015 8:10', '20.10.2019 8:10'),
    ('Сергей', '1988-02-14', '23.7.2014 8:10', '20.10.2019 8:10'),
    ('Иван', '1998-01-12', '24.6.2013 8:10', '20.10.2019 8:10'),
    ('Мария', '1992-08-29', '25.5.2012 8:10', '20.10.2019 8:10');

SELECT * FROM users;

/*
2. Необходимо преобразовать поля к типу DATETIME, сохранив введеные ранее значения.
 */
UPDATE users SET created_at = STR_TO_DATE(created_at, '%d.%m.%Y %h:%i'),
                 updated_at = STR_TO_DATE(updated_at, '%d.%m.%Y %h:%i');
ALTER TABLE users MODIFY created_at DATETIME DEFAULT CURRENT_TIMESTAMP;
ALTER TABLE users MODIFY updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;

DESCRIBE users;
SELECT * FROM users;

/*
3. В таблице складских запасов storehouses_products в поле value могут встречаться самые разные цифры: 0,
если товар закончился и выше нуля, если на складе имеются запасы.
 */
TRUNCATE storehouses_products;
DESCRIBE storehouses_products;

INSERT INTO storehouses_products(STOREHOUSE_ID, PRODUCT_ID, VALUE) VALUES
    (1,2,0),
    (1,2,2500),
    (1,2,0),
    (1,2,30),
    (1,2,500),
    (1,2,1);

SELECT value FROM storehouses_products;

/*
3. Необходимо отсортировать записи таким образом, чтобы они выводились в порядке увеличения значения value.
Однако, нулевые запасы должны выводиться в конце, после всех записей
 */
SELECT value FROM storehouses_products ORDER BY value=0, value;

/*
4. (по желанию) Из таблицы users необходимо извлечь пользователей, родившихся в августе и мае.
Месяцы заданы в виде списка английских названий ('may', 'august')
 */
SELECT * FROM users WHERE DATE_FORMAT(birthday_at, '%M') IN ('may', 'august');

/*
5. (по желанию) Из таблицы catalogs извлекаются записи при помощи запроса. SELECT * FROM catalogs WHERE id IN (5, 1, 2);
Отсортируйте записи в порядке, заданном в списке IN.
 */
SELECT * FROM catalogs WHERE id IN (5, 1, 2) ORDER BY id=5 DESC, id;

/*
Практическое задание теме “Агрегация данных”
1. Подсчитайте средний возраст пользователей в таблице users
 */
SELECT FLOOR(AVG(TIMESTAMPDIFF(YEAR, birthday_at, NOW()))) AS average FROM users;

/*
2. Подсчитайте количество дней рождения, которые приходятся на каждый из дней недели.
Следует учесть, что необходимы дни недели текущего года, а не года рождения.
 */
SELECT DATE_FORMAT(DATE_FORMAT(birthday_at, '2020-%m-%d %T'),'%W') AS day_of_week,
       COUNT(*) as birthddays_count FROM users GROUP BY day_of_week;

-- и тут видим что дни не повторяются, докидываем еще пользователей:
INSERT INTO users (name, birthday_at) VALUES
  ('Гена', '1990-10-05'),
  ('Ната', '1984-11-12'),
  ('Саша', '1985-05-20'),
  ('Серый', '1988-02-14');

-- и повторяем запрос:
SELECT DATE_FORMAT(DATE_FORMAT(birthday_at, '2020-%m-%d %T'),'%W') AS day_of_week,
       COUNT(*) as birthdday_count FROM users GROUP BY day_of_week;

/*
3. (по желанию) Подсчитайте произведение чисел в столбце таблицы
 */
SELECT id FROM catalogs;
SELECT round(exp(SUM(log(id)))) AS catalog_id_mul FROM catalogs;
