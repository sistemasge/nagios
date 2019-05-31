#!/bin/bash
if [ "$#" -ne 2 ]; then echo "Debe indicar umbral de porcentaje de Warning y de Critical"; exit 1; fi
if [ "$1" -lt 10 ] || [ "$1" -gt 99 ]; then echo "Error: el porcentaje de Warning debe estar entre 10 y 99";  exit 1; fi
if [ "$2" -lt 10 ] || [ "$2" -gt 99 ]; then echo "Error: el porcentaje de Critical debe estar entre 10 y 99"; exit 1; fi
if [ "$1" -gt "$2" ]; then echo "Error: el porcentaje de Warning no puede ser superior al de Critical"; exit 1; fi
RES=0
WARN="$1"
CRIT="$2"
#echo "$1 $2"

PRIMERO=1
WARN_TOP=$(expr $CRIT - 1)
for i in `seq $WARN $WARN_TOP`; do
  if [ "$PRIMERO" == "1" ]; then EXPR_WARN="$i"; PRIMERO=0; else EXPR_WARN="$EXPR_WARN|$i"; fi
done
#echo $EXPR_WARN
MSG1="$(df -Pkhl   | egrep "($EXPR_WARN)%")" #espacio libre
MSGI1="$(df -Pkhil | egrep "($EXPR_WARN)%")" #inodos libres (opción -i)
if [ "$MSGI1" != "" ]; then MSG1="$MSG1 INODOS: $MSGI1"; fi
#echo $MSG
if [ "$MSG1" != "" ]; then RES=1; fi

PRIMERO=1
for i in `seq $CRIT 100`; do
  if [ "$PRIMERO" == "1" ]; then EXPR_CRIT="$i"; PRIMERO=0; else EXPR_CRIT="$EXPR_CRIT|$i"; fi
done
#echo $EXPR_CRIT
MSG2="$(df -Pkhl   | egrep "($EXPR_CRIT)%")" #espacio libre
MSGI2="$(df -Pkhil | egrep "($EXPR_CRIT)%")" #inodos libres (opción -i)
if [ "$MSGI2" != "" ]; then MSG2="$MSG2 INODOS: $MSGI2"; fi
#echo $MSG
if [ "$MSG2" != "" ]; then RES=2; fi

if [ "$RES" == "0" ]; then MSG="OK"; fi
if [ "$RES" == "1" ]; then MSG="WARN - $MSG1"; fi
if [ "$RES" == "2" ]; then MSG="CRITICAL - $MSG2 $MSG1"; fi

#df -kh | egrep "(36|37|38|39|[4-9][0-9]|100)%"
#echo "RES: $RES"
echo "$MSG"
exit $RES

