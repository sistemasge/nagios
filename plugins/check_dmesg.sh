#!/bin/bash
DM_TMP="/tmp/dmesg_avisos_temporal.lst"
DM_INICIO="/tmp/dmesg_avisos_iniciales.lst"
DM_NUEVOS="/tmp/dmesg_avisos_nuevos.lst"
DM_EXCLUIR="/etc/scripts/dm_excluir.lst"
RES=0

dmesg -T &> /dev/null
if [ "$?" == "1" ]; then ARG=""; else ARG="-T "; fi #Si dmesg no acepta parametro -T entonces no lo usamos

if [ ! -f "${DM_INICIO}" ];  then dmesg ${ARG} &> "${DM_INICIO}"; fi
if [ ! -f "${DM_NUEVOS}" ];  then touch "${DM_NUEVOS}";  fi
if [ ! -f "${DM_EXCLUIR}" ]; then touch "${DM_EXCLUIR}"; fi

dmesg ${ARG} &> "${DM_TMP}"
grep -wFv -f "${DM_INICIO}" "${DM_TMP}" | grep -wFv -f "${DM_EXCLUIR}" | tee "${DM_NUEVOS}" #Buscamos lo que se ha anyadido nuevo desde que arrancó el servidor, quitando las excepciones

if [ "$(wc -l < "${DM_NUEVOS}")" -gt "0" ]; then
  RES=2
else
  echo "OK"
fi

exit ${RES}

