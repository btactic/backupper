#!/bin/bash

CONFIG_DIR="/usr/local/etc/backupper"
BINARY_DIR="/usr/local/bin"
BINARY_FILE="backupper.sh"
GLOBAL_CONFIG_FILE="global.conf"
CUSTOM_CONFIG_SAMPLE_FILE="custom.conf.sample"

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

echo -e -n "Installation compled!\n"