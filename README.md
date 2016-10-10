# BackUpper

Incremental backups with rsync and hard links.


## Instalación

1. Clonar el repositorio.
2. Ejecutar `install.sh`.



# Configuración

1. Configurar la máquina de destino para que se puedan realizar conexiones ssh desde la máquina orígen sin contraseña:
    - Si no exite el fichero `~/.ssh/id_rsa.pub` crearlo con `# ssh-keygen`.
    - `# ssh-copy-id -i ~/.ssh/id_rsa.pub -p 22 backupper@172.16.0.101`
    - Conectarse a la máquina de destino por ssh para verificar que se puede conectar correctamente.

2. Renombrar el fichero `/usr/local/etc/backupper/custom.conf.sample` por `/usr/local/etc/backupper/custom.conf`.

3. Editar el fichero `/usr/local/etc/backupper/custom.conf` con la configuración especifica del backup que queremos realizar.
