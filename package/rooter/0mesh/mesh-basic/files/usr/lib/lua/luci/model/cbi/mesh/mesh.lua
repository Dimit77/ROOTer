local utl = require "luci.util"
local uci  = require "luci.model.uci".cursor()
local nt = require "luci.sys"
local fs    = require "nixio.fs"

config ={}
config.uci = uci.cursor()

luci.sys.call("/usr/lib/mesh/setup.sh")

nrad = config.uci:get("mesh", "radiocnt", "count")
irad = config.uci:get("mesh", "radiocnt", "icount")
local has_auth = fs.access("/lib/wifi/authsae.sh")

m = Map("mesh", translate("Mesh Setup"), translate("Configure the Mesh router Settings"))

m.on_before_apply = function(self)
	luci.sys.call("/usr/lib/mesh/finish.sh &")
end

local s = m:section(TypedSection, "lanip", translate("Basic Settings"), translate("Basic router and gateway settings."))
s.anonymous = true
s:tab("router", translate("Router Settings"))
s:tab("ping", translate("Gateway Detection"))
s:tab("speed", translate("Relative Gateway Speeds"))

this_tab = "router"

local o = s:taboption(this_tab, Value, "ip", translate("IP Address"), translate("Must be in same subnet as the other routers in the mesh"))
o.datatype = "ipaddr"
o.rmempty = true

local oh = s:taboption(this_tab, Value, "host", translate("Hostname"), translate("Should be different for each router in the mesh"))
oh.rmempty = true

this_tab = "ping"

alive = s:taboption(this_tab, ListValue, "alive", "Detection Status :"); 
alive.rmempty = true;
alive:value("0", "Disabled")
alive:value("1", "Enabled")
alive.default=0

reliability = s:taboption(this_tab, Value, "reliability", translate("Tracking reliability"),
		translate("Acceptable values: 1-100. This many Tracking IP addresses must respond for the link to be deemed up"))
reliability.datatype = "range(1, 100)"
reliability.default = "1"
reliability:depends("alive", "1")

count = s:taboption(this_tab, ListValue, "count", translate("Ping count"), translate("# of packets sent during ping"))
count.default = "1"
count:value("1")
count:value("2")
count:value("3")
count:value("4")
count:value("5")
count:depends("alive", "1")

interval = s:taboption(this_tab, ListValue, "pingtime", translate("Ping interval"),
		translate("Amount of time between tracking tests"))
interval.default = "10"
interval:value("5", translate("5 seconds"))
interval:value("10", translate("10 seconds"))
interval:value("20", translate("20 seconds"))
interval:value("30", translate("30 seconds"))
interval:value("60", translate("1 minute"))
interval:value("300", translate("5 minutes"))
interval:value("600", translate("10 minutes"))
interval:value("900", translate("15 minutes"))
interval:value("1800", translate("30 minutes"))
interval:value("3600", translate("1 hour"))
interval:depends("alive", "1")

timeout = s:taboption(this_tab, ListValue, "pingwait", translate("Ping timeout"), translate("Time to wait for ping response"))
timeout.default = "2"
timeout:value("1", translate("1 second"))
timeout:value("2", translate("2 seconds"))
timeout:value("3", translate("3 seconds"))
timeout:value("4", translate("4 seconds"))
timeout:value("5", translate("5 seconds"))
timeout:value("6", translate("6 seconds"))
timeout:value("7", translate("7 seconds"))
timeout:value("8", translate("8 seconds"))
timeout:value("9", translate("9 seconds"))
timeout:value("10", translate("10 seconds"))
timeout:depends("alive", "1")

packetsize = s:taboption(this_tab, Value, "packetsize", translate("Ping packet size in bytes"),
		translate("Acceptable values: 4-56. Number of data bytes to send in ping packets. This may have to be adjusted for certain ISPs"))
	packetsize.datatype = "range(4, 56)"
	packetsize.default = "56"
	packetsize:depends("alive", "1")
	
down = s:taboption(this_tab, ListValue, "down", translate("Interface down"),
		translate("Interface will be deemed down after this many failed ping tests"))
down.default = "3"
down:value("1")
down:value("2")
down:value("3")
down:value("4")
down:value("5")
down:value("6")
down:value("7")
down:value("8")
down:value("9")
down:value("10")
down:depends("alive", "1")

up = s:taboption(this_tab, ListValue, "up", translate("Interface up"),
		translate("Downed interface will be deemed up after this many successful ping tests"))
