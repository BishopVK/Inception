#!/bin/bash

# Asegura que el script se detenga si hay un error
set -e

# Sustituye variables en init.sql
echo "[+] Sustituyendo variables en init.temp.sql..."
bash /usr/local/bin/substitute_env_vars.sh

# Directorio de datos de MariaDB
DATADIR="/var/lib/mysql"

# Verifica si el directorio de datos de MariaDB está vacío
if [ ! -d "${DATADIR}/mysql" ]; then
    echo "[+] Directorio de datos de MariaDB vacío. Inicializando base de datos..."
    # Importante: ejecutar mysql_install_db con el usuario mysql
    mysql_install_db --user=mysql --datadir="${DATADIR}" --auth-root-authentication-method=normal
    echo "[+] Base de datos MariaDB inicializada."
else
    echo "[+] Base de datos MariaDB ya existente. Saltando inicialización."
fi

# Inicia MariaDB en segundo plano para poder ejecutar los comandos iniciales de SQL
# Usamos el usuario mysql y el datadir correcto
echo "[+] Lanzando mysqld en segundo plano para configuración inicial..."
mysqld --user=mysql --datadir="${DATADIR}" &
PID_MYSQLD=$! # Guarda el PID del proceso de mysqld

# Espera a que MariaDB esté *completamente* disponible para conexiones SQL
# Aumentamos el tiempo de espera y la robustez del chequeo.
echo "[+] Esperando a que MariaDB esté completamente disponible para conexiones..."
for i in {60..0}; do # Intenta durante 60 segundos
    if mysql -u root -p"${DB_ROOT_PASSWORD}" -h 127.0.0.1 -e "SELECT 1;" > /dev/null 2>&1; then
        echo "[+] MariaDB está listo para conexiones SQL."
        break
    fi
    echo "[+] Esperando a que MariaDB esté disponible... ($i segundos restantes)"
    sleep 1
done

if ! mysql -u root -p"${DB_ROOT_PASSWORD}" -h 127.0.0.1 -e "SELECT 1;" > /dev/null 2>&1; then
    echo "[!] ERROR: MariaDB no arrancó a tiempo o no aceptó conexiones SQL. Abortando."
    kill $PID_MYSQLD # Intentar matar el proceso en segundo plano si aún está vivo
    exit 1
fi

# Ejecuta el SQL inicial (solo si no se ha ejecutado ya)
INITIALIZED_FLAG="${DATADIR}/.INITIALIZED_FLAG"
if [ ! -f "$INITIALIZED_FLAG" ]; then
    echo "[+] Ejecutando SQL inicial..."
    mysql -u root -p"${DB_ROOT_PASSWORD}" -h 127.0.0.1 < /etc/mysql/init.sql
    touch "$INITIALIZED_FLAG"
    echo "[+] SQL inicial ejecutado y bandera creada."
else
    echo "[+] SQL inicial ya ejecutado previamente. Saltando."
fi

# Detiene el mysqld temporal que se inició en segundo plano
echo "[+] Deteniendo mysqld temporal para iniciar el proceso principal..."
kill $PID_MYSQLD
wait $PID_MYSQLD 2>/dev/null || true # Espera a que el proceso termine, ignorando errores si ya no existe

echo "[+] Configuración inicial de MariaDB completada."
echo "[+] Iniciando MariaDB en primer plano como el proceso principal del contenedor..."

# Reemplaza el proceso actual del script con mysqld en primer plano.
# Esto es CRUCIAL para que Docker gestione correctamente el ciclo de vida del contenedor
# y para que MariaDB sea el PID 1, manteniendo el contenedor vivo.
exec mysqld --user=mysql --datadir="${DATADIR}"
