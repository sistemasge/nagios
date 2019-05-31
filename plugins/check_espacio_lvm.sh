#!/bin/bash
PORCENTAJE=" [6-9][0-9]\.[0-9][0-9] |100\.00" #60% o mas haria saltar alarma
PORCENTAJE=" [9][0-9]\.[0-9][0-9] |100\.00"   #90% o mas haria saltar alarma
PORCENTAJE=" [4-9][0-9]\.[0-9][0-9] |100\.00" #40% o mas haria saltar alarma
PORCENTAJE=" [8-9][0-9]\.[0-9][0-9] |100\.00" #80% o mas haria saltar alarma

HEADER="$(sudo -u root /sbin/lvs -a | head -n 1 | awk '{print $1" "$7" "$8}')"
#STATUS="$(sudo -u root /sbin/lvs -a | sed "s/g data//g" | awk '{print $1" "$5" "$6}' | egrep -v "Pool Origin|^[ ]*$" | grep " [4-9][0-9]\.[0-9][0-9] ")"
STATUS="$(sudo -u root /sbin/lvs -a | grep "data[ ]*pve" | sed "s/g data//g" | awk '{print $1" "$5" "$6}' | egrep -v "Pool Origin|^[ ]*$" | egrep "$PORCENTAJE")"
NUM="$(echo "$STATUS" | grep -v "^$" | wc -l)"

#echo "$HEADER"
#echo "$STATUS"
#echo "$NUM"

if [ "$NUM" == "0" ]; then
  RES=0
  STATUS="$(sudo -u root /sbin/lvs -a | grep "data[ ]*pve" | sed "s/g data//g" | awk '{print $1" "$5" "$6}' | egrep -v "Pool Origin|^[ ]*$")"
  MSG="OK - $STATUS \\n $HEADER \\n $STATUS"
else
  RES=1
  MSG="CRITICAL - $STATUS \\n $HEADER \\n $STATUS"
fi

echo -e "$MSG"
exit $RES
