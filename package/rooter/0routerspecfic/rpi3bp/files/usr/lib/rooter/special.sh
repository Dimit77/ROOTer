#!/bin/sh

LED=0
SM=$(uci get system.led_lan)
if [ -z $SM ]; then
	uci set system.led_lan=led
	uci set system.led_lan.default="0"  
	uci set system.led_lan.name="lan"
	uci set system.led_lan.sysfs="led0"
	uci set system.led_lan.trigger="netdev"
	uci set system.led_lan.dev="br-lan"
	uci set system.led_lan.mode="link tx rx"
	LED=1
fi
SM=$(uci get system.led_wifi)
if [ -z $SM ]; then
	uci set system.led_wifi=led
	uci set system.led_wifi.default="0"  
	uci set system.led_wifi.name="wifi"
	uci set system.led_wifi.sysfs="led1"
	uci set system.led_wifi.trigger="netdev"
	uci set system.led_wifi.dev="wlan0"
	uci set system.led_wifi.mode="link tx rx"
	LED=1
fi

if [ $LED -eq 1 ]; then
	uci commit system
	/etc/init.d/led restart
fi
