#!/bin/bash
#$1: % Warning
#$2: % Error

if [ -z $1 ] ; then
        echo "No warning limit gived"
        exit -1
fi
if [ -z $2 ] ; then
        echo "No critical limit gived"
        exit -2
fi

if [ $1 -gt $2 ]; then
	echo "Critical must be greater than warning"
	exit -3
fi


FREEOUTPUT=`free -m|grep Mem`
TOTAL=`echo -n $FREEOUTPUT|cut -d ' ' -f 2`
USED=`echo -n $FREEOUTPUT|cut -d ' ' -f 3`
BUFFERS=`echo -n $FREEOUTPUT|cut -d ' ' -f 6`
CACHED=`echo -n $FREEOUTPUT|cut -d ' ' -f 7`

WARN_MB=$(($TOTAL*${1}/100))
CRIT_MB=$(($TOTAL*${2}/100))

#memoria utilitzada ha de ser: mem used-cached-buffer

echo -n "Memoria Total: $TOTAL MB Utilitzada total: $USED MB Buffers: $BUFFERS MB Cached: $CACHED MB - Umbral Warn: $WARN_MB Umbral Crit: $CRIT_MB "

USED=$(($USED-$BUFFERS-$CACHED))
USED_PERCENT=$(($USED*100/$TOTAL))

echo -n "Utilitzada real: $USED MB (${USED_PERCENT}%)"

if [ $USED -gt $CRIT_MB ]; then
	echo " Critical"
	VALOR_RETORN=2
elif [ $USED -gt $WARN_MB ]; then
	echo " Warning"
	VALOR_RETORN=1
else echo " OK"
	VALOR_RETORN=0
fi

exit $VALOR_RETORN


