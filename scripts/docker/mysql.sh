#!/bin/sh
set -e
docker run -di --name mysql -p 3306:3306 -e MYSQL_ROOT_PASSWORD=root mysql
docker exec -it mysql /bin/bash -c 'sed -i "/symbolic-links=0/a\default-authentication-plugin=mysql_native_password" /etc/mysql/my.cnf'
docker exec -it mysql /bin/bash -c 'sed -i "/symbolic-links=0/a\character-set-server=utf8mb4" /etc/mysql/my.cnf'
docker exec -it mysql /bin/bash -c "sed -i \"/symbolic-links=0/a\init_connect=\'SET NAMES utf8mb4\'\" /etc/mysql/my.cnf"
docker restart mysql
docker exec -it mysql /bin/bash -c "mysql -uroot -proot mysql -e \"alter user root@'%' identified with mysql_native_password by 'root';\""
echo "docker exec -it mysql /bin/bash"
echo "docker rm mysql -f"
 
