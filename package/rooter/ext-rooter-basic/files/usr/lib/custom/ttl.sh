#!/bin/sh 

log() {
	logger -t "TTL Hack" "$@"
}

sleep 5
ENB=$(uci get ttl.ttl.enabled)
FLG=0

exst=$(cat /etc/firewall.user | grep "#startTTL")
if [ ! -z "$exst" ]; then
	cp -f /etc/firewall.user /etc/firewall.user.bk
	sed /"#startTTL"/,/"#endTTL"/d /etc/firewall.user.bk > /etc/firewall.user
	rm -f /etc/firewall.user.bk
	FLG=1
fi
if [ $ENB -eq 1 ]; then
	VALUE=$(uci get ttl.ttl.value)
	if -z $VALUE ]; then
		VALUE=65
	fi
	echo "#startTTL" >> /etc/firewall.user
	echo "iptables -t mangle -I POSTROUTING -o wwan0 -j TTL --ttl-set $VALUE" >> /etc/firewall.user
	echo "iptables -t mangle -I PREROUTING -i wwan0 -j TTL --ttl-set $VALUE" >> /etc/firewall.user
	echo "#endTTL" >> /etc/firewall.user
	FLG=1
fi
if [ $FLG -eq 1 ]; then
	/etc/init.d/firewall restart
fi
