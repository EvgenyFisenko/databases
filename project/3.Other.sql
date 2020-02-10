USE phone_store;

-- Представления
SELECT * FROM vendors_products_count;
SELECT * FROM orders_profiles_couriers_in_delivery;

-- Процедура применения скидки на определенный товар
SELECT id, name, price from products where id = 1;
CALL set_discount(1,15);
SELECT id, name, price from products where id = 1;

-- Таблица для сохранения тригером удаленных комментариев
DELETE FROM comments WHERE id in (1,2,3);
SELECT * FROM logs;

-- Скрипты характерных выборок. Средняя стоимость товаров вендора
SELECT v.name, avg(price)
FROM products p
JOIN vendors v
    on p.vendor_id = v.id
GROUP BY vendor_id
ORDER BY vendor_id;

-- Скрипты характерных выборок. Количестов товаров по статусу заказа
SELECT os.name, count(*)
FROM orders o
JOIN order_statuses
    os on o.status_id = os.id
GROUP BY status_id;

-- Скрипты характерных выборок. Все телефоны всех пользователей и курьеров
SELECT c.id, CONCAT(first_name,' ', last_name) name, phone
FROM couriers c
UNION
SELECT u.id,CONCAT(first_name,' ', last_name), phone
FROM profiles p
JOIN users u
    on p.user_id = u.id;

-- Скрипты характерных выборок. Все комментирии товаров определенного бренда
SELECT head, body
FROM comments
WHERE product_id = (SELECT id FROM vendors WHERE name LIKE 'LG');

-- Скрипты характерных выборок. Подтвержденные заказы самого молодого пользователя
SELECT *
FROM orders
WHERE (status_id = (SELECT id FROM order_statuses WHERE name LIKE 'confirmed'))
  and (user_id = (SELECT user_id FROM profiles ORDER BY birthday DESC LIMIT 1));

-- Скрипты характерных выборок. Адреса пользователя, купившего наибольшее количество одинакового товара
SELECT u.email, pr.address, od.quantity, p.name,
       (SELECT name from vendors WHERE id = p.vendor_id) vendor
FROM orders o
JOIN profiles pr
    on o.user_id = pr.user_id
JOIN users
    u on o.user_id = u.id
JOIN order_details od
    on o.id = od.order_id
JOIN products p
    on od.product_id = p.id
WHERE o.status_id = (SELECT id FROM order_statuses WHERE name LIKE 'finished')
ORDER BY od.quantity DESC
LIMIT 1;
