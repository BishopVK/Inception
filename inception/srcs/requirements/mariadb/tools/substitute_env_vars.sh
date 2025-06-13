#!/bin/bash

echo "[+] Sustituyendo variables en init.temp.sql..."

# Cargar variables de entorno
export $(grep -v '^#' /etc/mysql/.env | xargs)

# Sustituir variables en init.temp.sql
envsubst < /etc/mysql/init.temp.sql > /etc/mysql/init.sql

echo "[+] Archivo /etc/mysql/init.sql generado:"
cat /etc/mysql/init.sql