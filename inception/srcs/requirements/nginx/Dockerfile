# Imagen base mínima
FROM debian:bullseye

# Instalamos nginx y limpiamos cache
RUN	apt-get update && \
	apt-get install -y nginx openssl && \
	apt-get clean

# Copiar el script y el archivo de configuración
COPY tools/generate_certs.sh /tmp/generate_certs.sh
COPY html/index.html /var/www/html/index.html
COPY conf/default.conf /etc/nginx/sites-available/default

# Dar permisos de ejecución al script y ejecutarlo
RUN chmod +x /tmp/generate_certs.sh && \
	/tmp/generate_certs.sh

RUN chmod -R 755 /var/www/html
RUN chown -R www-data:www-data /var/www/html

# Declaramos el puerto que usará nginx (sólo informativo)
EXPOSE 443

# Comando que se ejecutará cuando el contenedor arranca
CMD ["nginx", "-g", "daemon off;"]
