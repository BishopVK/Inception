#Makefile

NAME	=	inception

all: up

setup_dirs:
	sudo mkdir -p /home/danjimen/data/wordpress
	sudo chown -R 101:101 /home/danjimen/data/wordpress
	sudo chmod 755 /home/danjimen/data/wordpress
	sudo mkdir -p /home/danjimen/data/mariadb
	sudo chown -R 101:101 /home/danjimen/data/mariadb
	sudo chmod 750 /home/danjimen/data/mariadb

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
	sudo rm -rf /home/danjimen/data/
	docker volume rm srcs_mariadb_data srcs_wordpress_data || true

volumes:
	docker volume ls
	docker volume inspect srcs_mariadb_data
	docker volume inspect srcs_wordpress_data

status:
	@echo "🟦 Docker containers:"
	@docker ps -a --filter name=nginx --filter name=wordpress --filter name=mariadb

	@echo "\n🟩 Docker volumes:"
	@docker volume ls | grep -E 'mariadb_data|wordpress_data' || echo "No volumes found"

	@echo "\n🟨 Docker volume paths:"
	@echo "MariaDB:    /home/danjimen/data/mariadb"
	@echo "WordPress:  /home/danjimen/data/wordpress"
	@sudo ls -l /home/danjimen/data/

	@echo "\n🟪 Docker network:"
	@docker network ls | grep inception || echo "No network found"