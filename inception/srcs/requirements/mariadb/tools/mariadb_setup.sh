#!/bin/bash

# Sustituye variables en init.sql
bash /usr/local/bin/substitute_env_vars.sh

# Verifica si el directorio de datos de MariaDB está vacío
# Esto es crucial para la inicialización
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "[+] Directorio de datos de MariaDB vacío. Inicializando base de datos..."
    # Comando para inicializar MariaDB. Esto crea las tablas del sistema.
    mysql_install_db --user=mysql --datadir=/var/lib/mysql --auth-root-authentication-method=normal
    echo "[+] Base de datos MariaDB inicializada."
fi


# Inicia MariaDB en segundo plano
echo "[+] Lanzando mysqld..."
mysqld &

# Espera a que el socket esté disponible antes de continuar
echo "[+] Esperando conexión a MariaDB..."
while ! mysqladmin ping --silent; do
    echo "[+] Esperando a que MariaDB arranque..."
    sleep 1
done

# Ejecuta el SQL inicial (solo si no se ha ejecutado ya)
# Agregamos una bandera o un chequeo para evitar ejecutarlo cada vez
# Usamos un archivo de bandera para esto
if [ ! -f /var/lib/mysql/INITIALIZED_FLAG ]; then
    echo "[+] Ejecutando SQL inicial..."
    mysql -u root < /etc/mysql/init.sql
    touch /var/lib/mysql/INITIALIZED_FLAG
    echo "[+] SQL inicial ejecutado y bandera creada."
else
    echo "[+] SQL inicial ya ejecutado previamente. Saltando."
fi

# Mata el mysqld temporal (para que luego arranque en primer plano como proceso principal)
echo "[+] Deteniendo mysqld temporal..."
mysqladmin shutdown

# Ejecutamos mysqld como proceso principal del contenedor
echo "[+] Lanzando mysqld en primer plano..."
exec mysqld

# Mantiene el contenedor vivo
#tail -f /dev/null