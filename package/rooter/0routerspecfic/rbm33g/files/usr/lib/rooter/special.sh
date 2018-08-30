#!/bin/sh 
. /lib/functions.sh

VL=0
do_vlan() {
	local config=$1
	config_get ports $1 ports
	if [ "$ports" = "1 2 3 4 6t" ]; then
		uci set network."$config".ports="0 1 3 4 6t"
		VL=1
	fi
	if [ "$ports" = "0 6t" ]; then
		uci set network."$config".ports="2 6t"
		VL=1
	fi
}


config_load network
config_foreach do_vlan switch_vlan

if [ $VL -eq 1 ]; then
	uci commit network
	/etc/init.d/network restart
fi
