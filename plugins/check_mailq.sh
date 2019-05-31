#!/bin/bash
# En lugar de llamar a mailq, contamos los correos que hay en las colas postfix, que es mas rapido
#$1: Warning
#$2: Error

if [ -z $1 ] ; then
        echo "Error: es requereixen 2 parametres numeris warning i critical"
        exit 2
fi
if [ -z $2 ] ; then
        echo "Error: es requereixen 2 parametres numeris warning i critical"
        exit 3
fi
if [ "$(whoami)" != "root" ]; then echo "Este script se debe ejecutar como root"; exit 1; fi

TEMP=$(mktemp)

#MAILQ=`mailq|grep Requests|cut -d ' ' -f5`
RUTA1="/opt/zimbra/data/postfix/spool/active/"
RUTA2="/opt/zimbra/data/postfix/spool/deferred/"
ls "$RUTA1" > /dev/null 2> "$TEMP"
#ssh zimbra@localhost " ls \"$RUTA1\" > /dev/null 2> \"$TEMP\"; chmod 666 \"$TEMP\" "
ERR1=$?
ls "$RUTA2" > /dev/null 2>> "$TEMP"
#ssh zimbra@localhost " ls \"$RUTA2\" > /dev/null 2>>\"$TEMP\"; chmod 666 \"$TEMP\" "
ERR2=$?
#echo "Errores: $ERR1 $ERR2"
if [ "$ERR1" == "0" ] || [ "$ERR2" == "0" ]; then
  MAILQ=$(find "$RUTA1" "$RUTA2" | wc -l) #Agafem el compte dels correus
  if [ -z $MAILQ ]; then
    MAILQ=0
  fi
  echo -n "Mails en cua : $MAILQ ."
else
  echo -n "ERROR: $(cat $TEMP)"
  MAILQ=$1 #Forzamos que sea un warning con el mensaje de error
  rm -f "$TEMP"
fi



if [ "$MAILQ" -ge "$2" ]; then
  echo " Critical"
  VALOR_RETORN=2
elif [ "$MAILQ" -ge "$1" ]; then
  echo " Warning"
  VALOR_RETORN=1
else echo " OK"
  VALOR_RETORN=0
fi

exit $VALOR_RETORN
