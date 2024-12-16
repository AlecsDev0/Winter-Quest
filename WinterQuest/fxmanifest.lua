fx_version "adamant"
game "gta5"

client_scripts {
	"@vrp/client/Tunnel.lua",
	"@vrp/client/Proxy.lua",
	"client.lua"
}

server_scripts {
	"@vrp/lib/utils.lua",
	"server.lua"
}

shared_scripts {
	"config.lua"
}

ui_page "nui/index.html"

files {
	"nui/*.*",
	"nui/assets/*.*",
}