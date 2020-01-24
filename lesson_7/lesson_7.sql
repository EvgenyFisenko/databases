/*
1.Составьте список пользователей users, которые осуществили хотя бы один заказ orders в интернет магазине.
 */
USE SHOP;
SELECT name
FROM users u
JOIN orders o
ON u.id = o.user_id;

-- тот же запрос + сумма заказов каждого пользователя
SELECT u.name , SUM(op.total) as price
FROM users u
JOIN orders o
ON u.id = o.user_id
    JOIN orders_products op
    ON o.id = op.order_id
GROUP BY u.name;

/*
2.Выведите список товаров products и разделов catalogs, который соответствует товару.
 */
SELECT p.name, c.name
FROM products p
JOIN catalogs c
ON p.catalog_id = c.id;

/*
3.(по желанию) Пусть имеется таблица рейсов flights (id, from, to) и таблица городов cities (label, name).
Поля from, to и label содержат английские названия городов, поле name — русское.
Выведите список рейсов flights с русскими названиями городов.
 */
DROP TABLE IF EXISTS flights;

CREATE TABLE flights (
    id SERIAL PRIMARY KEY,
    flight_from VARCHAR(255) COMMENT 'Отправление',
    flight_to VARCHAR(255) COMMENT 'Прибытие');

DROP TABLE IF EXISTS cities;

CREATE TABLE cities(
    label VARCHAR(255) COMMENT 'Направление',
    name VARCHAR(255) COMMENT 'Описание на русском');

INSERT INTO flights(flight_from, flight_to)
VALUES
       ('moscow', 'omsk'),
       ('novgorod','kazan'),
       ('irkutsk','moscow'),
       ('omsk','irkutsk'),
       ('moscow','kazan');

INSERT INTO cities(label, name)
VALUES
       ('moscow','Москва'),
       ('irkutsk', 'Иркутск'),
       ('novgorod', 'Новгород'),
       ('kazan','Казань'),
       ('omsk','Омск');

SELECT * FROM flights;
SELECT * FROM cities;

-- сам запрос
SELECT f.id, cf.name as flight_from , ct.name as flight_to
FROM flights f
JOIN cities cf
    JOIN cities ct
    ON f.flight_from = cf.label AND f.flight_to = ct.label
ORDER BY f.id;
