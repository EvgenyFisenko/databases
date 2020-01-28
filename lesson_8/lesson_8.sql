USE vk;
-- communities
DESC communities;
ALTER TABLE communities
    ADD CONSTRAINT communities_photo_id_fk
        FOREIGN KEY (photo_id) REFERENCES media(id)
            ON DELETE SET NULL;

-- communities_users
DESC communities_users;
ALTER TABLE communities_users
    ADD CONSTRAINT communities_user_id_fk
        FOREIGN KEY (user_id) REFERENCES users(id)
            ON DELETE CASCADE;

-- friendship
DESC friendship;
ALTER TABLE friendship MODIFY COLUMN status_id INT(10) UNSIGNED;
ALTER TABLE friendship
    ADD CONSTRAINT friendship_user_id_fk
        FOREIGN KEY (user_id) REFERENCES users(id)
            ON DELETE CASCADE,
    ADD CONSTRAINT friendship_friend_id_fk
        FOREIGN KEY (friend_id) REFERENCES users(id)
            ON DELETE CASCADE,
    ADD CONSTRAINT friendship_status_id_fk
        FOREIGN KEY (status_id) REFERENCES friendship_statuses(id)
            ON DELETE SET NULL;

-- likes
DESC likes;
ALTER TABLE likes MODIFY COLUMN target_type_id INT(10) UNSIGNED;
ALTER TABLE likes
    ADD CONSTRAINT likes_user_id_fk
        FOREIGN KEY (user_id) REFERENCES users(id),
    ADD CONSTRAINT likes_target_type_id_fk
        FOREIGN KEY (target_type_id) REFERENCES target_types(id)
            ON DELETE SET NULL;

-- media
DESC media;
ALTER TABLE media MODIFY COLUMN media_type_id INT(10) UNSIGNED;
ALTER TABLE media
    ADD CONSTRAINT media_media_type_id_fk
        FOREIGN KEY (media_type_id) REFERENCES media_types(id)
            ON DELETE SET NULL,
    ADD CONSTRAINT media_user_id_fk
        FOREIGN KEY (user_id) REFERENCES users(id)
            ON DELETE CASCADE;

-- meetings_users
DESC meetings_users;
ALTER TABLE meetings_users
    ADD CONSTRAINT meetings_users_meetings_id_fk
        FOREIGN KEY (meeting_id) REFERENCES meetings(id)
            ON DELETE CASCADE,
    ADD CONSTRAINT meetings_users_user_id_fk
        FOREIGN KEY (user_id) REFERENCES users(id)
            ON DELETE CASCADE;

-- messages
DESC messages;
ALTER TABLE messages
    ADD CONSTRAINT messages_from_user_id_fk
        FOREIGN KEY (from_user_id) REFERENCES users(id),
    ADD CONSTRAINT messages_to_user_id_fk
        FOREIGN KEY (to_user_id) REFERENCES users(id);

-- posts
DESC posts;
ALTER TABLE posts
    ADD CONSTRAINT posts_user_id_fk
        FOREIGN KEY (user_id) REFERENCES users(id),
    ADD CONSTRAINT posts_media_id_fk
        FOREIGN KEY (media_id) REFERENCES media(id)
            ON DELETE SET NULL;

-- profiles
DESC profiles;
ALTER TABLE profiles MODIFY COLUMN photo_id INT(10) UNSIGNED;
ALTER TABLE profiles
    ADD CONSTRAINT profiles_user_id_fk
        FOREIGN KEY (user_id) REFERENCES users(id)
            ON DELETE CASCADE,
    ADD CONSTRAINT profiles_photo_id_fk
        FOREIGN KEY (photo_id) REFERENCES media(id)
            ON DELETE SET NULL;

/*
Пусть задан некоторый пользователь(13).
Из всех друзей этого пользователя найдите человека, который больше всех общался с нашим пользователем.
 */

SELECT m.from_user_id,
       CONCAT(u.first_name, ' ', u.last_name) as from_user_name,
       COUNT(m.from_user_id) as total_msgs
FROM messages m
JOIN friendship f
    ON m.from_user_id = f.user_id OR m.from_user_id = f.friend_id
JOIN users u
    ON m.from_user_id = u.id
JOIN friendship_statuses fs
    ON f.status_id = fs.id
WHERE m.to_user_id = 13 and fs.name = 'Confirmed'
GROUP BY from_user_id
ORDER BY total_msgs DESC
LIMIT 1;

/*
Подсчитать общее количество лайков, которые получили 10 самых молодых пользователей.
 */

SELECT COUNT(*) as likes_total
FROM likes l
JOIN (SELECT * FROM profiles ORDER BY birthday DESC LIMIT 10) p
    ON l.target_id = p.user_id
JOIN target_types tt
    ON l.target_type_id = tt.id
WHERE tt.name = 'users';

/*
Определить кто больше поставил лайков (всего) - мужчины или женщины?
 */

SELECT CASE(sex)
		WHEN 'm' THEN 'man'
		WHEN 'f' THEN 'woman'
	END AS sex,
	COUNT(*) as likes_count
FROM likes l
JOIN profiles p
    on l.user_id = p.user_id
GROUP BY sex
ORDER BY likes_count DESC
LIMIT 1;

/*
Найти 10 пользователей, которые проявляют наименьшую активность в использовании социальной сети.
 */

SELECT u.id, CONCAT(first_name, ' ', last_name) AS name,
       (COUNT(DISTINCT(l.id)) + COUNT(DISTINCT(m.id)) + COUNT(DISTINCT(ms.id))) AS act
FROM users u
LEFT JOIN likes l
    on u.id = l.user_id
LEFT JOIN media m
    on u.id = m.user_id
LEFT JOIN messages ms
    on u.id = ms.from_user_id
GROUP BY u.id
ORDER BY act
LIMIT 10;
