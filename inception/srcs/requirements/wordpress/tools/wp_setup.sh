#!/bin/bash

# Descargar WP-CLI
cd /ust/local/bin
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
mv wp-cli.phar wp

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
  --title="Inception" \
  --admin_user="$WP_USER" \
  --admin_password="$WP_PASSWORD" \
  --admin_email="$WP_EMAIL" \
  --skip-email \
  --allow-root

# Lanzar php-fpm en primer plano
php-fpm7.4 -F