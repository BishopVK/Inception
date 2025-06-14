#!/bin/bash

# Sustituye variables en init.sql
bash /usr/local/bin/substitute_env_vars.sh

# Verifica si el directorio de datos de MariaDB está vacío
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "[+] Directorio de datos de MariaDB vacío. Inicializando base de datos..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql --auth-root-authentication-method=normal
    echo "[+] Base de datos MariaDB inicializada."
fi

# NO iniciamos mysqld en segundo plano aquí, porque lo haremos en primer plano al final

# Espera a que el socket esté disponible antes de continuar
# Necesitamos que mysqld esté escuchando para que mysqladmin pueda funcionar
# Vamos a iniciar mysqld temporalmente en segundo plano para el setup, y luego lo matamos
# Ojo: Una alternativa es usar --skip-networking en el primer mysqld y luego reiniciarlo.
# Pero para la simplicidad de Inception, podemos hacer esto:

echo "[+] Lanzando mysqld temporalmente para configuración..."
mysqld_safe --skip-networking --skip-grant-tables & # Inicia temporalmente sin red ni tablas de permisos para setup
PID_MYSQLD_TEMP=$! # Guarda el PID del proceso temporal

echo "[+] Esperando conexión a MariaDB (temporal)..."
while ! mysqladmin ping --silent; do
    echo "[+] Esperando a que MariaDB arranque temporalmente..."
    sleep 1
done

# Ejecuta el SQL inicial (solo si no se ha ejecutado ya)
if [ ! -f /var/lib/mysql/INITIALIZED_FLAG ]; then
    echo "[+] Ejecutando SQL inicial..."
    mysql -u root < /etc/mysql/init.sql
    touch /var/lib/mysql/INITIALIZED_FLAG
    echo "[+] SQL inicial ejecutado y bandera creada."
else
    echo "[+] SQL inicial ya ejecutado previamente. Saltando."
fi

# Detiene el proceso mysqld temporal si se inició
if [ -n "$PID_MYSQLD_TEMP" ]; then
    echo "[+] Deteniendo mysqld temporal..."
    kill $PID_MYSQLD_TEMP
    wait $PID_MYSQLD_TEMP 2>/dev/null # Espera a que termine, ignorando errores si ya murió
fi


echo "[+] Iniciando MariaDB en primer plano..."
exec mysqld # Esto reemplazará el script con el proceso mysqld