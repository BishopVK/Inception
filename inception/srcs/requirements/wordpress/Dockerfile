# Imagen base mínima
FROM debian:bullseye

RUN	apt-get update -y && \
	apt-get upgrade -y && \
	apt-get install -y \
		php7.4-fpm \
		php7.4-mysqli \
		curl \
		mariadb-client \
		wget \
		unzip && \
	apt-get clean

# Crear directorios necesarios
RUN mkdir -p /var/www/html /run/php

# Copia opcional de archivos de configuración personalizados
COPY ./conf/php.ini /usr/local/etc/php/conf.d/custom.ini
COPY ./conf/www.conf /etc/php/7.4/fpm/pool.d/www.conf
COPY ./conf/www.conf /usr/local/etc/php-fpm-www.conf

COPY ./tools/wp_setup.sh /usr/local/bin/wp_setup.sh
RUN chmod +x /usr/local/bin/wp_setup.sh

# Declarar el puerto (informativo)
EXPOSE 9000

# Comando por defecto al arrancar el contenedor
CMD ["bash", "/usr/local/bin/wp_setup.sh"]