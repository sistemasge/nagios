#!/bin/bash


SEVERITIES="err,alert,emerg,crit"
WHITELIST="microcode: |\
Firmware Bug|\
i8042: No controller|\
Odd, counter constraints enabled but no core perfctrs detected|\
Failed to access perfctr msr|\
echo 0 > /proc/sys"


# Check for critical dmesg lines from this day
date=$(date "+%a %b %e")
output=$(dmesg -T -l "$SEVERITIES" | egrep -v "$WHITELIST" | grep "$date" | tail -5)


if [ "$output" == "" ]; then
  echo "All is fine."
  exit 0
else
  echo "Para eliminar estos errores, ejecutar dmesg -c en el servidor "
fi


echo "$output" | xargs
exit 1
