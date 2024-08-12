#!/bin/bash

# Variáveis de configuração do Graylog
GRAYLOG_SERVER="192.7.0.28"  # Substitua pelo IP do seu servidor Graylog
GRAYLOG_PORT="1514"          # Porta GELF TCP que o Graylog está escutando

# Habilitar UFW
ufw enable

# Permitir tráfego para o Graylog (porta 9000 para a interface web e API)
ufw allow 9000/tcp

# Permitir tráfego para o rsyslog (portas 514 TCP/UDP para Syslog)
ufw allow 514/tcp
ufw allow 514/udp

# Permitir tráfego para o rsyslog (portas 1514 TCP/UDP para Syslog)
ufw allow 1514/tcp
ufw allow 1514/udp

# Permitir tráfego para MongoDB (porta 27017)
ufw allow 27017/tcp

# Permitir tráfego para MariaDB (porta 3306)
ufw allow 3306/tcp

# Permitir tráfego para OpenSearch (porta 9200 para a interface REST)
ufw allow 9200/tcp

# Permitir tráfego para OpenSearch (porta 9300 para o transporte de nós)
ufw allow 9300/tcp

# Configurar rsyslog para enviar logs do UFW para o Graylog
bash -c "cat <<EOF > /etc/rsyslog.d/20-ufw-graylog.conf
# Envia logs do UFW para o Graylog via GELF TCP
module(load=\"omfwd\")
module(load=\"gelf\")

template(name=\"GraylogFormat\" type=\"list\"){
    constant(value=\"{\")
    constant(value=\"\\\"version\\\":\\\"1.1\\\",\")
    constant(value=\"\\\"host\\\":\\\"\")
    property(name=\"hostname\")
    constant(value=\"\\\",\")
    constant(value=\"\\\"short_message\\\":\\\"\")
    property(name=\"msg\")
    constant(value=\"\\\",\\\"timestamp\\\":\")
    property(name=\"timereported\" dateFormat=\"unixtimestamp\")
    constant(value=\",\\\"level\\\":\")
    property(name=\"syslogseverity\")
    constant(value=\"}\")
}

if \$msg contains \"UFW\" then {
    action(type=\"omfwd\"
        Target=\"${GRAYLOG_SERVER}\"
        Port=\"${GRAYLOG_PORT}\"
        Protocol=\"tcp\"
        Template=\"GraylogFormat\")
}
EOF"

# Reiniciar o rsyslog para aplicar as mudanças
systemctl restart rsyslog

# Exibir status do UFW para confirmar as regras
ufw status verbose

# Feedback para o usuário
echo "Regras do UFW configuradas e logs do UFW agora estão sendo enviados para o Graylog."
