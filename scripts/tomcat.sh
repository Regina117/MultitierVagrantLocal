#!/bin/bash

# ===== Конфигурация =====
DB_HOST="192.168.56.12"
DB_PORT="3306"

CACHE_HOST="192.168.56.13"
CACHE_PORT="6379"

BROKER_HOST="192.168.56.14"
BROKER_PORT="5672"

# ===== Функции проверки =====
check_service() {
  local service=$1
  local host=$2
  local port=$3
  local timeout=5
  
  echo "Проверка подключения к ${service} (${host}:${port})..."
  
  if ! nc -z -w $timeout "$host" "$port"; then
    echo "❌ Ошибка: Не удалось подключиться к ${service}"
    echo "Проверьте:"
    echo "1. Запущен ли сервис на ${host}"
    echo "2. Открыт ли порт ${port}"
    echo "3. Доступность сети (ping ${host})"
    exit 1
  fi
  
  echo "✅ ${service} доступен"
}

# ===== Установка зависимостей =====
sudo apt update
sudo apt install -y mc openjdk-8-jdk maven wget mysql-server redis redis-tools netcat docker.io git 

# ===== Проверка всех сервисов =====
check_service "MySQL" "$DB_HOST" "$DB_PORT"
check_service "Redis" "$CACHE_HOST" "$CACHE_PORT"
check_service "RabbitMQ" "$BROKER_HOST" "$BROKER_PORT"

# ===== Настройка MySQL и Redis =====
sudo systemctl enable mysql
sudo systemctl start mysql
sudo systemctl enable redis-server
sudo systemctl start redis-server

# ===== Настройка Maven =====
export MAVEN_OPTS="-Xmx2048m -Xms512m"
mkdir -p ~/.m2

cat <<EOF > ~/.m2/settings.xml
<settings>
    <profiles>
        <profile>
            <id>default</id>
            <properties>
                <maven.compiler.source>1.8</maven.compiler.source>
                <maven.compiler.target>1.8</maven.compiler.target>
                <maven.compiler.encoding>UTF-8</maven.compiler.encoding>
                <maven.javadoc.skip>true</maven.javadoc.skip>
            </properties>
        </profile>
    </profiles>
</settings>
EOF

# ===== Установка Tomcat =====
sudo useradd -m -U -d /opt/tomcat -s /bin/false tomcat

wget https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.99/bin/apache-tomcat-9.0.99.tar.gz
sudo rm -rf /opt/tomcat
sudo tar -xzf apache-tomcat-9.0.99.tar.gz -C /opt
sudo mv /opt/apache-tomcat-9.0.99 /opt/tomcat
sudo rm -rf apache-tomcat-9.0.99.tar.gz

sudo chown -R tomcat:tomcat /opt/tomcat
sudo chmod -R u+x /opt/tomcat/bin
sudo chmod -R g+r /opt/tomcat/conf
sudo chmod -R g+w /opt/tomcat/logs /opt/tomcat/temp /opt/tomcat/work

sudo mkdir -p /opt/tomcat/logs
sudo mkdir -p /opt/tomcat/temp
sudo touch /opt/tomcat/temp/tomcat.pid
sudo chown -R tomcat:tomcat /opt/tomcat/temp/tomcat.pid

JAVA_HOME="$(readlink -f /usr/bin/java | sed "s:/bin/java::")"

# ===== Настройка сервиса Tomcat =====
cat <<EOF | sudo tee /etc/systemd/system/tomcat.service
[Unit]
Description=Apache Tomcat Web Application Container
After=network.target

[Service]
Type=simple
User=tomcat
Group=tomcat
Environment="JAVA_HOME=$JAVA_HOME"
Environment="JAVA_OPTS=-Djava.security.egd=file:///dev/urandom"
Environment="CATALINA_PID=/opt/tomcat/temp/tomcat.pid"
Environment="CATALINA_HOME=/opt/tomcat"
Environment="CATALINA_BASE=/opt/tomcat"
ExecStart=/opt/tomcat/bin/catalina.sh run
ExecStop=/opt/tomcat/bin/shutdown.sh
Restart=on-failure
RestartSec=10
UMask=0007

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable tomcat

# ===== Настройка RabbitMQ в переменных окружения =====
sudo tee /opt/tomcat/bin/setenv.sh <<EOF
#!/bin/sh
# DB connection
export DB_HOST="$DB_HOST"
export DB_PORT="$DB_PORT"

# Redis connection
export CACHE_HOST="$CACHE_HOST"
export CACHE_PORT="$CACHE_PORT"

# RabbitMQ connection
export BROKER_HOST="$BROKER_HOST"
export BROKER_PORT="$BROKER_PORT"
export BROKER_USERNAME="test"
export BROKER_PASSWORD="test"
export BROKER_VIRTUAL_HOST="/"
EOF

sudo chown tomcat:tomcat /opt/tomcat/bin/setenv.sh
sudo chmod +x /opt/tomcat/bin/setenv.sh

# ===== Настройка Manager =====
sudo sed -i '/<\/tomcat-users>/i \
<role rolename="manager-gui"/>\
<role rolename="manager-script"/>\
<role rolename="manager-jmx"/>\
<role rolename="manager-status"/>\
<role rolename="admin-gui"/>\
<user username="multi" password="multidev" roles="manager-gui,manager-script,manager-jmx,manager-status,admin-gui"/>' /opt/tomcat/conf/tomcat-users.xml

sudo sed -i 's/<Context>/<Context privileged="true">/' /opt/tomcat/webapps/manager/META-INF/context.xml
sudo sed -i 's/allow=".*"/allow="127\.\\d+\\.\\d+\\.\\d+|::1|0:0:0:0:0:0:0:1|192\.168\.56\.\\d+"/' /opt/tomcat/webapps/manager/META-INF/context.xml
sudo sed -i 's/<Context>/<Context privileged="true">/' /opt/tomcat/webapps/host-manager/META-INF/context.xml
sudo sed -i 's/allow=".*"/allow="127\.\\d+\\.\\d+\\.\\d+|::1|0:0:0:0:0:0:0:1|192\.168\.56\.\\d+"/' /opt/tomcat/webapps/host-manager/META-INF/context.xml

# ===== Запуск Tomcat =====
sudo systemctl start tomcat

echo "Проверка статуса Tomcat..."
sudo systemctl status tomcat --no-pager

echo "Tomcat доступен по адресу: http://192.168.56.11:8080/"
echo "Менеджер: http://192.168.56.11:8080/manager/html"
echo "Хост-менеджер: http://192.168.56.11:8080/host-manager/html"