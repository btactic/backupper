# BackUpper

Incremental backups with rsync and hard links.

## Configuración de los backups

Crear el fichero `backup.conf` en el directorio raíz y añadir la siguiente configuración:
```
#Directorios a contemplar
DIRS_TO_BACKUP=(
    /var/www/html
    /opt/zimbra/logs
)

# Configuración de la máquina de destino
DEST_HOST_HOSTNAME=172.16.0.101
DEST_HOST_PORT=22
DEST_HOST_USER=backupper
DEST_HOST_BACKUPS_DIR=/home/backupper/backups/

# Configuración correo electrónico notificaciones
MAIL_TO="backupper@example.com"

# Configuración para rotar los backups
BACKUPS_TO_KEEP=30

# Configuración backup bases de datos mysql
MYSQL_USER=user
MYSQL_PASSWORD=pass1234
MYSQL_DATABASES=(
    database1
    datanase2
)
```

Configurar la máquina de destino para que se puedan realizar conexiones ssh desde la máquina orígen sin contraseña con:
```
# ssh-copy-id -i ~/.ssh/id_rsa.pub -p 22 backupper@172.16.0.101
```
