#!/bin/sh

ROOTER=/usr/lib/rooter

log() {
	logger -t "Lock Provider" "$@"
}

setautocops() {
	if [ "$MODTYPE" = "6" ]; then
		NETMODE=$(uci get modem.modem$CURRMODEM.netmode)
		case $NETMODE in
			"3")
				ATCMDD="AT+COPS=0,,,0" ;;
			"5")
				ATCMDD="AT+COPS=0,,,2" ;;
			"7")
				ATCMDD="AT+COPS=0,,,7" ;;
			*)
				ATCMDD="AT+COPS=0" ;;
		esac
	else
		ATCMDD="AT+COPS=0"
	fi
	OX=$($ROOTER/gcom/gcom-locked "$CPORT" "run-at.gcom" "$CURRMODEM" "$ATCMDD")
	CLOG=$(uci get modem.modeminfo$CURRMODEM.log)
	if [ $CLOG = "1" ]; then
		log "$OX"
	fi
	exit 0
}

CURRMODEM=$1
CPORT=/dev/ttyUSB$(uci get modem.modem$CURRMODEM.commport)
MODTYPE=$(uci get modem.modem$CURRMODEM.modemtype)
LOCK=$(uci get modem.modeminfo$CURRMODEM.lock)

if [ -z $LOCK ]; then
	setautocops
fi

MCC=$(uci get modem.modeminfo$CURRMODEM.mcc)
LMCC=${#MCC}
if [ $LMCC -ne 3 ]; then
	setautocops
fi
MNC=$(uci get modem.modeminfo$CURRMODEM.mnc)
if [ -z $MNC ]; then
	setautocops
fi
LMNC=${#MNC}
if [ $LMNC -eq 1 ]; then
	MNC=0$MNC
fi

if [ "$MODTYPE" = "6" ]; then
	NETMODE=$(uci get modem.modem$CURRMODEM.netmode)
	case $NETMODE in
		"3")
			ATCMDD="AT+COPS=1,2,\"$MCC$MNC\",0" ;;
		"5")
			ATCMDD="AT+COPS=1,2,\"$MCC$MNC\",2" ;;
		"7")
			ATCMDD="AT+COPS=1,2,\"$MCC$MNC\",7" ;;
		*)
			ATCMDD="AT+COPS=1,2,\"$MCC$MNC\"" ;;
	esac
else
	ATCMDD="AT+COPS=1,2,\"$MCC$MNC\""
fi
OX=$($ROOTER/gcom/gcom-locked "$CPORT" "run-at.gcom" "$CURRMODEM" "$ATCMDD")
CLOG=$(uci get modem.modeminfo$CURRMODEM.log)
if [ $CLOG = "1" ]; then
	log "Error While Locking to Provider"
	log "$OX"
else
	log "Locked to Provider $MCC $MNC"
fi
