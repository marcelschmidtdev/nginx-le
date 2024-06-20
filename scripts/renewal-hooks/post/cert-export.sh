#!/bin/bash

if [[ -z $CERT_EXPORT ]] || [ ! -d "/le_export" ]; then
  exit 0
fi

if [ "$(ls /le_export)" ]; then
  rm -r /le_export/*
fi

IFS=',' read -r -a array <<< "$CERT_EXPORT"

for element in "${array[@]}"
do
  cp -RL /etc/letsencrypt/live/$element /le_export
done
