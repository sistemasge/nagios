#!/bin/bash
# estimamos que 14 dias antes nos empiece a dar el aviso y 7 dias antes la alarma critica
DIAS_WARN=14
DIAS_CRITICAL=7
let UNIX_TIME_WARN="$DIAS_WARN*24*60*60"
let UNIX_TIME_CRITICAL="$DIAS_CRITICAL*24*60*60"
#echo "UNIX_TIME_WARN= $UNIX_TIME_WARN"
#echo "UNIX_TIME_CRITICAL= $UNIX_TIME_CRITICAL"
ZIMBRA_CERT_FENCE_DATE=`su -c "/opt/zimbra/bin/zmcertmgr viewdeployedcrt | grep 'notAfter' |  cut -d'=' -f2 | sort -u" zimbra`
ZIMBRA_CERT_FENCE_DATE_UNIX_TIME=`date -d "$ZIMBRA_CERT_FENCE_DATE" +%s`
#echo "ZIMBRA_CERT_FENCE_DATE_UNIX_TIME= $ZIMBRA_CERT_FENCE_DATE_UNIX_TIME"
TODAYS_DATE=`date +%s`
# prueba de warn TODAYS_DATE=1345284294
# prueba de critical TODAYS_DATE=1345457094
#echo "TODAYS_DATE= $TODAYS_DATE"
let TIME_TO_EXPIRE_ZIMBRA_CERT_UNIX_TIME="$ZIMBRA_CERT_FENCE_DATE_UNIX_TIME-$TODAYS_DATE"
#echo "TIME_TO_EXPIRE_ZIMBRA_CERT= $TIME_TO_EXPIRE_ZIMBRA_CERT_UNIX_TIME"
let "DAYS_TO_EXPIRE_ZIMBRA_CERT= $TIME_TO_EXPIRE_ZIMBRA_CERT_UNIX_TIME/86400"
#echo "DAYS_TO_EXPIRE_ZIMBRA_CERT= $DAYS_TO_EXPIRE_ZIMBRA_CERT"
if [ $DAYS_TO_EXPIRE_ZIMBRA_CERT -lt 0 ] ; then
        let "DAYS_EXCEDED_ZIMBRA_CERT_UNIX_TIME= -1*DAYS_TO_EXPIRE_ZIMBRA_CERT"
        echo "CRITICAL hace $DAYS_EXCEDED_ZIMBRA_CERT_UNIX_TIME dias que el certificado de Zimbra ha expirado"
        exit 2
fi
if [ $TIME_TO_EXPIRE_ZIMBRA_CERT_UNIX_TIME -lt $UNIX_TIME_WARN ]; then
        if [ $TIME_TO_EXPIRE_ZIMBRA_CERT_UNIX_TIME -lt $UNIX_TIME_CRITICAL ]; then
                echo "CRITICAL quedan $DAYS_TO_EXPIRE_ZIMBRA_CERT dias para que el certificado de zimbra expire"
                exit 2
        else
                echo "WARN quedan $DAYS_TO_EXPIRE_ZIMBRA_CERT dias para que el certificado de zimbra expire"
                exit 1
        fi
fi
echo "OK quedan $DAYS_TO_EXPIRE_ZIMBRA_CERT dias para que el certificado de zimbra expire"
exit 0
