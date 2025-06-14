#!/bin/bash

# Asegurarse de que el script se detenga si hay un error
set -e

# Sustituye variables en init.sql
echo "[+] Sustituyendo variables en init.temp.sql..."
bash /usr/local/bin/substitute_env_vars.sh

# Directorio de datos de MariaDB
DATADIR="/var/lib/mysql"

# Comprobar si la base de datos se ha copiado al volumen y si el SQL inicial ya se ejecutó.
# Si el archivo de bandera no existe, significa que es la primera vez que se monta el volumen vacío.
INITIALIZED_FLAG="${DATADIR}/.INITIALIZED_FLAG_SQL" # Nueva bandera para SQL

if [ ! -f "$INITIALIZED_FLAG" ]; then
    echo "[+] Primera inicialización del volumen. Iniciando MariaDB temporalmente para ejecutar SQL inicial..."

    # Iniciamos mysqld en segundo plano, temporalmente, para ejecutar el SQL inicial.
    # No exponemos a la red aún y no validamos credenciales de root por simplicidad en este paso.
    mysqld_safe --datadir="${DATADIR}" --skip-networking --skip-grant-tables &
    PID_MYSQLD_TEMP=$!

    # Esperar a que el servidor mysqld temporal esté listo para comandos SQL
    echo "[+] Esperando a que mysqld temporal arranque..."
    for i in {30..0}; do
        if mysqladmin ping --silent --socket=/var/run/mysqld/mysqld.sock; then # Aseguramos usar el socket local
            echo "[+] mysqld temporal arrancado."
            break
        fi
        echo "[+] Esperando a que mysqld temporal arranque... ($i segundos restantes)"
        sleep 1
    done

    if ! mysqladmin ping --silent --socket=/var/run/mysqld/mysqld.sock; then
        echo "[!] ERROR: mysqld temporal no arrancó a tiempo. Abortando."
        kill $PID_MYSQLD_TEMP || true
        exit 1
    fi

    echo "[+] Ejecutando SQL inicial desde init.sql..."
    # Ejecutar init.sql. Como skip-grant-tables está activo, no necesitamos credenciales aquí.
    mysql --socket=/var/run/mysqld/mysqld.sock < /etc/mysql/init.sql

    # Crear la bandera para indicar que el SQL inicial ya se ejecutó
    touch "$INITIALIZED_FLAG"
    echo "[+] SQL inicial ejecutado y bandera '$INITIALIZED_FLAG' creada."

    # Detener el proceso mysqld temporal
    echo "[+] Deteniendo mysqld temporal..."
    kill $PID_MYSQLD_TEMP
    wait $PID_MYSQLD_TEMP 2>/dev/null || true # Espera a que termine, ignorando errores si ya murió

else
    echo "[+] MariaDB ya inicializado y SQL inicial ejecutado. Saltando setup."
fi

echo "[+] Iniciando MariaDB en primer plano como el proceso principal del contenedor..."
# Reemplaza el proceso del script con el proceso mysqld en primer plano.
# Esto es CRUCIAL para que Docker gestione correctamente el ciclo de vida del contenedor
# y para que MariaDB sea el PID 1, manteniendo el contenedor vivo sin loops infinitos.
exec mysqld --user=mysql --datadir="${DATADIR}"
