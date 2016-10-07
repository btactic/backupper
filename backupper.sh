#!/bin/bash

global_config_file="global.conf"

function load_config() {
    if [ -f $global_config_file ]; then
        echo -e "Loading global config..."
        source $global_config_file
    else
        echo -e "Error loading global config file '$global_config_file'."
        exit 1
    fi

    if [ -f $BACKUP_CONFIG_FILE ]; then
        echo -e "Loading backup config..."
        source $BACKUP_CONFIG_FILE
    else
        echo -e "Error loading backup config file '$BACKUP_CONFIG_FILE'."
        exit 1
    fi
}

function parse_config() {
    echo  -e "Parsing config..."
    dirs_to_backup_args=$(
        for dir in ${DIRS_TO_BACKUP}; do
            echo -e -n "${dir%/}/ "
        done
    )
    rsync_flags_args=$RSYNC_FLAGS
    mysqldump_flags_args=$MYSQLDUMP_FLAGS
    dest_backups_dir=${DEST_HOST_BACKUPS_DIR%/}
}

function save_last_backup_name() {
    echo -e -n "$backup_name" > $LAST_BACKUP_FILE
}

function create_backup_dir() {
    backup_name=$(date +$BACKUP_NAME_FORMAT)
    ssh -p $DEST_HOST_PORT $DEST_HOST_USER@$DEST_HOST_HOSTNAME \
        "mkdir --parents $dest_backups_dir/$backup_name"
    create_backup_dir_exit_value=$?
    if [ $create_backup_dir_exit_value -ne 0 ]; then
        echo -e "Error creating backup dir '$backup_name'."
    else
        echo -e "Backup dir '$backup_name' created successfully."
    fi
}

function send_backup() {
    echo -e "Sending backup '$backup_name' to '$DEST_HOST_HOSTNAME'."
    echo -e "-- Begin rsync --"
    rsync $rsync_flags_args -e "ssh -p $DEST_HOST_PORT" $dirs_to_backup_args \
        $DEST_HOST_USER@$DEST_HOST_HOSTNAME:$dest_backups_dir/$LAST_RSYNC_BACKUP_FOLDER/
    rsync_exit_value=$?
    echo -e "-- End rsync --"
    if [ $rsync_exit_value -eq 0 ]; then
        echo -e "Backup '$backup_name' sent successfully."
        ssh -p $DEST_HOST_PORT $DEST_HOST_USER@$DEST_HOST_HOSTNAME \
            "mkdir --parents $dest_backups_dir/$backup_name/files;\
                cp -al $dest_backups_dir/$LAST_RSYNC_BACKUP_FOLDER/* \
                $dest_backups_dir/$backup_name/files/"
    fi
}

function get_rsync_error() {
    if [ $rsync_exit_value -eq 0 ]; then
        echo "Success"
    elif [ $rsync_exit_value -eq 1 ]; then
        echo "Syntax or usage error"
    elif [ $rsync_exit_value -eq 2 ]; then
        echo "Protocol incompatibility"
    elif [ $rsync_exit_value -eq 3 ]; then
        echo "Errors selecting input/output files, dirs"
    elif [ $rsync_exit_value -eq 4 ]; then
        echo "Requested  action not supported: an attempt was made to \
            manipulate 64-bit files on a platform that cannot support them; \
            or an option was specified that supported by the client and not \
            by the server."
    elif [ $rsync_exit_value -eq 5 ]; then
        echo "Error starting client-server protocol"
    elif [ $rsync_exit_value -eq 6 ]; then
        echo "Daemon unable to append to log-file"
    elif [ $rsync_exit_value -eq 10 ]; then
        echo "Error in socket I/O"
    elif [ $rsync_exit_value -eq 11 ]; then
        echo "Error in file I/O"
    elif [ $rsync_exit_value -eq 12 ]; then
        echo "Error in rsync protocol data stream"
    elif [ $rsync_exit_value -eq 13 ]; then
        echo "Errors with program diagnostics"
    elif [ $rsync_exit_value -eq 14 ]; then
        echo "Error in IPC code"
    elif [ $rsync_exit_value -eq 20 ]; then
        echo "Received SIGUSR1 or SIGINT"
    elif [ $rsync_exit_value -eq 21 ]; then
        echo "Some error echoed by waitpid()"
    elif [ $rsync_exit_value -eq 22 ]; then
        echo "Error allocating core memory buffers"
    elif [ $rsync_exit_value -eq 23 ]; then
        echo "Partial transfer due to error"
    elif [ $rsync_exit_value -eq 24 ]; then
        echo "Partial transfer due to vanished source files"
    elif [ $rsync_exit_value -eq 25 ]; then
        echo "The --max-delete limit stopped deletions"
    elif [ $rsync_exit_value -eq 30 ]; then
        echo "Timeout in data send/receive"
    elif [ $rsync_exit_value -eq 35 ]; then
        echo "Timeout waiting for daemon connection"
    else
        echo "Returned exit value: $rsync_exit_value"
    fi
}

