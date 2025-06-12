#!/bin/bash

# Sustituye variables antes de lanzar MariaDB
/usr/local/bin/substitute_env_vars.sh

# Inicializa la base de datos si no existe (primera vez)
if [ ! -d "/var/lib/mysql/wordpress" ]; then
  echo "⚙️ Inicializando base de datos..."

  mysqld --user=mysql --bootstrap < /etc/mysql/init.sql
fi

# Inicia MariaDB en primer plano
exec mysqld

#mysql_install_db
#mysqld