# INSTALAR MARIADB DOCKER CON DOCKERFILE:

## CREAR DOCKERFILE
	# Imagen base mínima
	FROM debian:bullseye

	# Instalamos MariaDB y limpiamos cache
	RUN apt-get update && \
		apt install mariadb-server -y && \
		apt-get clean

	# Declaramos el puerto que usará nginx (sólo informativo)
	EXPOSE 3306

	# Comando que se ejecutará cuando el contenedor arranca
	CMD ["mysqld"]
>
	FROM debian:bullseye		Usamos Debian minimalista como base
	RUN apt-get update ...		Instalamos MariaDB en la imagen y limpiamos
	EXPOSE 3306					Declara el puerto 3306 como el que va a exponer nginx
								(no lo abre en el host)
	CMD ...						Al ejecutar mysqld, se inicia el daemon del servidor de MariaDB,
								que es responsable de manejar las conexiones de los clientes,
								gestionar las bases de datos, y realizar operaciones de lectura y escritura.

## CREAR .env
### Definimos una variable que podremos usar en Makefile o docker-compose
	MARIADB_PORT=3306

## CREAR Makefile
	include .env

	NAME	=	mariadb

	build:
		docker build -t $(NAME) ./srcs/requirements/mariadb

	run:
		docker run -d -p $(MARIADB_PORT):3306 --name $(NAME) $(NAME)

	stop:
		docker stop $(NAME)

	rm:
		docker rm $(NAME)

	re: stop rm build run
>
	build		Construye la imagen con nombre nginx
	run			Lanza un contenedor a partir de esa imagen
	stop		Detiene el contenedor si está corriendo
	rm			Elimina el contenedor
	re			Hace un rebuild completo: para, borra, construye y corre