up.default = "3"
up:value("1")
up:value("2")
up:value("3")
up:value("4")
up:value("5")
up:value("6")
up:value("7")
up:value("8")
up:value("9")
up:value("10")
up:depends("alive", "1")

cb2 = s:taboption(this_tab, DynamicList, "trackip", translate("Tracking IP"),
		translate("This IP address will be pinged to dermine if the link is up or down."))
cb2.datatype = "ipaddr"
cb2:depends("alive", "1")

this_tab = "speed"

m1s = s:taboption(this_tab, ListValue, "m1speed", "Modem 1 Speed :", translate("Speed of Modem 1 relative to the other Internet sources")); 
m1s.rmempty = true;
m1s:value("10000", "Low")
m1s:value("20000", "Medium")
m1s:value("30000", "High")
m1s:value("40000", "Highest")
m1s.default="10000"

m2s = s:taboption(this_tab, ListValue, "m2speed", "Modem 2 Speed :", translate("Speed of Modem 2 relative to the other Internet sources")); 
m2s.rmempty = true;
m2s:value("10000", "Low")
m2s:value("20000", "Medium")
m2s:value("30000", "High")
m2s:value("40000", "Highest")
m2s.default="10000"

mwws = s:taboption(this_tab, ListValue, "wwspeed", "Hotspot Speed :", translate("Speed of the Hotspot relative to the other Internet sources")); 
mwws.rmempty = true;
mwws:value("10000", "Low")
mwws:value("20000", "Medium")
mwws:value("30000", "High")
mwws:value("40000", "Highest")
mwws.default="10000"

mws = s:taboption(this_tab, ListValue, "wspeed", "WAN Speed :", translate("Speed of the WAN relative to the other Internet sources")); 
mws.rmempty = true;
mws:value("10000", "Low")
mws:value("20000", "Medium")
mws:value("30000", "High")
mws:value("40000", "Highest")
mws.default="10000"	

local b = m:section(NamedSection, "backhaul", "backhaul", translate("Wifi Backhaul"), translate("Radio used for mesh backhaul. All nodes must use same channel for backhaul."))
local brad = b:option(ListValue, "radio", translate("Backhaul Radio"))
for i=0,nrad-1 do
	stri = string.format("%d", i)
	radio = "radio" .. stri
	device = config.uci:get("mesh", radio, "device")
	text = config.uci:get("mesh", radio, "text")
	brad:value(device, text)
end
if has_auth then
	local encrypt = b:option(ListValue, "encryption", translate("Backhaul Encryption"))
	encrypt:value("none", "None")
	encrypt:value("psk2", "Encrypted")
	local bkey = b:option(Value, "key", translate("Backhaul Encryption Key"))
	bkey:depends("encryption", "psk2")
	bkey.default = "rooter2017"
	bkey.rmempty=true
	bkey.password = true
end

w ={}
text = {}
chan2 = {}
chan5 = {}
htmode = {}
enc = {}
ekey = {}
ssid = {}
key = {}
drate = {}
brate = {}

