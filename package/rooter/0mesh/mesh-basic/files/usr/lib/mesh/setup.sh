#!/bin/sh 
. /lib/functions.sh

log() {
	logger -t "MESH-SETUP" "$@"
}

uci delete mesh.lanip
uci set mesh.lanip=lanip
uci set mesh.lanip.ip=$(uci get network.lan.ipaddr)
uci set mesh.lanip.host=$(uci get system.@system[-1].hostname)
uci set mesh.lanip.alive=$(uci get watchping.watchping.alive)
uci set mesh.lanip.pingtime=$(uci get watchping.watchping.pinginterval)
uci set mesh.lanip.pingwait=$(uci get watchping.watchping.pingwait)
uci set mesh.lanip.reliability=$(uci get watchping.watchping.reliability)
uci set mesh.lanip.count=$(uci get watchping.watchping.count)
uci set mesh.lanip.packetsize=$(uci get watchping.watchping.packetsize)
uci set mesh.lanip.down=$(uci get watchping.watchping.down)
uci set mesh.lanip.up=$(uci get watchping.watchping.up)

track_ips=
list_track_ips() {
	track_ips="$1 $track_ips"
}
config_load watchping
config_list_foreach "watchping" "trackip" list_track_ips
for track_ip in $track_ips; do
	uci add_list mesh.lanip.trackip=$track_ip
done

uci set mesh.lanip.m1speed=$(uci get watchping.speed.m1)	
uci set mesh.lanip.m2speed=$(uci get watchping.speed.m2)	
uci set mesh.lanip.wwspeed=$(uci get watchping.speed.ww)
uci set mesh.lanip.wspeed=$(uci get watchping.speed.w)

uci delete mesh.backhaul
uci set mesh.backhaul=back
uci set mesh.backhaul.radio=$(uci get wireless.default_radio_adhoc.device)
uci set mesh.backhaul.encryption=$(uci get wireless.default_radio_adhoc.encryption)
if [ $(uci get wireless.default_radio_adhoc.encryption) != "none" ]; then
	uci set mesh.backhaul.key=$(uci get wireless.default_radio_adhoc.key)
else
	uci set mesh.backhaul.key=
fi

do_radio() {
	local config=$1
	local htmode

	config_get channel $1 channel
	config_get htmode $1 htmode
	config_get supported_rates $1 supported_rates
	config_get basic_rate $1 basic_rate
	BH=$(uci get mesh.backhaul.radio)
	TT=" "
	if [ $config = $BH ]; then
		TT=" (Backhaul Radio)"
	fi
	SR="0"
	if [ ! -z "$supported_rates" ]; then
		SR="1"
	fi
	BR="18"
	if [ ! -z "$basic_rate" ]; then
		case "$basic_rate" in
			6000*)
				BR="6"
				;;
			9000*)
				BR="9"
				;;
			12000*)
				BR="12"
				;;
			18000*)
				BR="18"
				;;
			24000*)
				BR="24"
				;;
			36000*)
				BR="36"
				;;
			48000*)
				BR="48"
				;;
			54000*)
				BR="54"
				;;
		esac
	fi
	
	if [ $channel -lt 15 ]; then
		uci delete mesh.$config
		uci set mesh.$config=wifi-device
		uci set mesh.$config.device=$config
		uci set mesh.$config.text="2.4 GHz ($config)""$TT"
		uci set mesh.$config.channel=$channel
		uci set mesh.$config.htmode=$htmode
		uci set mesh.$config.two="1"
		cnt=$((cnt+1))
	else
		uci delete mesh.$config
		uci set mesh.$config=wifi-device
		uci set mesh.$config.device=$config
		uci set mesh.$config.text="5 GHz ($config)""$TT"
		uci set mesh.$config.channel=$channel
		uci set mesh.$config.htmode=$htmode
		uci set mesh.$config.two="0"
		cnt=$((cnt+1))
	fi
	uci set mesh.$config.drate=$SR
	uci set mesh.$config.brate=$BR
}

cnt=0
config_load wireless
config_foreach do_radio wifi-device
uci delete mesh.radiocnt
uci set mesh.radiocnt=radiocnt
uci set mesh.radiocnt.count=$cnt
uci commit mesh

do_iface() {
	local config=$1
	local mode
	local ssid
	local device
	local channel
	local htmode
	local encryption
	local key
	
	config_get mode $1 mode
	config_get ssid $1 ssid
	config_get device $1 device
	config_get channel $1 channel
	config_get htmode $1 htmode
	config_get encryption $1 encryption
	config_get key $1 key
	if [ $mode = "ap" ]; then
		oconfig=$config
		DEFT=$(echo $config | grep "default_")
		if [ -z $DEFT ]; then
			config="default_$(uci get mesh.$device.device)"
		fi
		uci delete mesh.$config
		uci set mesh.$config=wifi-iface
		uci set mesh.$config.ssid=$ssid
		uci set mesh.$config.oconfig=$oconfig
		uci set mesh.$config.text="$(uci get mesh.$device.text)" 
		uci set mesh.$config.channel="$(uci get mesh.$device.channel)"
		uci set mesh.$config.htmode="$(uci get mesh.$device.htmode)"
		uci set mesh.$config.device="$(uci get mesh.$device.device)"
		uci set mesh.$config.encryption="$encryption"
		uci set mesh.$config.key="$key"
		uci set mesh.$config.freq="$(uci get mesh.$device.two)"
		uci set mesh.$config.drate="$(uci get mesh.$device.drate)"
		uci set mesh.$config.brate="$(uci get mesh.$device.brate)"
		RADIO="$(uci get mesh.$device.device)"
		uci set mesh.$config.iface="$(ubus -S call network.wireless status | jsonfilter -l 1 -e "@."$RADIO".interfaces[@.config.mode=\"${mode}\"].ifname")"
		cnt=$((cnt+1))
	fi
}

cnt=0
config_load wireless
config_foreach do_iface wifi-iface
uci set mesh.radiocnt.icount=$cnt


uci commit mesh
