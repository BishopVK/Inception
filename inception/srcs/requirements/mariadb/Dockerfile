# Imagen base mínima
FROM debian:bullseye

# Instalamos MariaDB y limpiamos cache
RUN apt-get update -y && \
	apt-get upgrade -y && \
	apt install mariadb-server -y && \
	apt-get clean

# Declaramos el puerto que usará nginx (sólo informativo)
EXPOSE 3306

# Comando que se ejecutará cuando el contenedor arranca
CMD ["mysqld"]
