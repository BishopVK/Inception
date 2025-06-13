#!/bin/bash

# Sustituye variables antes de lanzar MariaDB
bash /usr/local/bin/substitute_env_vars.sh

# Inicia el servicio MariaDB
service mysql start

# Ejecuta el SQL inicial
mysql < /etc/mysql/init.sql

# Espera indefinidamente (mantiene el contenedor vivo)
tail -f /dev/null