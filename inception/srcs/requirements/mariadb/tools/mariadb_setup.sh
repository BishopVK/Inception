#!/bin/bash

# Sustituye variables antes de lanzar MariaDB
/usr/local/bin/substitute_env_vars.sh

# Inicia MariaDB en primer plano
exec mysqld

#mysql_install_db
#mysqld