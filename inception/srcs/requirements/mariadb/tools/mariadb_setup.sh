#!/bin/bash

# Sustituye variables antes de lanzar MariaDB
#/usr/local/bin/substitute_env_vars.sh

# Solo inicializa si no existe ya la base de datos
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "⚙️ Inicializando base de datos..."
    mysql_install_db --user=mysql > /dev/null
    mysqld --user=mysql --bootstrap < /etc/mysql/init.sql
fi

# Inicia MariaDB en primer plano
exec mysqld --user=mysql

#mysql_install_db
#mysqld