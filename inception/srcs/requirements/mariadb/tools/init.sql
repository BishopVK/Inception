CREATE DATABASE IF NOT EXISTS ${DB_DATABASE};

-- Opcional, si quieres asegurar que root tiene contraseña (no es imprescindible)
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';

-- Crear el usuario solo si no existe
CREATE USER IF NOT EXISTS '${DB_USER_NAME}'@'%' IDENTIFIED BY '${DB_USER_PASSWORD}';

-- Dar acceso solo a la base de datos de WordPress
GRANT ALL PRIVILEGES ON ${DB_DATABASE}.* TO '${DB_USER_NAME}'@'%';

FLUSH PRIVILEGES;