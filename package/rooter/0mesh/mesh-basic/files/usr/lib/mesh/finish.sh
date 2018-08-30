#!/bin/sh 
. /lib/functions.sh

log() {
	logger -t "MESH-SETUP" "$@"
}

log "Finsh off setting up Mesh system"

sleep 5
netchge=0
curr=$(uci get network.lan.ipaddr)
ip=$(uci get mesh.lanip.ip)

if [ $curr != $ip ]; then
	log "change IP to $ip"
	uci set network.lan.ipaddr=$ip
	netchge=1
fi

currh=$(uci get system.@system[-1].hostname)
newh=$(uci get mesh.lanip.host)

if [ $currh != $newh ]; then
	log "change Host to $newh"
	uci set system.@system[-1].hostname=$newh
	echo "$newh" > /proc/sys/kernel/hostname
	uci commit system
fi

wirechge=0
currbh=$(uci get wireless.default_radio_adhoc.device)
newbh=$(uci get mesh.backhaul.radio)

if [ $currbh != $newbh ]; then
	log "change backhaul radio to $newbh"
	uci set wireless.default_radio_adhoc.device=$newbh
	wirechge=1
fi

uci delete watchping.watchping
uci set watchping.watchping=watchping
uci set watchping.watchping.alive=$(uci get mesh.lanip.alive)
uci set watchping.watchping.pingtime=$(uci get mesh.lanip.pingtime)
uci set watchping.watchping.pingwait=$(uci get mesh.lanip.pingwait)
uci set watchping.watchping.reliability=$(uci get mesh.lanip.reliability)
uci set watchping.watchping.count=$(uci get mesh.lanip.count)
uci set watchping.watchping.packetsize=$(uci get mesh.lanip.packetsize)
uci set watchping.watchping.down=$(uci get mesh.lanip.down)
uci set watchping.watchping.up=$(uci get mesh.lanip.up)

track_ips=
list_track_ips() {
	track_ips="$1 $track_ips"
}
config_load mesh
config_list_foreach "lanip" "trackip" list_track_ips
for track_ip in $track_ips; do
	uci add_list watchping.watchping.trackip=$track_ip
done

M1=$(uci get watchping.speed.m1)
if [ -z $M1 ]; then
	uci set watchping.speed=speed
fi
uci set watchping.speed.m1=$(uci get mesh.lanip.m1speed)	
uci set watchping.speed.m2=$(uci get mesh.lanip.m2speed)
uci set watchping.speed.ww=$(uci get mesh.lanip.wwspeed)	
uci set watchping.speed.w=$(uci get mesh.lanip.wspeed)

uci commit watchping

currenc=$(uci get wireless.default_radio_adhoc.encryption)
newenc=$(uci get mesh.backhaul.encryption)

if [ $currenc != $newenc ]; then
	log "change backhaul encryption to $newenc"
	uci set wireless.default_radio_adhoc.encryption=$newenc
	wirechge=1
fi

currkey=$(uci get wireless.default_radio_adhoc.key)
newkey=$(uci get mesh.backhaul.key)

if [ "$currkey" != "$newkey" ]; then
	log "change backhaul key to $newkey"
	uci set wireless.default_radio_adhoc.key=$newkey
	wirechge=1
fi

count=$(uci get mesh.radiocnt.icount)

do_iface() {
	local config=$1
	local ssid
	local channel
	local htmode
	local encryption
	local key
	
	config_get ssid $1 ssid
	config_get channel $1 channel
	config_get htmode $1 htmode
	config_get encryption $1 encryption
	config_get key $1 key
	config_get device $1 device
	config_get drate $1 drate
	config_get brate $1 brate
	config_get oconfig $1 oconfig
	
	srate=$(uci get wireless.$device.supported_rates)
	if [ ! -z "$srate" -a $drate = "0" ]; then
		uci delete wireless.$device.supported_rates
		uci delete wireless.$device.basic_rate
		wirechge=1
	fi
	if [ -z "$srate" -a $drate = "1" ]; then
		uci add_list wireless.$device.supported_rates="6000 9000 12000 18000 24000 36000 48000 54000"
		wirechge=1
	fi
	if [ $drate = "1" ]; then
		wrate=$(uci get wireless.$device.basic_rate)
		case "$brate" in
			"6") BR="6000 9000 12000 18000 24000 36000 48000 54000"
				;;
			"9") BR="9000 12000 18000 24000 36000 48000 54000"
				;;
			"12") BR="12000 18000 24000 36000 48000 54000"
				;;
			"18") BR="18000 24000 36000 48000 54000"
				;;
			"24") BR="24000 36000 48000 54000"
				;;
			"36") BR="36000 48000 54000"
				;;
			"48") BR="48000 54000"
				;;
			"54") BR="54000"
				;;
		esac
		if [ "$wrate" != "$BR" ]; then
			log "change basic_rate to $BR"
			uci delete wireless.$device.basic_rate
			uci add_list wireless.$device.basic_rate="$BR"
			uci delete wireless.$device.supported_rates
			uci add_list wireless.$device.supported_rates="$BR"
			wirechge=1
		fi
	fi
	
	currssid=$(uci get wireless.$oconfig.ssid)
	if [ "$currssid" != "$ssid" ]; then
		log "change $config ssid to $ssid"
		uci set wireless.$oconfig.ssid=$ssid
		wirechge=1
	fi
	currchan=$(uci get wireless.$device.channel)
	if [ "$currchan" != "$channel" ]; then
		log "change $device channel to $channel"
		uci set wireless.$device.channel=$channel
		wirechge=1
	fi
	currht=$(uci get wireless.$device.htmode)
	if [ "$currht" != "$htmode" ]; then
		log "change $device htmode to $htmode"
		uci set wireless.$device.htmode=$htmode
		wirechge=1
	fi
	currenc=$(uci get wireless.$oconfig.encryption)
	if [ "$currenc" != "$encryption" ]; then
		log "change $config encryption to $encryption"
		uci set wireless.$oconfig.encryption=$encryption
		wirechge=1
	fi
	currkey=$(uci get wireless.$oconfig.key)
	if [ "$currkey" != "$key" ]; then
		log "change $config key to $key"
		uci set wireless.$oconfig.key=$key
		wirechge=1
	fi
}

config_load mesh
config_foreach do_iface wifi-iface

if [ $netchge = 1 ]; then
	uci commit network
	/etc/init.d/network restart
fi

if [ $wirechge = 1 ]; then
	uci commit wireless
	wifi up
fi