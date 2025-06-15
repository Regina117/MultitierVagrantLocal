Troubleshooting Notes for Multi-Tier Web App Automation


## 1. Nginx (Frontend)
### Ошибка 502 Bad Gateway.
решение: 
 Добавить в /etc/hosts
echo "192.168.56.11 backend" | sudo tee -a /etc/hosts

команда для просмотра логов journalctl -u nginx -f

## 2. Tomcat (Backend)
### - Приложение не деплоится (vprofile-v2.war не распаковывается).
решение: 
 Проверить права на папку webapps
sudo chown -R tomcat:tomcat /opt/tomcat/webapps
 Вручную распаковать WAR
sudo unzip /opt/tomcat/webapps/vprofile-v2.war -d /opt/tomcat/webapps/ROOT
### - Ошибки Maven (mvn clean package).
решение: 
 Увеличить память Maven
export MAVEN_OPTS="-Xmx2048m -Xms512m"

команда для просмотра логов tail -f /opt/tomcat/logs/catalina.out

## 3. MySQL (Db)
### Нет подключения с бэкенда (Access denied for user 'multi'@'backend').
решение:
-- На сервере MySQL:
GRANT ALL ON multidb.* TO 'multi'@'192.168.56.%' IDENTIFIED BY 'multidev';
FLUSH PRIVILEGES;
### MySQL не слушает внешние подключения.
решение: 
 В файле /etc/mysql/mysql.conf.d/mysqld.cnf:
bind-address = 0.0.0.0
sudo systemctl restart mysql

команда для просмотра логов sudo tail -f /var/log/mysql/error.log

## 4. Redis (Cache)
### redis-cli -h 192.168.56.13 ping → Connection refused.
решение:
 Проверить конфиг Redis:
grep -E "bind|protected-mode" /etc/redis/redis.conf
 Должно быть:
bind 0.0.0.0
protected-mode no

sudo systemctl restart redis

## 5. RabbitMQ (Broker) 
### Веб-интерфейс не доступен (http://192.168.56.14:15672).
решение:
 Активировать плагин
sudo rabbitmq-plugins enable rabbitmq_management

 Добавить пользователя
sudo rabbitmqctl add_user admin secret
sudo rabbitmqctl set_user_tags admin administrator

###Ошибки AMQP (5672/tcp закрыт).
решение:
sudo ufw allow 5672/tcp
sudo ufw reload

команда для просмотра логов sudo journalctl -u rabbitmq-server -f

## 6. Переменные окружения Tomcat
### Приложение не видит DB_HOST, CACHE_HOST и т.д.
 Проверить setenv.sh
cat /opt/tomcat/bin/setenv.sh
 Должно содержать:
export DB_HOST="192.168.56.12"
export CACHE_HOST="192.168.56.13"

## 7. Проблемы с Manager App (Tomcat)
### Доступ к /manager/html запрещен.
<!-- В /opt/tomcat/conf/tomcat-users.xml -->
<user username="multi" password="multidev" roles="manager-gui,admin-gui"/>

