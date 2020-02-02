/*
Проанализировать какие запросы могут выполняться наиболее часто в процессе работы приложения и добавить
необходимые индексы.
 */

USE vk;
CREATE UNIQUE INDEX communities_name_uq ON communities(name);
CREATE INDEX media_filename_idx ON media(filename);
CREATE INDEX media_user_id_media_type_id_idx ON media(user_id, media_type_id);
CREATE INDEX posts_header_idx ON posts(header);
CREATE INDEX profiles_birthday_idx ON profiles(birthday);
CREATE UNIQUE INDEX users_email_uq ON users(email);
CREATE UNIQUE INDEX users_phone_uq ON users(phone);

/*
Некоторые индексы уже были созданы автоматически и mysql ругался на:
[HY000][1831] Duplicate index 'communities_name_uq' defined on the table 'vk.communities'.
This is deprecated and will be disallowed in a future release.
поэтому:
 */

DROP INDEX communities_name_uq ON communities;
DROP INDEX users_email_uq ON users;
DROP INDEX users_phone_uq ON users;

/*
Задание на оконные функции
Построить запрос, который будет выводить следующие столбцы:
имя группы
среднее количество пользователей в группах
самый молодой пользователь в группе
самый пожилой пользователь в группе
общее количество пользователей в группе
всего пользователей в системе
отношение в процентах (общее количество пользователей в группе / всего пользователей в системе) * 100
 */

SELECT DISTINCT c.name,
    AVG(gr_users.cnt) OVER () as avg,
    MAX(CONCAT(p.birthday, ' ', u.last_name, ' ', u.first_name)) OVER w as yangest,
    MIN(CONCAT(p.birthday, ' ', u.last_name, ' ', u.first_name)) OVER w as oldest,
    COUNT(cu.user_id) OVER w as users_in_group,
    (SELECT COUNT(u.id) FROM users u) as total_users,
    COUNT(cu.user_id) OVER w / (SELECT COUNT(u.id) FROM users u) * 100 as "%"
FROM communities_users cu
JOIN communities c
    on cu.community_id = c.id
JOIN users u
    on cu.user_id = u.id
JOIN profiles p
    on u.id = p.user_id
JOIN (SELECT community_id, COUNT(DISTINCT user_id) as cnt FROM communities_users GROUP BY community_id) gr_users
    on gr_users.community_id = c.id
WINDOW w AS (PARTITION BY cu.community_id);