for i=0,irad-1 do
	stri = string.format("%d", i)
	dradio = "default_radio" .. stri
	drad = config.uci:get("mesh", dradio, "freq")
	dtext = config.uci:get("mesh", dradio, "text")
	w[i] = m:section(NamedSection, dradio, dradio, translate("Wifi AP Interface : " .. dtext), translate("All mesh nodes must use the same SSID. If radio used for backhaul all nodes must use same channel."))

	ssid[i] = w[i]:option(Value, "ssid", translate("SSID"))

	chan2[i] = w[i]:option(ListValue, "channel", translate("Radio Channel"))
	if drad == "1" then
		chan2[i]:value("1", "2.412 GHz (Channel 1)")
		chan2[i]:value("2", "2.417 GHz (Channel 2)")
		chan2[i]:value("3", "2.422 GHz (Channel 3)")
		chan2[i]:value("4", "2.427 GHz (Channel 4)")
		chan2[i]:value("5", "2.432 GHz (Channel 5)")
		chan2[i]:value("6", "2.437 GHz (Channel 6)")
		chan2[i]:value("7", "2.442 GHz (Channel 7)")
		chan2[i]:value("8", "2.447 GHz (Channel 8)")
		chan2[i]:value("9", "2.452 GHz (Channel 9)")
		chan2[i]:value("10", "2.457 GHz (Channel 10)")
		chan2[i]:value("11", "2.462 GHz (Channel 11)")
	else
		chan2[i]:value("36", "5.180 GHz (Channel 36)")
		chan2[i]:value("40", "5.200 GHz (Channel 40)")
		chan2[i]:value("44", "5.220 GHz (Channel 44)")
		chan2[i]:value("48", "5.240 GHz (Channel 48)")
		chan2[i]:value("52", "5.260 GHz (Channel 52)")
		chan2[i]:value("56", "5.280 GHz (Channel 56)")
		chan2[i]:value("60", "5.300 GHz (Channel 60)")
		chan2[i]:value("64", "5.320 GHz (Channel 64)")
		chan2[i]:value("100", "5.500 GHz (Channel 100)")
		chan2[i]:value("104", "5.520 GHz (Channel 104)")
		chan2[i]:value("108", "5.540 GHz (Channel 108)")
		chan2[i]:value("112", "5.560 GHz (Channel 112)")
		chan2[i]:value("116", "5.580 GHz (Channel 116)")
		chan2[i]:value("120", "5.600 GHz (Channel 120)")
		chan2[i]:value("124", "5.620 GHz (Channel 124)")
		chan2[i]:value("128", "5.640 GHz (Channel 128)")
		chan2[i]:value("132", "5.660 GHz (Channel 132)")
		chan2[i]:value("136", "5.680 GHz (Channel 136)")
		chan2[i]:value("140", "5.700 GHz (Channel 140)")
		chan2[i]:value("149", "5.745 GHz (Channel 149)")
		chan2[i]:value("153", "5.765 GHz (Channel 153)")
		chan2[i]:value("157", "5.785 GHz (Channel 157)")
		chan2[i]:value("161", "5.805 GHz (Channel 161)")
		chan2[i]:value("165", "5.825 GHz (Channel 165)")
	end
	
	dface = config.uci:get("mesh", dradio, "iface")
	iw = luci.sys.wifi.getiwinfo(dface)
	if iw ~= nil then
		ht_modes = iw.htmodelist or { }
	
		htmode[i] = w[i]:option(ListValue, "htmode", translate("Radio Channel Width"))
		if ht_modes["HT20"] and (not ht_modes["VHT20"]) then
			htmode[i]:value("HT20", "20 MHz")
		end
		if ht_modes["HT40"] and (not ht_modes["VHT40"]) then
			htmode[i]:value("HT40", "40 MHz")
		end
		if ht_modes["VHT20"] then
			htmode[i]:value("VHT20", "20 MHz")
		end
		if ht_modes["VHT40"] then
			htmode[i]:value("VHT40", "40 MHz")
		end
		if ht_modes["VHT80"] then
			htmode[i]:value("VHT80", "80 MHz")
		end
		if ht_modes["VHT160"] then
			htmode[i]:value("VHT160", "160 MHz")
		end
	end
	
	enc[i] = w[i]:option(ListValue, "encryption", translate("Wifi Encryption"))
	enc[i]:value("none", "None")
	enc[i]:value("psk", "WPA-PSK")
	enc[i]:value("psk2", "WPA2-PSK")
	enc[i]:value("psk-mixed", "WPA-PSK/WPA2-PSK Mixed Mode")
	enc[i]:value("wpa", "WPA-EAP")
	enc[i]:value("wpa2", "WPA2-EAP")
	
	key[i] = w[i]:option(Value, "key", translate("Wifi Encryption Key"))
	key[i]:depends("encryption", "psk")
	key[i]:depends("encryption", "psk2")
	key[i]:depends("encryption", "psk-mixed")
	key[i]:depends("encryption", "wpa")
	key[i]:depends("encryption", "wpa2")
	key[i].default = "rooter2017"
	key[i].rmempty=true
	key[i].password = true
	
	drate[i] = w[i]:option(ListValue, "drate", translate("Set Minimum Data Rate"), translate("Set a minimum data rate for dropping client connection."))
	drate[i]:value("0", "No")
	drate[i]:value("1", "Yes")
	drate[i].default = "0"
	
	brate[i] = w[i]:option(Value, "brate", translate("Minimum Data Rate"), translate("Minimum data rate before dropping client."))
	brate[i]:value("6", "6000")
	brate[i]:value("9", "9000")
	brate[i]:value("12", "12000")
	brate[i]:value("18", "18000")
	brate[i]:value("24", "24000")
	brate[i]:value("36", "36000")
	brate[i]:value("48", "24000")
	brate[i]:value("54", "54000")
	brate[i].default = "18"
	brate[i]:depends("drate", "1")


end

return m


