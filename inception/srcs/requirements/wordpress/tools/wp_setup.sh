#!/bin/bash

# Instalar wordpress sino no existe ya. Aseguramos la persistencia al bajar y levantar contenedores.
# Siempre que no eliminemos los volumenes.
if [ -f /var/www/html/wp-config.php ]; then
    echo "[+] WordPress ya está instalado. Saltando configuración inicial."
    php-fpm7.4 -F
    exit 0
fi

# Copiar www.conf
cp /usr/local/etc/php-fpm-www.conf /etc/php/7.4/fpm/pool.d/www.conf

# Descargar WP-CLI si no existe
if [ ! -f /usr/local/bin/wp ]; then
  cd /usr/local/bin
  curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
  chmod +x wp-cli.phar
  mv wp-cli.phar wp
fi

# Preparar el directorio web
mkdir -p /var/www/html
cd /var/www/html

# Descargar e instalar WordPress
wp core download --allow-root
wp config create \
  --dbname="$DB_DATABASE" \
  --dbuser="$DB_USER_NAME" \
  --dbpass="$DB_USER_PASSWORD" \
  --dbhost="$DB_HOSTNAME" \
  --allow-root

wp core install \
  --url="$DOMAIN_NAME" \
  --title="danjimen's Inception" \
  --admin_user="$WP_USER" \
  --admin_password="$WP_PASSWORD" \
  --admin_email="$WP_EMAIL" \
  --skip-email \
  --allow-root

# Lanzar php-fpm en primer plano
php-fpm7.4 -F