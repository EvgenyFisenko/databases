mysqldump -uroot -p example> example.dump
mysql -u root -p -e "DROP DATABASE IF EXISTS sample;CREATE DATABASE sample;"
mysql -u root -p sample< example.dump
mysql -u root -p -e "SHOW TABLES FROM sample;
pause
mysqldump -uroot -p --where="true limit 100" mysql help_keyword > help_keyword.dump
pause