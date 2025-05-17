# GENERARL DOCKER COMANDS:

1. **Show the names of all the containers you have + the id you need and the port associated:**
	-	docker ps
	-	docker ps -a
2. **Pull an image from dockerhub**
	-	docker pull "NameOfTheImage"
3. **Show the logs of your last run of dockers:**
	-	docker "Three first letter of your docker"
4. **Allow to delete all the opened images:**
	-	docker rm $(docker ps -a -q)
5. **To execute the program with the shell:**
	-	docker exec -it "Three first letter of your docker" sh

<!-- ```bash
// Código con resaltado de sintaxis
console.log("Hola mundo"); -->

# DOCKER RUN:

1. **To run the docker image**
	-	docker run "name of the docker image"
2. **Run container in background**
	-	docker run -d
3. **Publish a container's port to the host**
	-	docker run -p
4. **Publish all exposed port to random ports**
	-	docker run -P
5. **The program will continue to run and we will be able to interact with the container**
	-	docker run -it "imageName"
6. **Give a name for the container instead an ID**
	-	docker run -name sl mysql
**Example:**
	-	docker run -d -p 7000:80 test:latest


# Docker image:

1. **Delete the image, if the image is running you need to kill it first**
	-	docker image rm -f "image name/id"
2. **Stop a running image**
	-	docker image kill "name"