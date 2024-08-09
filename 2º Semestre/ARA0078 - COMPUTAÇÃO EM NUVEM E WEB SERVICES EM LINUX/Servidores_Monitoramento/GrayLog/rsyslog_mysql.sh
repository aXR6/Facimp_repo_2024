#!/bin/bash

# Variáveis de configuração
DB_NAME="Syslog"
DB_USER="rsyslog_user"
DB_PASS="rsyslog_password"
MARIADB_ROOT_PASS="root_password"
GRAYLOG_SERVER_IP="127.0.0.1"  # Substitua pelo IP do servidor Graylog

# Atualizar e instalar pacotes necessários
sudo apt-get update
sudo apt-get install -y rsyslog-mysql mariadb-server

# Configurar o MariaDB
sudo mysql -u root -p"${MARIADB_ROOT_PASS}" -e "CREATE DATABASE ${DB_NAME};"
sudo mysql -u root -p"${MARIADB_ROOT_PASS}" -e "CREATE USER '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASS}';"
sudo mysql -u root -p"${MARIADB_ROOT_PASS}" -e "GRANT INSERT ON ${DB_NAME}.* TO '${DB_USER}'@'localhost';"
sudo mysql -u root -p"${MARIADB_ROOT_PASS}" -e "FLUSH PRIVILEGES;"

# Criar tabela de logs no banco de dados
sudo mysql -u root -p"${MARIADB_ROOT_PASS}" ${DB_NAME} <<EOF
CREATE TABLE SystemEvents
(
    ID int unsigned not null auto_increment primary key,
    CustomerID int NULL,
    ReceivedAt datetime NULL,
    DeviceReportedTime datetime NULL,
    Facility smallint NULL,
    Priority smallint NULL,
    FromHost varchar(60) NULL,
    Message text,
    NTSeverity int NULL,
    Importance int NULL,
    EventSource varchar(60) NULL,
    EventUser varchar(60) NULL,
    EventCategory int NULL,
    EventID int NULL,
    EventBinaryData text NULL,
    MaxAvailable int NULL,
    CurrUsage int NULL,
    MinUsage int NULL,
    MaxUsage int NULL,
    InfoUnitID int NULL,
    SysLogTag varchar(60),
    EventLogType varchar(60),
    GenericFileName VarChar(60),
    SystemID int NULL
);
EOF

# Configurar o rsyslog para enviar logs ao Graylog
sudo bash -c "cat <<EOF >> /etc/rsyslog.conf

# Enviando LOGS para o servidor GrayLog
*.*    @@${GRAYLOG_SERVER_IP}:12201;RSYSLOG_SyslogProtocol23Format
EOF"

# Reiniciar o rsyslog para aplicar as mudanças
sudo systemctl restart rsyslog

# Feedback ao usuário
echo "Configuração do rsyslog para gravação de logs em MariaDB e envio ao Graylog configurada com sucesso."