function remove_old_backups() {
    local backups
    backups=($(ssh -p $DEST_HOST_PORT $DEST_HOST_USER@$DEST_HOST_HOSTNAME \
        "ls -1t $dest_backups_dir/ --ignore='$LAST_RSYNC_BACKUP_FOLDER'"))
    if [ $? -ne 0 ]; then
        echo -e "Error retrieving list of backups from remote host!"
        echo -e "Old backups will not be deleted."
        return
    fi
    local backups_to_remove=(${backups[@]:$NUMBER_OF_BACKUPS_TO_KEEP})
    if [ ${#backups_to_remove[@]} -eq 0 ]; then
        echo -e "There are no old backups to remove."
        return
    fi
    local rm_args=$(
        for backup in ${backups_to_remove[@]}; do
            echo -e -n "$dest_backups_dir/$backup "
        done
    )
    echo -e "Removing ${#backups_to_remove[@]} old backups: ${backups_to_remove[@]}"
    ssh -p $DEST_HOST_PORT $DEST_HOST_USER@$DEST_HOST_HOSTNAME \
        "rm -rf $rm_args"
    if [ $? -ne 0 ]; then
        echo -e "Error removing old backups!"
    else
        echo -e "Old backups removed successfully."
    fi
}

function send_mail() {
    local subject="Backup '$backup_name' from '$(hostname -f)'"
    mail -s "$subject" $MAIL_TO < "${LOG_FILE}"
}

function backup_mysql_databases() {
    echo -e "Creating mysql dabatases directory..."
    ssh -p $DEST_HOST_PORT $DEST_HOST_USER@$DEST_HOST_HOSTNAME \
        "mkdir --parents $dest_backups_dir/$backup_name/mysql_databases"
    for database in ${MYSQL_DATABASES[@]}; do
        echo -e "Sending backup of '$database' database to '$DEST_HOST_HOSTNAME'."
        echo -e "-- Begin mysqldump --"
        mysqldump $mysqldump_flags_args -u $MYSQL_USER \
            --password=$MYSQL_PASSWORD $database | gzip -9 -c | \
            ssh -p $DEST_HOST_PORT $DEST_HOST_USER@$DEST_HOST_HOSTNAME \
            "cat > $dest_backups_dir/$backup_name/mysql_databases/$database.sql.gz"
        echo -e "-- End mysqldump --"
    done
}

function send_log_to_dest() {
    echo -e "Sending log to destination host..."
    cat $LOG_FILE | ssh -p $DEST_HOST_PORT $DEST_HOST_USER@$DEST_HOST_HOSTNAME \
        "cat > $dest_backups_dir/$backup_name/backupper.log"
    if [ $? -ne 0 ]; then
        echo -e "Error sending log to destination host!"
    else
        echo -e "Log sent successfully to destination host."
    fi
}

## MAIN BEGIN ##

load_config
parse_config

exec > $LOG_FILE 2>&1

create_backup_dir
if [ $create_backup_dir_exit_value -ne 0 ]; then
    send_mail
    exit 1
fi
if [ ${#DIRS_TO_BACKUP[@]} -eq 0 ]; then
    echo -e "There are no dirs to backup!"
else
    send_backup
    if [ $rsync_exit_value -ne 0 ]; then
        rsync_error_message=$(get_rsync_error)
        echo -e "Error executing rsync ($rsync_exit_value): $rsync_error_message"
    fi
fi
if [ ${#MYSQL_DATABASES[@]} -eq 0 ]; then
    echo -e "There are no mysql databases to backup."
else
    backup_mysql_databases
fi
if [ $rsync_exit_value -eq 0 ]; then
    remove_old_backups
else
    echo -e "Rsync failed! Old backups are not deleted!"
fi
send_mail
send_log_to_dest
save_last_backup_name

## MAIN END ##
