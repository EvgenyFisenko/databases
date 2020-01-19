/*
2. Пусть задан некоторый пользователь.
Из всех друзей этого пользователя найдите человека, который больше всех общался с нашим пользователем.
 */
USE VK;
-- пусть id заданного пользователя 13
SET @usr = 13;
SELECT *
FROM(
    (SELECT from_user_id AS u_id, COUNT(*) AS mes_cnt
    FROM messages
    WHERE to_user_id = @usr
        AND is_delivered = 1
    GROUP BY from_user_id)
    UNION
    (SELECT to_user_id, COUNT(*)
    FROM messages
    WHERE from_user_id = @usr
        AND is_delivered = 1
    GROUP BY to_user_id)) AS all_m
WHERE u_id IN(
    (SELECT friend_id
     FROM friendship
     WHERE user_id = @usr
        AND status_id IN (
            SELECT id
            FROM friendship_statuses
            WHERE name = 'Confirmed'
        )
    )
    UNION
    (SELECT user_id
     FROM friendship
     WHERE friend_id = @usr
        AND status_id IN (
            SELECT id
            FROM friendship_statuses
            WHERE name = 'Confirmed'
        )
    )
)
ORDER BY mes_cnt DESC
LIMIT 1;

/*
3. Подсчитать общее количество лайков, которые получили 10 самых молодых пользователей.
 */

SELECT SUM(cnt) AS likes_sum
FROM(
    SELECT COUNT(target_id) as cnt
    FROM likes
    WHERE target_id IN(
        SELECT *
        FROM(
            SELECT user_id
            FROM profiles
            ORDER BY birthday
            LIMIT 10)
            y)
    GROUP BY target_id
    ORDER BY cnt DESC)
ct;

/*
4.Определить кто больше поставил лайков (всего) - мужчины или женщины?
 */

SELECT
IF(
    (SELECT COUNT(id)
    FROM likes
    WHERE user_id IN(
        SELECT user_id
        FROM profiles
        WHERE sex = 'm'
        )
    ) >
    (SELECT COUNT(id)
    FROM likes
    WHERE user_id IN(
        SELECT user_id
        FROM profiles
        WHERE sex = 'f'
        )
    ),
    'male',
    'female'
) as more_from;

/*
 5.Найти 10 пользователей, которые проявляют наименьшую активность в использовании социальной сети.
 */

SELECT user_id, sum(cnts) as act FROM(
    (SELECT user_id, COUNT(*) as cnts
    FROM communities_users
    GROUP BY user_id)
    UNION
    (SELECT user_id, COUNT(*)
    FROM friendship
    GROUP BY user_id)
    UNION
    (SELECT friend_id, COUNT(*)
    FROM friendship
    WHERE status_id IN(
        SELECT id FROM friendship_statuses
            WHERE name = 'Confirmed'
        )
    GROUP BY friend_id)
    UNION
    (SELECT user_id, COUNT(*)
    FROM likes
    GROUP BY user_id)
    UNION
    (SELECT user_id, COUNT(*)
    FROM media
    GROUP BY user_id)
    UNION
    (SELECT user_id, COUNT(*)
    FROM meetings_users
    GROUP BY user_id)
    UNION
    (SELECT from_user_id, COUNT(*)
    FROM messages
    GROUP BY from_user_id)
    UNION
    (SELECT user_id, COUNT(*)
    FROM posts
    GROUP BY user_id)
    ) as all_act
GROUP BY user_id
ORDER BY act, user_id
LIMIT 10;
