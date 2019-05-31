#!/bin/sh
# Version 0.2
#
#	### History ###
# V0.1 Created script from CPU Idle script V0.2 Handle dicimal compare and output
if [ "$1" = "-w" ] && [ "$2" -gt "0" ] && [ "$3" = "-c" ] && [ "$4" -gt "0" ] ; then
	warn=$2
	crit=$4
	IDLE=`top -b -n2|grep Cpu|tail -1|cut -d',' -f4|cut -d% -f1`
	USAGE=`echo "100 - $IDLE"|bc|sed -r 's/^\./0./g'` ||exit 3
#	echo "DEBUG: head: ${USAGE%%.*} tail: ${USAGE##*.} " echo "DEBUG: ||$USAGE_RAW|| , ||$USAGE||"
        if [ $warn -lt ${USAGE%%.*} ]; then
                if [ $crit -lt ${USAGE%%.*} ]; then
                echo "CRITICAL - CPU Usage = $USAGE %|CPU Usage=$USAGE%;;;;"
                exit 2
        else
                echo "WARNING - CPU Usage = $USAGE %|CPU Usage=$USAGE%;;;;"
                exit 1
        fi
	else
                echo "OK - CPU Usage = $USAGE %|CPU Usage=$USAGE%;;;;"
        	exit 0
	fi
	else
        echo "$0 - Nagios Plugin for checking CPU Usage in percentage "
        echo ""
        echo "Usage:	$0 -w <warnlevel> -c <critlevel>"
        echo "	= warnlevel and critlevel is warning and critical value for alerts. "
        echo ""
        echo "EXAMPLE: /usr/lib64/nagios/plugins/$0 -w 80 -c 90 "
	echo "	= This will send warning alert when CPU Usage percentage is higher than 80%, and send critical when higher than 90%"
        echo ""
        exit 3
fi
