FROM debian:bullseye

RUN apt-get update && \
    apt-get install -y mariadb-server && \
    apt-get clean

# Creamos el directorio destino para evitar errores
RUN mkdir -p /etc/mysql

COPY ./tools/mariadb_setup.sh /usr/local/bin/mariadb_setup.sh
COPY ./conf/init.sql /etc/mysql/init.sql

RUN chmod +x /usr/local/bin/mariadb_setup.sh

CMD ["bash", "/usr/local/bin/mariadb_setup.sh"]