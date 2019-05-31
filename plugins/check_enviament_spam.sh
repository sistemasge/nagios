#!/bin/bash
#TRUSTED_RECIPIENTS=""
TRUSTED_RECIPIENTS="" #direcciones separadas por espacios


#si donem com a bo un remitent buit
NULL_TRUSTED_RECIPIENT=1

if [ $# != 2 ]; then
        echo "$0 [WARN_INTERVAL] [CRIT_INTERVAL]"
        exit 1
else
        if [ "$1" -gt "$2" ]; then
                echo "El intervalo Warn $1 debe ser inferior al intervalo Critical $2"; exit 1
        fi
fi

POSTFIXFILE=/var/log/zimbra.log
SASLAUTHFILE=/var/log/zimbra.log

check_trusted()
{
        #comprovar si el remitent es fiable
        for trust in $TRUSTED_RECIPIENTS; do
                if [ "$trust" == "$1" ]; then
                        return 1
                fi
        done

        if [ $NULL_TRUSTED_RECIPIENT == 1 ] && [ "$1" == "" ]; then
                return 1
        fi

        return 0
}

set_return_value()
{
        #si ja estem en estat critical, no fem res
        if [ $VALOR_RETORN == 2 ]; then
                return
        fi
        VALOR_RETORN=$1
}

WARN_INTERVAL=$1
CRIT_INTERVAL=$2
VALOR_RETORN=0

#Numero de correus que ha enviat un mateix usuari en un interval de temps (per si algu ha descobert el password i/o es un open relay)
echo -n "SMTP send mails: "

TEMPFILE=`mktemp`
#cat $POSTFIXFILE|grep postfix|grep "from="| grep -v "redmine-sistemas@xunta.gal" |sed 's/.*from=<//'|cut -d '>' -f1|sort|uniq -c > $TEMPFILE
#grep -F postfix $POSTFIXFILE|grep "from="| grep -v "redmine-sistemas@xunta.gal" |sed 's/.*from=<//'|cut -d '>' -f1|sort|uniq -c > $TEMPFILE
#grep -F postfix $POSTFIXFILE|grep "from="| grep -v "redmine-sistemas@xunta.gal" |sed 's/.*from=<//'|cut -d '>' -f1|sort|uniq -c|sort -nr > $TEMPFILE
grep -F postfix $POSTFIXFILE|grep "from="|tail -n 5000|grep -v "redmine-sistemas@xunta.gal" |sed 's/.*from=<//'|cut -d '>' -f1|sort|uniq -c|sort -nr > $TEMPFILE

  LINE=""
  VEGADES=99999999

  while [ "$VEGADES" -gt "$WARN_INTERVAL" ]
  do
    read LINE || break

        VEGADES=`echo -n $LINE|awk '{printf "%s\n",$1}'`
        USUARI=`echo -n $LINE|awk '{printf "%s\n",$2}'`

        check_trusted "$USUARI"
        if [ $? == 0 ]; then

                if [ $VEGADES -gt $CRIT_INTERVAL ]; then
                        set_return_value 2
                        echo -n "$USUARI $VEGADES. "
                elif [ $VEGADES -gt $WARN_INTERVAL ]; then
                        set_return_value 1
                        echo -n "$USUARI $VEGADES. "
                fi

        fi
  done < $TEMPFILE

echo $LINE

echo -n " - "

#Numero de vegades que un usuari s'autentifica amb smtp auth en un interval (per si algu ha descobert el password)
#Per zimbra:

#zimbra.log
#Oct 21 17:48:38 zimbra saslauthd[12374]: auth_zimbra: chernandez auth OK
echo -n "SMTP Auth operations: "

#cat $SASLAUTHFILE|grep saslauthd|grep "auth OK"|sed 's/.*auth_zimbra: //'|cut -d ' ' -f1|sort|uniq -c > $TEMPFILE
#grep -F saslauthd $SASLAUTHFILE|grep "auth OK"|sed 's/.*auth_zimbra: //'|cut -d ' ' -f1|sort|uniq -c > $TEMPFILE
#grep -F saslauthd $SASLAUTHFILE|grep "auth OK"|sed 's/.*auth_zimbra: //'|cut -d ' ' -f1|sort|uniq -c|sort -nr > $TEMPFILE
grep -F saslauthd $SASLAUTHFILE|grep "auth OK"|tail -n 5000|sed 's/.*auth_zimbra: //'|cut -d ' ' -f1|sort|uniq -c|sort -nr > $TEMPFILE

  LINE=""
  VEGADES=99999999

  while [ "$VEGADES" -gt "$WARN_INTERVAL" ]
  do
    read LINE || break

        VEGADES=`echo -n $LINE|awk '{printf "%s\n",$1}'`
        USUARI=`echo -n $LINE|awk '{printf "%s\n",$2}'`

        check_trusted "$USUARI"
        if [ $? == 0 ]; then


                if [ $VEGADES -gt $CRIT_INTERVAL ]; then
                        set_return_value 2
                        echo -n "$USUARI $VEGADES. "
                elif [ $VEGADES -gt $WARN_INTERVAL ]; then
                        set_return_value 1
                        echo -n "$USUARI $VEGADES. "
                fi

        fi

  done < $TEMPFILE


echo -n " - "

if [ $VALOR_RETORN == 0 ]; then
        echo "OK"
elif [ $VALOR_RETORN == 2 ]; then
        echo "CRITICAL"
else
        echo "WARNING"
fi

rm -f $TEMPFILE

exit $VALOR_RETORN

