# Imagen base mínima
FROM debian:bullseye

# Instalamos MariaDB y limpiamos cache
RUN apt-get update -y && \
	apt-get upgrade -y && \
	apt install mariadb-server gettext -y && \
	apt-get clean

COPY requirements/mariadb/conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
COPY .env /etc/mysql/.env
COPY requirements/mariadb/tools/init.sql /etc/mysql/init.temp.sql
COPY requirements/mariadb/tools/substitute_env_vars.sh /usr/local/bin/substitute_env_vars.sh
COPY requirements/mariadb/tools/mariadb_setup.sh /usr/local/bin/mariadb_setup.sh

RUN chmod +x /usr/local/bin/*.sh
RUN mkdir /run/mysqld

#RUN /usr/local/bin/substitute_env_vars.sh
#RUN rm /etc/mysql/init.temp.sql
#RUN rm /etc/mysql/.env


#RUN chmod +x mariadb_setup.sh

# Declaramos el puerto que usará nginx (sólo informativo)
EXPOSE 3306

# Comando que se ejecutará cuando el contenedor arranca
#CMD ["mysqld"]
CMD ["/usr/local/bin/mariadb_setup.sh"]
