-- lesson_4
USE vk;
SHOW TABLES;

-- users
SELECT * FROM users;
SELECT COUNT(*) FROM users; -- 500, это важно

-- profiles
SELECT * FROM profiles;
CREATE TEMPORARY TABLE sex (sex CHAR(1));
INSERT INTO sex VALUES ('m'), ('f');
UPDATE profiles SET sex = (SELECT sex FROM sex ORDER BY RAND() LIMIT 1);

-- messages
SELECT * FROM messages;
UPDATE messages SET
    from_user_id = FLOOR(1 + (RAND() * 500)),
    to_user_id = FLOOR(1 + (RAND() * 500));

-- media_types
SELECT * FROM media_types;
TRUNCATE media_types;
INSERT INTO media_types (name) VALUES
    ('photo'),
    ('video'),
    ('audio');

-- media
SELECT * FROM media;
UPDATE media SET size = FLOOR(1 + (RAND() * 999999)); -- нет в лекции, считаю необходимо, чтобы не было файлов размером 0
UPDATE media SET media_type_id = FLOOR(1 + (RAND() * 3));
UPDATE media SET user_id = FLOOR(1 + (RAND() * 500));
UPDATE media SET filename = CONCAT('https://dropbox/vk/file_', size);
UPDATE media SET user_id = FLOOR(1 + (RAND() * 500));
UPDATE media SET metadata = CONCAT(
    '{"', size, '":"',
    (SELECT CONCAT(first_name, ' ', last_name) FROM users WHERE id = user_id),
    '"}');
DESC media;
ALTER TABLE media MODIFY COLUMN metadata JSON;
SELECT * FROM media where size like 0;

-- friendship
SELECT * FROM friendship;
UPDATE friendship SET
    user_id = FLOOR(1 + (RAND() * 500)),
    friend_id = FLOOR(1 + (RAND() * 500));
DESC friendship;
SELECT * FROM friendship WHERE user_id = friend_id;

-- friendship_statuses
SELECT * FROM friendship_statuses;
TRUNCATE friendship_statuses;
INSERT INTO friendship_statuses (name) VALUES ('Requested'), ('Confirmed');

-- friendship
SELECT * FROM friendship;
UPDATE friendship SET status_id = FLOOR(1 + (RAND() * 3));

-- communities
SELECT * FROM communities;
DELETE FROM communities WHERE id > 20;

-- communities_users
SELECT * FROM communities_users;
UPDATE communities_users SET
    community_id = FLOOR(1 + (RAND() * 20)),
    user_id = FLOOR(1 + (RAND() * 500));

-- add 'posts' table
CREATE TABLE posts (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    user_id INT UNSIGNED NOT NULL,
    header VARCHAR(255),
    body TEXT NOT NULL,
    media_id INT UNSIGNED,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP);
SHOW TABLES;
DESC posts;

-- add 'updated_at' column to profiles
ALTER TABLE profiles ADD COLUMN updated_at DATETIME DEFAULT NOW() ON UPDATE NOW();
DESC profiles;

-- add 'Interrupted' friendship status
SELECT * FROM friendship_statuses;
INSERT INTO friendship_statuses (name) VALUE ('Interrupted');

UPDATE friendship SET status_id = FLOOR(1 + (RAND() * 3));
SELECT * FROM friendship;

-- add 'meetings' table
CREATE TABLE meetings (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(150) NOT NULL UNIQUE,
    scheduled_at DATETIME);
DESC meetings;
