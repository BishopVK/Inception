Aquí tienes la versión modificada de tu script requirements/wordpress/tools/wp_setup.sh:

#!/bin/bash

# Aseguramos que el directorio principal de WordPress exista y navegamos a él
mkdir -p /var/www/html
cd /var/www/html

# Instalar WordPress si wp-config.php no existe.
# Esto se ejecuta solo en la primera inicialización o si los volúmenes se borran.
if [ ! -f /var/www/html/wp-config.php ]; then
    echo "[+] WordPress no detectado. Iniciando instalación..."

    # Copiar www.conf antes de iniciar php-fpm
    cp /usr/local/etc/php-fpm-www.conf /etc/php/7.4/fpm/pool.d/www.conf

    # Descargar WP-CLI si no existe
    if [ ! -f /usr/local/bin/wp ]; then
        echo "[+] Descargando WP-CLI..."
        curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
        chmod +x wp-cli.phar
        mv wp-cli.phar /usr/local/bin/wp
    fi

    # Descargar e instalar WordPress
    echo "[+] Descargando el core de WordPress..."
    wp core download --allow-root

    echo "[+] Creando wp-config.php..."
    wp config create \
        --dbname="$DB_DATABASE" \
        --dbuser="$DB_USER_NAME" \
        --dbpass="$DB_USER_PASSWORD" \
        --dbhost="$DB_HOSTNAME" \
        --allow-root

    echo "[+] Realizando la instalación principal de WordPress..."
    wp core install \
        --url="$DOMAIN_NAME" \
        --title="Inception" \
        --admin_user="$WP_USER" \
        --admin_password="$WP_PASSWORD" \
        --admin_email="$WP_EMAIL" \
        --skip-email \
        --allow-root

    echo "[+] WordPress instalado. Realizando configuraciones iniciales de la web..."

    # --- INICIO DE PERSONALIZACIÓN DE LA WEB ---

    # 1. Eliminar el post por defecto "Hello world!"
    echo "[+] Eliminando post y página por defecto de WordPress..."
    wp post delete $(wp post list --post_type=post --posts_per_page=1 --format=ids --allow-root) --force --allow-root
    wp post delete $(wp post list --post_type=page --posts_per_page=1 --format=ids --allow-root) --force --allow-root
    echo "[+] Posts/páginas por defecto eliminados (si existían)."


    # 2. Crear una nueva página "Inicio" con contenido personalizado
    echo "[+] Creando la página de 'Inicio' personalizada..."
    # Puedes personalizar este contenido HTML a tu gusto
    CUSTOM_PAGE_CONTENT="<h1>Bienvenido a mi proyecto Inception!</h1><p>Esta es la página de inicio personalizada.</p><p>¡El servidor Nginx, WordPress y MariaDB están funcionando correctamente!</p>"
    
    # Crea la página y captura su ID
    HOME_PAGE_ID=$(wp post create \
        --post_type=page \
        --post_title="Inicio" \
        --post_status=publish \
        --post_content="$CUSTOM_PAGE_CONTENT" \
        --allow-root \
        --porcelain) # --porcelain devuelve solo el ID

    if [ -n "$HOME_PAGE_ID" ]; then
        echo "[+] Página 'Inicio' creada con ID: $HOME_PAGE_ID"
    else
        echo "[!] ERROR: No se pudo crear la página 'Inicio'. El ID está vacío."
    fi


    # 3. Configurar WordPress para que 'Inicio' sea la página de inicio estática
    echo "[+] Estableciendo la página 'Inicio' como página de inicio estática (show_on_front)..."
    wp option update show_on_front 'page' --allow-root
    echo "[+] Estableciendo la página 'Inicio' como página de inicio estática (page_on_front)..."
    if [ -n "$HOME_PAGE_ID" ]; then
        wp option update page_on_front $HOME_PAGE_ID --allow-root
    else
        echo "[!] ADVERTENCIA: No se pudo establecer page_on_front porque el ID de la página 'Inicio' no se obtuvo."
    fi


    # 4. Configurar permalinks a un formato amigable (ej. /%postname%/)
    echo "[+] Configurando permalinks amigables..."
    wp rewrite structure '/%postname%/' --allow-root
    wp rewrite flush --allow-root # Esto es importante para que los cambios de permalink surtan efecto
    echo "[+] Permalinks configurados y refrescados."

    echo "[+] Configuración inicial de la web completada."
    # --- FIN DE PERSONALIZACIÓN DE LA WEB ---

else
    echo "[+] WordPress ya está instalado. Saltando configuración inicial y personalización."
    # Si WordPress ya está instalado, solo lanza php-fpm
fi

# Lanzar php-fpm en primer plano (siempre se ejecuta)
echo "[+] Iniciando php-fpm7.4 en primer plano..."
php-fpm7.4 -F
