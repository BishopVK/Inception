# Imagen base mínima
FROM debian:bullseye

# Instalamos MariaDB y limpiamos cache
RUN apt-get update -y && \
    apt-get upgrade -y && \
    apt install mariadb-server gettext -y && \
    apt-get clean

# Preparamos el directorio de datos. Se inicializará aquí.
RUN mkdir -p /var/lib/mysql /run/mysqld \
    && chown -R mysql:mysql /var/lib/mysql /run/mysqld

# Copiamos el archivo de configuración antes de la inicialización
COPY requirements/mariadb/conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

# INICIALIZACIÓN DE LA BASE DE DATOS DURANTE EL BUILD
# Esto crea las tablas del sistema de MariaDB en la imagen.
# Cuando un volumen vacío se monta, MariaDB copiará estos archivos al volumen.
RUN mysql_install_db --user=mysql --datadir=/var/lib/mysql --auth-root-authentication-method=normal

# Copia los scripts y el .env
COPY .env /etc/mysql/.env
COPY requirements/mariadb/tools/init.sql /etc/mysql/init.temp.sql
COPY requirements/mariadb/tools/substitute_env_vars.sh /usr/local/bin/substitute_env_vars.sh
COPY requirements/mariadb/tools/mariadb_setup.sh /usr/local/bin/mariadb_setup.sh

# Dar permisos de ejecución a los scripts
RUN chmod +x /usr/local/bin/*.sh

# Declaramos el puerto que usará MariaDB (sólo informativo)
EXPOSE 3306

# Comando que se ejecutará cuando el contenedor arranca
# Este será nuestro script de setup final, que luego ejecuta mysqld en primer plano.
CMD ["/usr/local/bin/mariadb_setup.sh"]
