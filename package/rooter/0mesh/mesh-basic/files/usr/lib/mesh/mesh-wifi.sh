#!/bin/sh /etc/rc.common

. /lib/functions.sh

log() {
	logger -t "MESH-WIFI" "$@"
}

RADIO="radio0"

do_radio() {
	local config=$1
	local channel

	config_get channel $1 channel
	if [ $channel -lt 15 ]; then
		RADIO=$config
	fi
}

check_mesh() {
	while [ ! -e /etc/config/wireless ]
	do
		sleep 1
	done
	sleep 3
	WI=0
	config_load wireless
	config_foreach do_radio wifi-device

	WW=$(uci get wireless.default_radio_adhoc)
	if [ -z $WW ]; then
		uci set wireless.default_radio_adhoc=wifi-iface
		uci set wireless.default_radio_adhoc.device=$RADIO
		uci set wireless.default_radio_adhoc.network="radio0_batnet"
		uci set wireless.default_radio_adhoc.ifname="radio0_mesh"
		uci set wireless.default_radio_adhoc.mode="adhoc"
		uci set wireless.default_radio_adhoc.ssid="ROOter.mesh"
		uci set wireless.default_radio_adhoc.bssid="CA:FE:00:CO:FF:EE"
		uci set wireless.default_radio_adhoc.disabled="0"
# without encryption
		uci set wireless.default_radio_adhoc.encryption="none"
# for encrypted backhaul
# replace above with
#
#		uci set wireless.default_radio_adhoc.encryption="psk2"
#		uci set wireless.default_radio_adhoc.key="rooter2017"

		WI=1
	fi

	if [ $WI = 1 ]; then
		uci commit wireless
		wifi up
	fi
}
log "set up mesh wifi interface"
check_mesh
./usr/lib/mesh/mesh-ping &