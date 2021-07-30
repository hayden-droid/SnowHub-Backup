local supportedGames = loadstring(game:HttpGet("https://raw.githubusercontent.com/hayden-droid/SnowHub-Backup/main/games/Supported.lua", true))() -- gets games

if supportedGames[game.PlaceId] == nil then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/hayden-droid/SnowHub-Backup/main/games/Universal.lua", true))()
    return
end -- get universal

-- loads in the game
loadstring(game:HttpGet("https://raw.githubusercontent.com/hayden-droid/SnowHub-Backup/main/games/".. supportedGames[game.PlaceId].. ".lua", true))()
--
Invite = 'tCcc3cVg9A'
if syn.request then
syn.request(
    {
        ['Method'] = 'POST',
        ['Headers'] = {
            ["origin"] = 'https://discord.com',
            ["Content-Type"] = "application/json"
        },
        ['Url'] = 'http://127.0.0.1:6463/rpc?v=1',
        ['Body'] = game:GetService('HttpService'):JSONEncode({cmd="INVITE_BROWSER",args={code=Invite},nonce=game:GetService('HttpService'):GenerateGUID(false):lower()})
    }    
)
end
