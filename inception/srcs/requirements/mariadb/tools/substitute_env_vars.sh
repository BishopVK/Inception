#!/bin/bash

# Load environment variables from .env file
export $(grep -v '^#' /etc/mysql/.env | xargs)

# # Substitute environment variables in init.sql and output to init.sql
envsubst < /etc/mysql/init.temp.sql > /etc/mysql/init.sql