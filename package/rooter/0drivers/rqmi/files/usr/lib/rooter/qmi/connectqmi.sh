#!/bin/sh

ROOTER=/usr/lib/rooter

log() {
	logger -t "QMI Connect" "$@"
}

	. /lib/functions.sh
	. /lib/netifd/netifd-proto.sh

CURRMODEM=$1
device=/dev/$2
auth=$3
NAPN=$4
username=$5
password=$6
pincode=$7

interface="wan"$CURRMODEM

case $auth in
	"0" )
		auth="none"
	;;
	"1" )
		auth="pap"
	;;
	"2" )
		auth="chap"
	;;
	*)
		auth="none"
	;;
esac
if [ $username = NIL ]; then
	username=
fi
if [ $password = NIL ]; then
	password=
fi

devname="$(basename "$device")"
devpath="$(readlink -f /sys/class/usbmisc/$devname/device/)"
ifname="$( ls "$devpath"/net )"

while uqmi -s -d "$device" --get-pin-status | grep '"UIM uninitialized"' > /dev/null; do
		sleep 1;
done

[ -n "$pincode" ] && {
	uqmi -s -d "$device" --verify-pin1 "$pincode" || {
		log "Unable to verify PIN"
		exit 1
	}
}

uqmi -s -d "$device" --stop-network 0xffffffff --autoconnect > /dev/null & sleep 10 ; kill -9 $!

uqmi -s -d "$device" --set-data-format 802.3
uqmi -s -d "$device" --wda-set-data-format 802.3
DATAFORM=$(uqmi -s -d "$device" --wda-get-data-format)
log "WDA-GET-DATA-FORMAT is $DATAFORM"
if [ "$DATAFORM" = '"raw-ip"' ]; then
	[ -f /sys/class/net/$ifname/qmi/raw_ip ] || {
		log "Device only supports raw-ip mode but is missing this required driver attribute: /sys/class/net/$ifname/qmi/raw_ip"
		exit 1
	}
	echo "Y" > /sys/class/net/$ifname/qmi/raw_ip
fi

uqmi -d $device --fcc-auth
sleep 1

log "Waiting for network registration"
while uqmi -s -d "$device" --get-serving-system | grep '"searching"' > /dev/null; do
	sleep 5;
done

log "Starting network $NAPN"
cid=`uqmi -s -d "$device" --get-client-id wds`
[ $? -ne 0 ] && {
	log "Unable to obtain client ID"
	exit 1
}

uqmi -s -d "$device" --set-client-id wds,"$cid" --set-ip-family ipv4 > /dev/null

ST=$(uqmi -s -d "$device" --set-client-id wds,"$cid" --start-network ${NAPN:+--apn $NAPN} ${auth:+--auth-type $auth} \
	${username:+--username $username} ${password:+--password $password} --autoconnect)
log "Connection returned : $ST"

CONN=$(uqmi -s -d "$device" --get-data-status)
log "status is $CONN"

CONNZX=$(uqmi -s -d $device --set-client-id wds,$cid --get-current-settings)
log "GET-CURRENT-SETTINGS is $CONNZX"

T=$(echo $CONN | grep "disconnected")
if [ -z $T ]; then
	echo "1" > /tmp/qmigood
	
	cid6=`uqmi -s -d "$device" --get-client-id wds`
	[ $? -ne 0 ] && {
		log "Unable to obtain client ID"
		exit 1
	}
	uqmi -s -d "$device" --set-client-id wds,"$cid6" --set-ip-family ipv6 > /dev/null
	ST6=$(uqmi -s -d "$device" --set-client-id wds,"$cid6" --start-network ${NAPN:+--apn $NAPN} ${auth:+--auth-type $auth} \
	${username:+--username $username} ${password:+--password $password} --autoconnect)
	log "IPv6 Connection returned : $ST6"
	CONN=$(uqmi -s -d "$device" --get-data-status)
	log "IPv6 status is $CONN"
	CONNZX=$(uqmi -s -d $device --set-client-id wds,$cid6 --get-current-settings)
	log "IPv6 GET-CURRENT-SETTINGS is $CONNZX"
	
	
	if [ $DATAFORM = "raw-ip" ]; then
		json_load "$(uqmi -s -d $device --set-client-id wds,$cid --get-current-settings)"
		json_select ipv4
		json_get_vars ip subnet gateway dns1 dns2
		
		json_load "$(uqmi -s -d $device --set-client-id wds,$cid6 --get-current-settings)"
		json_select ipv6
		json_get_var ip_6 ip
		json_get_var gateway_6 gateway
		json_get_var dns1_6 dns1
		json_get_var dns2_6 dns2
		json_get_var ip_prefix_length ip-prefix-length
		
		proto_init_update "$ifname" 1
		proto_set_keep 1
		proto_add_ipv4_address "$ip" "$subnet"
		proto_add_dns_server "$dns1"
		proto_add_dns_server "$dns2"
		proto_add_ipv4_route "0.0.0.0" 0 "$gateway"
		
		proto_add_ipv6_address "$ip_6" "128"
		proto_add_ipv6_prefix "${ip_6}/${ip_prefix_length}"
		proto_add_ipv6_route "$gateway_6" "128"
		proto_add_ipv6_route "::0" 0 "$gateway_6" "" "" "${ip_6}/${ip_prefix_length}"
		proto_add_dns_server "$dns1_6"
		proto_add_dns_server "$dns2_6"
			
		proto_add_data
		json_add_string "cid_4" "$cid"
		json_add_string "pdh_4" "$ST"
		json_add_string "cid_6" "$cid6"
		json_add_string "pdh_6" "$ST6"
		proto_close_data
		proto_send_update "$interface"
	fi
else
	uqmi -s -d "$device" --stop-network 0xffffffff --autoconnect > /dev/null & sleep 10 ; kill -9 $!
fi

