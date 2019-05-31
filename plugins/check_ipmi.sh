#!/bin/bash
BASELINE_OK="/etc/scripts/_check_ipmi_baseline_ok.lst"
TMP=$(mktemp)

command ipmimonitoring &> /dev/null
if [ "$?" == "0" ]; then
  ipmimonitoring --comma-separated-output --non-abbreviated-units --no-header-output | grep -v ",Nominal," > "${TMP}"
  if [ ! -f ${BASELINE_OK} ]; then #Creamos fichero base para la monitorizacion
    cp -fv "${TMP}" "${BASELINE_OK}"
  fi
  if [ ! -f ${BASELINE_OK} ]; then #Si el fichero ahora no existe, mostramos error
    MSG="ERROR - fichero base no creado. Ejecutar el script como root en el equipo. Cosas extranyas detectadas: $(cat "${TMP}")"
    RES=2
  else
    DIFERENCIAS="$(grep -vxf "${BASELINE_OK}" "${TMP}")"
    if [ "$DIFERENCIAS" == "" ]; then
      MSG="OK - IPMI OK. Excepciones: $(cat ${BASELINE_OK})"
      RES=0
    else
      MSG="ERROR - Errores encontrados en IPMI: $DIFERENCIAS.\n EXCEPCIONES: $(cat ${BASELINE_OK})"
      RES=2
    fi
  fi
else
  MSG="ERROR - Comando 'ipmimonitoring' no instalado. Instalarlo para usar este script"
  RES=2
fi

rm -f "${TMP}"

echo "${MSG}"
exit $RES
