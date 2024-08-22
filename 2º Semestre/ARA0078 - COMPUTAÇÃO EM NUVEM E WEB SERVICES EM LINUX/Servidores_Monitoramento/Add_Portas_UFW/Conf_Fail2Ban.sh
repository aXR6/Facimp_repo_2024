#!/bin/bash

# Verificar se o usuário é root
if [ "$(id -u)" -ne 0 ]; then
  echo "Este script deve ser executado como root."
  exit 1
fi

# Instalar Fail2ban, UFW e rsyslog
echo "Instalando Fail2ban, UFW e rsyslog..."
apt update && apt install -y fail2ban ufw rsyslog

# Configurar o allowipv6 no Fail2ban
echo "Configurando 'allowipv6' no Fail2ban..."
if [ ! -f /etc/fail2ban/jail.local ]; then
  cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
fi

if ! grep -q "allowipv6" /etc/fail2ban/jail.local; then
  echo "Adicionando configuração 'allowipv6 = auto' em /etc/fail2ban/jail.local..."
  echo -e "\n[DEFAULT]\nallowipv6 = auto" >> /etc/fail2ban/jail.local
fi

# Detectar serviços ativos com portas abertas
echo "Detectando serviços ativos que utilizam portas de rede..."
services=$(ss -tunlp | awk 'NR>1 {print $1, $5, $7}' | awk -F':' '{print $1, $2}' | awk '{print $1, $2, $4}')

# Template para perfis do Fail2ban
fail2ban_template() {
  local service_name=$1
  local port=$2
  local filter=$3
  local logpath=$4

  cat <<EOL
[$service_name]
enabled = true
port = $port
filter = $filter
logpath = $logpath
maxretry = 5
EOL
}

# Função para criar um perfil Fail2ban e regra UFW baseado no serviço detectado
create_fail2ban_profile_and_ufw_rule() {
  local protocol=$1
  local port=$2
  local service_name=$3
  local logpath=""
  local filter=""

  case $service_name in
    sshd)
      filter="sshd"
      logpath="/var/log/auth.log"
      ;;
    apache2)
      filter="apache-auth"
      logpath="/var/log/apache2/*error.log"
      ;;
    nginx)
      filter="nginx-http-auth"
      logpath="/var/log/nginx/error.log"
      ;;
    docker)
      filter="docker"
      logpath="/var/log/docker.log"
      ;;
    *)
      filter="generic"
      logpath="/var/log/syslog"
      ;;
  esac

  # Criar o perfil do Fail2ban
  fail2ban_template $service_name $port $filter $logpath > /etc/fail2ban/jail.d/${service_name}_${port}.conf

  # Criar regra UFW para a porta detectada
  ufw allow ${port}/${protocol}
}

# Iterar sobre os serviços detectados e criar configurações do Fail2ban e UFW
echo "Configurando Fail2ban e UFW para serviços detectados..."
echo "$services" | while read protocol port service_info; do
  service_name=$(echo $service_info | awk -F'/' '{print $2}')
  if [ -n "$service_name" ]; then
    create_fail2ban_profile_and_ufw_rule $protocol $port $service_name
  fi
done

# Reiniciar Fail2ban para aplicar novas configurações
echo "Reiniciando o Fail2ban..."
systemctl restart fail2ban

# Configurar UFW
echo "Configurando UFW..."
ufw default deny incoming
ufw default allow outgoing

# Ativar UFW
echo "Ativando UFW..."
ufw enable

# Configuração do rsyslog para centralizar logs
echo "Configurando o rsyslog para centralizar logs..."
cat <<EOL >> /etc/rsyslog.conf

# Enviar todos os logs para um servidor central de logs (exemplo: logserver.local)
*.* @@logserver.local:514

# Configurar logs locais para serem mais detalhados
*.info;mail.none;authpriv.none;cron.none                /var/log/messages
authpriv.*                                              /var/log/secure
mail.*                                                  -/var/log/maillog
cron.*                                                  /var/log/cron
*.emerg                                                 *

EOL

# Configuração final e reinício de serviços
echo "Reiniciando serviços..."
systemctl restart ufw && systemctl status ufw
systemctl restart fail2ban && systemctl status fail2ban
systemctl restart rsyslog && systemctl status rsyslog

echo "Configuração concluída. UFW, Fail2ban e rsyslog foram configurados com base nos serviços ativos e portas detectadas."