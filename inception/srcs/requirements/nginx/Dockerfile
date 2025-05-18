# Imagen base mínima
FROM debian:bullseye

# Instalamos nginx y limpiamos cache
RUN	apt-get update && \
	apt-get install -y nginx && \
	apt-get clean

# Declaramos el puerto que usará nginx (sólo informativo)
EXPOSE 80

# Comando que se ejecutará cuando el contenedor arranca
CMD ["nginx", "-g", "daemon off;"]
