# VIRTUAL MACHINE INSTALATION:
## 1.	Install in:
	sgoinfree

## 2.	Install config:
	Hostname:				Inception
	Domain name:			danjimen.42.fr
	Username:				danjimen
	Password:				Inception42
	Base memory:			2048 MB
	Processors:				1 CPU
	Virtual Hard Disk:		20.00 GB


# DEBIAN INITIALIZATION:
## 1.	Update:
	sudo apt update && sudo apt upgrade

## 2.	Add user "danjimen" to sudo group:
**Switch to root:**
-	su -

**Add danjimen to sudo group:**
-	usermod -aG sudo danjimen

**Check if the changes were successful:**
-	su - danjimen
-	sudo whoami (must return root)

**Reboot VM**


# INSTALL AND CONNECT VIA SSH
## 1. Install:
	sudo apt install openssh-server

## 2.1 Check if it is available and start
	sudo systemctl enable ssh
	sudo systemctl start ssh
## 2.2 Verify status
	sudo systemctl status ssh

## 3. Check port forwarding in VirtualBox
	VirtualBox > Settings > Network > Adapter 1 > Advanced > Port forwading:

	| Nombre | Protocolo | IP anfitrión | Puerto anfitrión | IP invitado | Puerto invitado |
	| ------ | --------- | ------------ | ---------------- | ----------- | --------------- |
	| SSH    | TCP       | vacío        | 2222             | vacío       | 22              |

## 4. Connect from the host
	ssh danjimen@localhost -p 2222


# INSTALL GIT:
## 1.1. Install:
	sudo apt install git -y
## 1.2. Verify install:
	git --version

## 2.1. Update Github identity:
	git config --global user.name danjimen
	git config --global user.email danjimen@student.42madrid.com

## 3.1. Generate SSH key:
	ssh-keygen -t ed25519 -C danjimen@student.42madrid.com
## 3.2. Copy public key:
	cat ~/.ssh/id_ed25519.pub
## 3.3. Paste key in GitHub SSH Keys section
## 3.4. Clone repository:
	git clone git@github.com:BishopVK/Inception.git
## 3.5. Verify SSH conexion:
	ssh -T git@github.com


# INSTALL DOCKER:
## 1. Follow docs.docker.com steps for install debian docker:
	# Add Docker's official GPG key:
	sudo apt-get update
	sudo apt-get install ca-certificates curl
	sudo install -m 0755 -d /etc/apt/keyrings
	sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
	sudo chmod a+r /etc/apt/keyrings/docker.asc

	# Add the repository to Apt sources:
	echo \
		"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
		$(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
		sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
	sudo apt-get update

	# Install the latest version:
	sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

	# Verify that the installation is successful
	sudo docker run hello-world
##	2. Add user to docker group
	sudo adduser danjimen docker
##	3. Reboot VM


# CREATE FOLDER STRUCTURE
	mkdir -p inception/srcs/requirements/{nginx,wordpress,mariadb}
	touch inception/Makefile
	touch inception/srcs/{.env,docker-compose-yml}
	touch inception/srcs/requirements/nginx/Dockerfile
	touch inception/srcs/requirements/wordpress/Dockerfile
	touch inception/srcs/requirements/mariadb/Dockerfile


# ADD NGINX CONTAINER

## 1. srcs/.env
	NGINX_PORT=443
	DOMAIN_NAME=danjimen.42.fr

## 2. srcs/requirements/nginx/Dockerfile
	FROM debian:bullseye

	RUN apt-get update && \
		apt-get install -y nginx openssl && \
		apt-get clean

	EXPOSE 443

	CMD ["nginx", "-g", "daemon off;"]

## 3. srcs/docker-compose.yml
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

## 4. Makefile
	# Makefile

	NAME=inception

	up:
		docker compose -f srcs/docker-compose.yml up -d --build

	down:
		docker compose -f srcs/docker-compose.yml down

	logs:
		docker compose -f srcs/docker-compose.yml logs -f

	re: down up

## 5. TESTING
### Start the NGINX container
	make up
### Shutdown and remove the NGINX container
	make down
