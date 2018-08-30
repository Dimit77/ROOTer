#!/bin/sh

. /lib/functions.sh

ROOTER=/usr/lib/rooter
ROOTER_LINK="/tmp/links"

log() {
	logger -t "Get Profile" "$@"
}

CURRMODEM=$1

MODEL=$(uci get modem.modem$CURRMODEM.model)
idV=$(uci get modem.modem$CURRMODEM.idV)
idP=$(uci get modem.modem$CURRMODEM.idP)
IMEI=$(uci get modem.modem$CURRMODEM.imei)
IMSI=$(uci get modem.modem$CURRMODEM.imsi)
ICCID=$(uci get modem.modem$CURRMODEM.iccid)

MATCH=0

do_custom() {
	local config=$1
	local select name enabled select1
	local model
	local imsi
	local vid
	local pid

	if [ $MATCH -eq 0 ]; then
		config_get select $1 select
		config_get name $1 name
		config_get enabled $1 enabled
		if [ -z $enabled ]; then
			enabled=1
		fi
		if [ -z $name ]; then
			name="Not Named"
		fi
		if [ $enabled -eq 1 ]; then
			case $select in
			"0" )
				config_get vid $1 vid
				config_get pid $1 pid
				if [ $idV = $vid -a $idP = $pid ]; then
					MATCH=1
					log "Modem ID Profile - "$name""
				fi
				;;
			"1" )
				config_get imei $1 imei
				if [ "$IMEI" == "$imei" ]; then
					MATCH=1
					log "Modem IMEI Profile - "$name""
				fi
				;;
			"2" )
				config_get model $1 model
				if [ "$MODEL" == "$model" ]; then
					MATCH=1
					log "Modem Model Profile - "$name""
				fi
				;;
			"3" )
				config_get imsi $1 imsi
				case $IMSI in
				"$imsi"*)
					MATCH=1
					log "SIM IMSI Profile - "$name""
					;;
				esac
				;;
			"4" )
				config_get iccid $1 iccid
				if [ "$ICCID" == "$iccid" ]; then
					MATCH=1
					log "SIM ICCID Profile - "$name""
				fi
				;;		
			esac
			if [ $MATCH = 1 ]; then
				config_get select1 $1 select1
				if [ $select1 -ne 10 ]; then
					MATCH=0
					case $select1 in
					"0" )
						config_get vid1 $1 vid1
						config_get pid1 $1 pid1
						if [ $idV = $vid1 -a $idP = $pid1 ]; then
							MATCH=1
							log "Modem ID Profile - "$name""
						fi
						;;
					"1" )
						config_get imei1 $1 imei1
						if [ "$IMEI" == "$imei1" ]; then
							MATCH=1
							log "Modem IMEI Profile - "$name""
						fi
						;;
					"2" )
						config_get model1 $1 model1
						if [ "$MODEL" == "$model1" ]; then
							MATCH=1
							log "Modem Model Profile - "$name""
						fi
						;;
					"3" )
						config_get imsi1 $1 imsi1
						case $IMSI in
						"$imsi1"*)
							MATCH=1
							log "SIM IMSI Profile - "$name""
							;;
						esac
						;;
					"4" )
						config_get iccid1 $1 iccid1
						if [ "$ICCID" == "$iccid1" ]; then
							MATCH=1
							log "SIM ICCID Profile - "$name""
						fi
						;;		
					esac
				fi
				if [ $MATCH = 1 ]; then
					local apn user passw pincode auth ppp delay lock mcc mnc
					local dns1 dns2 log lb at atc
					config_get apn $1 apn
					uci set modem.modeminfo$CURRMODEM.apn=$apn
					config_get user $1 user
					uci set modem.modeminfo$CURRMODEM.user=$user
					config_get passw $1 passw
					uci set modem.modeminfo$CURRMODEM.passw=$passw
					config_get pincode $1 pincode
					uci set modem.modeminfo$CURRMODEM.pincode=$pincode
					config_get auth $1 auth
					uci set modem.modeminfo$CURRMODEM.auth=$auth
					config_get ppp $1 ppp
					uci set modem.modeminfo$CURRMODEM.ppp=$ppp
					config_get delay $1 delay
					uci set modem.modeminfo$CURRMODEM.delay=$delay
					config_get lock $1 lock
					uci set modem.modeminfo$CURRMODEM.lock=$lock
					config_get mcc $1 mcc
					uci set modem.modeminfo$CURRMODEM.mcc=$mcc
					config_get mnc $1 mnc
					uci set modem.modeminfo$CURRMODEM.mnc=$mnc
					config_get dns1 $1 dns1
					uci set modem.modeminfo$CURRMODEM.dns1=$dns1
					config_get dns2 $1 dns2
					uci set modem.modeminfo$CURRMODEM.dns2=$dns2
					config_get log $1 log
					uci set modem.modeminfo$CURRMODEM.log=$log
					config_get lb $1 lb
					uci set modem.modeminfo$CURRMODEM.lb=$lb
					config_get at $1 at
					uci set modem.modeminfo$CURRMODEM.at=$at
					config_get atc $1 atc
					uci set modem.modeminfo$CURRMODEM.atc=$atc
					
					config_get alive $1 alive
					uci delete modem.pinginfo$CURRMODEM       
					uci set modem.pinginfo$CURRMODEM=pinfo$CURRMODEM
					uci set modem.pinginfo$CURRMODEM.alive=$alive
					if [ $alive -ne 0 ]; then
						local reliability count pingtime pingwait packetsize down up
						
						handle_trackip() {
							local value="$1"
							uci add_list modem.pinginfo$CURRMODEM.trackip=$value
						}
						config_list_foreach "$config" trackip handle_trackip
						TIP=$(uci get modem.pinginfo$CURRMODEM.trackip)
						if [ -z $TIP ]; then
							uci add_list modem.pinginfo$CURRMODEM.trackip="1.1.1.1"
						fi
						config_get reliability $1 reliability
						uci set modem.pinginfo$CURRMODEM.reliability=$reliability
						config_get count $1 count
						uci set modem.pinginfo$CURRMODEM.count=$count
						config_get pingtime $1 pingtime
						uci set modem.pinginfo$CURRMODEM.pingtime=$pingtime
						config_get pingwait $1 pingwait
						uci set modem.pinginfo$CURRMODEM.pingwait=$pingwait
						config_get packetsize $1 packetsize
						uci set modem.pinginfo$CURRMODEM.packetsize=$packetsize
						config_get down $1 down
						uci set modem.pinginfo$CURRMODEM.down=$down
						config_get up $1 up
						uci set modem.pinginfo$CURRMODEM.up=$up
					fi

					uci commit modem
				fi
			fi
		fi
	fi
}


