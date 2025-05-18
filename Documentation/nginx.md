# INSTALAR NGINX DOCKER MANUALMENTE:

## CREAR CONTENEDOR DE NGINX
	docker run -d -p 8080:80 --name nginx-test nginx
>
	docker run:				Crea y ejecuta el contenedor
	-d						Modo "detached", o sea, en segundo plano
	-p 8080:80				Mapea el puerto 80 del contenedor al 8080 de tu máquina
	--name nginx-test		Le da un nonbre al contenedor
	nginx					Usa la imagen oficial de NGINX desde Docker Hub

## VERIFICAR QUE FUNCIONA
### Desde el navegador
	http://localhost:8080

### Desde la terminal
	curl http://localhost:8080

## VER CONTENEDORES ACTIVOS
### Mostrar los contenedores en ejecución
	docker ps

## ACCEDER AL CONTENEDOR
## Acceder desde bash (si está instalado)
	docker exec -it nginx-test /bin/bash

## Acceder desde sh
	docker exec -it nginx-test /bin/sh

## Comprobar que estás dentro del contenedor
### Ver la versión de nginx
	nginx -v
### Listar los ficheros dentro del directorio
	ls /etx/nginx
### Salir del contenedor
	exit

## PARAR Y ELIMINAR EL CONTENEDOR
### Detener el contenedor
	docker stop nginx-test
### Eliminar el contenedor
	docker rm nginx-test

---
---

# INSTALAR NGINX DOCKER CON DOCKERFILE:

## CREAR DOCKERFILE
	# Imagen base mínima
	FROM debian:bullseye

	# Instalamos nginx y limpiamos cache
	RUN apt-get update && \
		apt-get install -y nginx && \
		apt-get clean

	# Declaramos el puerto que usará nginx (solo informativo)
	EXPOSE 80

	# Comando que se ejecutará cuando el contenedor arranca
	CMD ["nginx", "-g", "daemon off;"]
>
	FROM debian:bullseye		Usamos Debian minimalista como base
	RUN apt-get update ...		Instalamos nginx en la imagen y limpiamos
	EXPOSE 80					Declara el puerto 80 como el que va a exponer nginx
								(no lo abre en el host)
	CMD ...						Ejecuta nginx en primer plano (daemon off)
								para que el contenedor se mantenga vivo

## CREAR .env
### Definimos una variable que podremos usar en Makefile o docker-compose
	NGINX_PORT=8080

## CREAR Makefile
	include .env

	NAME	=	nginx

	build:
		docker build -t $(NAME) ./srcs/requirements/nginx

	run:
		docker run -d -p $(NGINX_PORT):80 --name $(NAME) $(NAME)

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

---
---

# INSTALAR NGINX DOCKER CON DOCKER-COMPOSE:

## CREAR .env
	NGINX_PORT=443
	DOMAIN_NAME=danjimen.42.fr

## CREAR Dockerfile
	# Imagen base mínima
	FROM debian:bullseye

	# Instalamos nginx y limpiamos cache
	RUN apt-get update && \
		apt-get install -y nginx && \
		apt-get clean

	# Declaramos el puerto que usará nginx (solo informativo)
	EXPOSE 443

	# Comando que se ejecutará cuando el contenedor arranca
	CMD ["nginx", "-g", "daemon off;"]
>
	FROM debian:bullseye		Usamos Debian minimalista como base
	RUN apt-get update ...		Instalamos nginx en la imagen y limpiamos
	EXPOSE 80					Declara el puerto 80 como el que va a exponer nginx
								(no lo abre en el host)
	CMD ...						Ejecuta nginx en primer plano (daemon off)
								para que el contenedor se mantenga vivo

## CREAR docker-compose.yml
	version: "3.8"

	services:
	nginx:
		build:
		context: ./requirements/nginx
		container_name: nginx
		ports:
		- "${NGINX_PORT}:443"
		restart: always
		networks:
		- inception
		volumes:
		- nginx_data:/var/www/html

	volumes:
	nginx_data:

	networks:
	inception:
		driver: bridge

## CREAR Makefile
	# Makefile

	NAME=inception

	up:
		docker compose -f srcs/docker-compose.yml up -d --build

	down:
		docker compose -f srcs/docker-compose.yml down

	logs:
		docker compose -f srcs/docker-compose.yml logs -f

	re: down up