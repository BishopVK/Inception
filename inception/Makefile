#Makefile

NAME	=	inception

all: up

setup_dirs:
#	mkdir -p /home/danjimen/data/wordpress
#	mkdir -p /home/danjimen/data/mariadb
#	chown -R 101:101 /home/danjimen/data/mariadb

up:	setup_dirs
	docker compose -f srcs/docker-compose.yml up -d --build

down:
	docker compose -f srcs/docker-compose.yml down --remove-orphans

logs:
	docker compose -f srcs/docker-compose.yml logs -f

re: down up

clean:
	docker compose -f srcs/docker-compose.yml down --remove-orphans
	docker image prune -f

fclean:
	docker compose -f srcs/docker-compose.yml down --volumes --remove-orphans
	docker container prune -f
	docker image prune -af
	docker volume prune -f