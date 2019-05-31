#!/bin/bash

var=$(iptables -L -nv -t nat | grep -c MASQUERADE)

  if [ $var != "0" ]; then
        echo "OK - El sistema esta funcionando"
        exit 0

        else
        echo "Error, el servicio esta detenido, lo ponemos en marcha"
#        iptables -t nat -A POSTROUTING -o  eth0 -j MASQUERADE
        exit 3

        fi

