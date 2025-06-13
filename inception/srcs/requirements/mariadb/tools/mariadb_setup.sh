#!/bin/bash

# Sustituye variables en init.sql
bash /usr/local/bin/substitute_env_vars.sh

# Inicia MariaDB en segundo plano
echo "[+] Lanzando mysqld..."
mysqld &

# Espera a que el socket esté disponible antes de continuar
echo "[+] Esperando conexión a MariaDB..."
while ! mysqladmin ping --silent; do
    echo "[+] Esperando a que MariaDB arranque..."
    sleep 1
done

# Ejecuta el SQL inicial
mysql -u root < /etc/mysql/init.sql

# Mantiene el contenedor vivo
tail -f /dev/null