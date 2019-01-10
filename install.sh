#!/bin/bash

#######################################################################
# backupper: Incremental backups with rsync and hard links.

# Copyright (C) 2017,2018,2019 BTACTIC, SCCL
# Copyright (C) 2019 Adrián Gibanel López
# Copyright (C) 2017,2018 Marc Sanchez Fauste
# Copyright (C) 2017,2018 Adria Sanchez Mas

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#######################################################################

CONFIG_DIR="/usr/local/etc/backupper"
BINARY_DIR="/usr/local/bin"
BINARY_FILE="backupper.sh"
GLOBAL_CONFIG_FILE="global.conf"
CUSTOM_CONFIG_SAMPLE_FILE="custom.conf.sample"
DEPENDENCES_PACKAGES="sendemail libnet-ssleay-perl libio-socket-ssl-perl rsync"
HAS_UPDATED_PACKAGES=false

function check_dependences() {
    echo -e "Checking dependences..."
    for dependence in $DEPENDENCES_PACKAGES; do
        check_dependence $dependence
    done
}

check_dependence() {
    if dpkg -s $1 > /dev/null 2>&1; then
        echo -e "[OK] $1 is installed!"
    else
        echo -e "[FAIL] $1 is not installed!"
        while true; do
            echo -e -n "Do you want to install $1? [y/n] "
            read choise
            if [ "$choise" == "n" ] || [ "$choise" == "N" ]; then
                return
            fi
            if [ "$choise" == "y" ] || [ "$choise" == "Y" ]; then
                install_package $1
                return
            fi
            echo -e "[ERROR] Invalid option!"
        done
    fi
}

function update_packages_list() {
    apt-get update
    HAS_UPDATED_PACKAGES=true
}

function install_package() {
    if [ $HAS_UPDATED_PACKAGES == false ]; then
        update_packages_list
    fi
    apt-get install $1
}

## MAIN BEGIN ##

echo -e -n "#################################\n"
echo -e -n "#       bTactic BackUpper       #\n"
echo -e -n "#################################\n\n"

if [ ! -d $CONFIG_DIR ]; then
    echo -e -n "Creating config dir '$CONFIG_DIR'...\n"
    mkdir --parents $CONFIG_DIR
fi
if [ ! -d $BINARY_DIR ]; then
    echo -e -n "Creating binary dir '$BINARY_DIR'...\n"
    mkdir --parents $BINARY_DIR
fi

if [ -f $BINARY_DIR/$BINARY_FILE ]; then
    echo -e -n "Binary file '$BINARY_DIR/$BINARY_FILE' already exists. Overwriting...\n"
    cp -f $BINARY_FILE $BINARY_DIR/$BINARY_FILE
else
    echo -e -n "Installing binary file '$BINARY_DIR/$BINARY_FILE'...\n"
    cp $BINARY_FILE $BINARY_DIR/$BINARY_FILE
fi
echo -e -n "Giving +x permissions to '$BINARY_FILE $BINARY_DIR/$BINARY_FILE'...\n"
chmod +x $BINARY_FILE $BINARY_DIR/$BINARY_FILE

if [ -f $CONFIG_DIR/$GLOBAL_CONFIG_FILE ]; then
    echo -e -n "Config file '$CONFIG_DIR/$GLOBAL_CONFIG_FILE' already exists. Overwriting...\n"
    cp -f $GLOBAL_CONFIG_FILE $CONFIG_DIR/$GLOBAL_CONFIG_FILE
else
    echo -e -n "Installing config file '$CONFIG_DIR/$GLOBAL_CONFIG_FILE'...\n"
    cp $GLOBAL_CONFIG_FILE $CONFIG_DIR/$GLOBAL_CONFIG_FILE
fi

if [ -f $CONFIG_DIR/$CUSTOM_CONFIG_SAMPLE_FILE ]; then
    echo -e -n "Config file '$CONFIG_DIR/$CUSTOM_CONFIG_SAMPLE_FILE' already exists. Overwriting...\n"
    cp -f $CUSTOM_CONFIG_SAMPLE_FILE $CONFIG_DIR/$CUSTOM_CONFIG_SAMPLE_FILE
else
    echo -e -n "Installing config file '$CONFIG_DIR/$CUSTOM_CONFIG_SAMPLE_FILE'...\n"
    cp $CUSTOM_CONFIG_SAMPLE_FILE $CONFIG_DIR/$CUSTOM_CONFIG_SAMPLE_FILE
fi

check_dependences

echo -e -n "Installation completed!\n"

## MAIN END ##
