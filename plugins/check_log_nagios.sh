#!/bin/bash
set -u #Fin de script si llama a variable que no existe
set -o errexit #o set -e. Cada comando retorna true si se ejecuta bien para hacer command || { echo "command failed"; exit 1; }. Finaliza script al primer error
#set -o verbose #o set -v. Muestra cada comando que se ejecuta
#set -i #Interactivo

FLOG="/var/log/nagios/"
LOG="${FLOG}alertas-nagios.log"
RES=0
MSG="OK - no hay entradas en ${LOG}"

if [ ! -d "${FLOG}" ]; then
  if [ "$(whoami)" == "root" ]; then mkdir -vp "${FLOG}"
  else echo "Error, no existe la carpeta ${FLOG}"; exit 1; fi
fi

if [ ! -f "${LOG}" ]; then
  if [ "$(whoami)" == "root" ]; then touch "${LOG}"; chown nagios:nagios "${LOG}"
  else touch "${LOG}"; fi
fi

if [ $(wc -l < "${LOG}") -gt 0 ]; then
  MSG=$(cat "${LOG}"); RES=1
fi

echo "${MSG}"

if [ "$#" == "0" ]; then
  echo "Para eliminar esta alerta, comprobar el problema indicado y luego llamar al script $(basename 0) con el parametro 'del' "
else
  echo "Eliminando las alertas: ${MSG}"
  > "${LOG}"
  chown nagios:nagios "${LOG}"
fi

exit ${RES}
