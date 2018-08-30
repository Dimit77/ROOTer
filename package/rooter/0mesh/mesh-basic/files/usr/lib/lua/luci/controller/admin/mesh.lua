module("luci.controller.admin.mesh", package.seeall)

function index()
	entry({"admin", "mesh"}, firstchild(), "Mesh", 37).dependent=false
	entry({"admin", "mesh", "mesh"}, cbi("mesh/mesh"), _("Mesh Setup"), 2)

	entry({"admin", "mesh", "externalip"}, call("action_externalip"))
end

function action_externalip()
	local rv ={}

	os.execute("rm -f /tmp/ipip; wget -O /tmp/ipip http://ipecho.net/plain > /dev/null 2>&1")
	file = io.open("/tmp/ipip", "r")
	if file == nil then
		rv["extip"] = "Not Available"
	else
		rv["extip"] = file:read("*line")
		if rv["extip"] == nil then
			rv["extip"] = "Not Available"
		end
		file:close()
	end

	luci.http.prepare_content("application/json")
	luci.http.write_json(rv)
end