config_load profile
config_foreach do_custom custom

if [ $MATCH = 0 ]; then
	uci set modem.modeminfo$CURRMODEM.apn=$(uci get profile.default.apn)
	uci set modem.modeminfo$CURRMODEM.user=$(uci get profile.default.user)
	uci set modem.modeminfo$CURRMODEM.passw=$(uci get profile.default.passw)
	uci set modem.modeminfo$CURRMODEM.pincode=$(uci get profile.default.pincode)
	uci set modem.modeminfo$CURRMODEM.auth=$(uci get profile.default.auth)
	uci set modem.modeminfo$CURRMODEM.ppp=$(uci get profile.default.ppp)
	uci set modem.modeminfo$CURRMODEM.delay=$(uci get profile.default.delay)
	uci set modem.modeminfo$CURRMODEM.lock=$(uci get profile.default.lock)
	uci set modem.modeminfo$CURRMODEM.mcc=$(uci get profile.default.mcc)
	uci set modem.modeminfo$CURRMODEM.mnc=$(uci get profile.default.mnc)
	uci set modem.modeminfo$CURRMODEM.dns1=$(uci get profile.default.dns1)
	uci set modem.modeminfo$CURRMODEM.dns2=$(uci get profile.default.dns2)
	uci set modem.modeminfo$CURRMODEM.log=$(uci get profile.default.log)
	uci set modem.modeminfo$CURRMODEM.lb=$(uci get profile.default.lb)
	uci set modem.modeminfo$CURRMODEM.at=$(uci get profile.default.at)
	uci set modem.modeminfo$CURRMODEM.atc=$(uci get profile.default.atc)
	
	alive=$(uci get profile.default.alive)
	uci delete modem.pinginfo$CURRMODEM       
	uci set modem.pinginfo$CURRMODEM=pinfo$CURRMODEM
	uci set modem.pinginfo$CURRMODEM.alive=$alive
	if [ $alive -ne 0 ]; then
	
		handle_trackip1() {
			local value="$1"
			uci add_list modem.pinginfo$CURRMODEM.trackip=$value
		}
		config_list_foreach "default" trackip handle_trackip1
		TIP=$(uci get modem.pinginfo$CURRMODEM.trackip)
		if [ -z $TIP ]; then
			uci add_list modem.pinginfo$CURRMODEM.trackip="1.1.1.1"
		fi
		uci set modem.pinginfo$CURRMODEM.reliability=$(uci get profile.default.reliability)
		uci set modem.pinginfo$CURRMODEM.count=$(uci get profile.default.count)
		uci set modem.pinginfo$CURRMODEM.pingtime=$(uci get profile.default.pingtime)
		uci set modem.pinginfo$CURRMODEM.pingwait=$(uci get profile.default.pingwait)
		uci set modem.pinginfo$CURRMODEM.packetsize=$(uci get profile.default.packetsize)
		uci set modem.pinginfo$CURRMODEM.down=$(uci get profile.default.down)
		uci set modem.pinginfo$CURRMODEM.up=$(uci get profile.default.up)
	fi
	
	uci commit modem
	log "Default Profile Used"
fi
