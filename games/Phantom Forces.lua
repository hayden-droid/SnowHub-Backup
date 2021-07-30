--// Snow Hub | Phantom Forces
local Settings = {color = Color3.new(1,0,0)}
local Client = setmetatable({
	{"aimbot", false, "Aimbot", "aim"},
	{"silent_aim", false, "Silent Aim", "aim"},
	{"bone", "Head", "Hit Part", "aim", {"Head", "Torso"}},
	{"smoothness", 50, "Smoothness", "aim", 1, 200},
	{"fov_used", false, "Use Fov", "aim"},
	{"fov", 100, "Fov", "aim", 1, 1000},
	{"box_esp", false, "Box Esp", "esp"},
	{"tracer_esp", false, "Tracer Esp", "esp"},
	{"name_esp", false, "Name Esp", "esp"},
	{"distance_esp", false, "Distance Esp", "esp"},
	{"walkspeed", 0, "Walk Speed", "move", 0, 100},
	{"jumppower", 0, "Jump Power", "move", 0, 100},
	{"gravity", 0, "Gravity", "move", 0, 100},
	{"fall", false, "No Fall Damage", "move"},
	{"bhop", false, "B-Hop", "move"},
	{"spoof", false, "Spoof Stance", "anti"},
	{"stance", "Head", "Stance", "anti", {"stand", "crouch", "prone"}},
	{"dir", false, "Spoof Direction", "anti"},
	{"yaw", 180, "Yaw", "anti", 0, 360},
	{"pitch", 90, "Pitch", "anti", 0, 180},
	{"spin", false, "Spin Bot", "anti"},
	{"speed", 100, "Spin Speed", "anti", 0, 200},
	{"recoil", false, "No Recoil", "gun"},
	{"spread", false, "No Spread", "gun"},
	{"auto", false, "Auto Weapons", "gun"},
	{"combine", false, "Combine Mags", "gun"},
	{"sway", false, "No Sway", "gun"}
}, {__index = function(self, Name)
	for i = 1, #self do
		if self[i][1] == Name then
			return self[i][2]
		elseif self[i][3] == Name then
			return self[i]
		end
	end
	return self[Name]
end})
local Tables = {
    particle = "reset",
    effects = "bloodhit",
    char = "setbasewalkspeed",
    network = "send",
    camera = "angles",
    vector = "toanglesyx",
    hud = "getplayerhealth",
    replication = "getbodyparts",
    input = "mouse",
    gamelogic = "gammo"
}
for i, v in pairs(getgc(true)) do
    if type(v) == "table" then
        for o, b in pairs(Tables) do
            if rawget(v, b) then
                getgenv()[o] = v
            end
        end
    end
end
local Old_Vars = {
	Metatable = getrawmetatable(game),
	Namecall = getrawmetatable(game).__namecall,
	Index = getrawmetatable(game).__index,
	Players = game:GetService("Players"),
	LocalPlayer = game:GetService("Players").LocalPlayer,
	Mouse = game:GetService("Players").LocalPlayer:GetMouse(),
	RunService = game:GetService("RunService"),
	UserInputService = game:GetService("UserInputService"),
	Workspace = game:GetService("Workspace"),
	Camera = game:GetService("Workspace").CurrentCamera,
	Gravity = game:GetService("Workspace").Gravity,
	FindFirstChild = game:GetService("Workspace").FindFirstChild,
    Chars = debug.getupvalue(replication.getbodyparts, 1),
    BulletCheck = require(game:GetService("ReplicatedFirst").SharedModules.Old.BulletCheck),
    setbasewalkspeed = char.setbasewalkspeed,
    jump = char.jump,
    Send = network.send
}
local Physics = game:GetService("ReplicatedFirst").SharedModules.Old.Utilities.Math.physics:Clone()
Physics.Parent = Workspace
Physics.Name = "snowhub data"
local gundata = require(game:GetService("ReplicatedFirst").SharedModules.Old.Data.GunDataGetter)
local getGunModule = gundata.getGunModule
local trajectory = require(Physics).trajectory
local Drawing_Props = {
    Thickness = 1,
    Filled = false,
    Transparency = 1,
    Outline = true,
    Center = true,
    Visible = false,
    Size = 20,
    Color = Settings.color
}
local Lib = loadstring(game:HttpGet(("https://snowhub.dev/developer/library"), true))()
local Window = Lib:Window("Phantom Forces")
local Tabs = {aim = Window:Tab("Combat"), esp = Window:Tab("Visuals"), move = Window:Tab("Movement"), anti = Window:Tab("Anti Aim"), gun = Window:Tab("Gun Mods")}
for i = 1, #Client do
	local Data = Client[i]
	Settings[Data[1]] = Data[2]
	if type(Data[2]) == "boolean" then
		Tabs[Data[4]]:Toggle(Data[3], Data[2], function(Bool)
    		Client[i][2] = Bool
    		Settings[Data[1]] = Bool
		end)
	elseif type(Data[2]) == "number" then
		Tabs[Data[4]]:Slider(Data[3], Data[5], Data[6], Data[2], 1, function(Number)
    		Client[i][2] = Number
    		Settings[Data[1]] = Number
		end)
	elseif type(Data[2]) == "string" then
		Tabs[Data[4]]:Dropdown(Data[3], Data[5], function(Option)
    		Client[i][2] = Option
    		Settings[Data[1]] = Option
		end)
	end
end
Tabs.esp:Colorpicker("Visuals Color", Color3.new(1,0,0), function(Color)
    Settings["color"] = Color
end)
for i, v in pairs(Old_Vars) do
	getgenv()[i] = v
end
function DrawingTemplate(Item)
	local Draw = Drawing.new(Item)
	for i, v in pairs(Drawing_Props) do
		pcall(function()
			Draw[i] = v
		end)
	end
	return Draw
end
function IsAlive(Player)
	if Chars[Player] ~= nil and rawget(Chars[Player], "head") then
		return Chars[Player].head:IsDescendantOf(Workspace)
	end
	return false
end
function FindTarget()
    local Target = nil
    local Magnitude = math.huge
    for i, v in pairs(Chars) do
        if IsAlive(i) then
            if i.Team ~= LocalPlayer.Team then
                local Position, Visible = Camera:WorldToScreenPoint(v.head.Position)
                if Visible then
                    local Mouse = UserInputService:GetMouseLocation()
                    local Distance = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(Position.X, Position.Y)).Magnitude
                    if not Settings.fov_used and Distance < Magnitude or Settings.fov_used and Distance < Magnitude and Distance < Settings.fov then
                        Target = i
                        Magnitude = Distance
                    end
                end
            end
        end
    end
    return Target
end
function GetCharInfo(Char)
	local Head, Visible = Camera:WorldToViewportPoint(Char.head.Position)
    local TopY = math.huge
    local BottomY = -math.huge
    local RightX = -math.huge
    local LeftX = math.huge
    local Offsets = (Camera:WorldToViewportPoint(Char.head.Position + Vector3.new(0, 1.25, 0)) - Head).Y
    for i, v in pairs(Char) do
        if i ~= "rootpart" then
            local Position, OnScreen = Camera:WorldToViewportPoint(v.Position)
            if OnScreen then
                if Position.Y < TopY then
                    TopY = Position.Y
                end
                if Position.Y > BottomY then
                    BottomY = Position.Y
                end
                if Position.X < LeftX then
                    LeftX = Position.X
                end
                if Position.X > RightX then
                    RightX = Position.X
                end
            end
        end
    end
    return {PointB = Vector2.new(LeftX + Offsets, TopY + Offsets), PointA = Vector2.new(RightX - Offsets, TopY + Offsets), PointC = Vector2.new(LeftX + Offsets, BottomY - Offsets), PointD = Vector2.new(RightX - Offsets, BottomY - Offsets)}, Vector2.new(Head.X, Head.Y), Visible
end
function Visuals(Player, Char)
	local Tag = math.random(0, 999999999)
	local Box = DrawingTemplate("Quad")
	local Tracer = DrawingTemplate("Line")
	local Name = DrawingTemplate("Text")
	local Distance = DrawingTemplate("Text")
	local Started = false
	Name.Text = "[ " .. Player.Name .. " ]"
	Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
	RunService:BindToRenderStep(Tag, 1, function()
		if IsAlive(Player) and Player.Team ~= LocalPlayer.Team then
			local Corners, Position, Visible = GetCharInfo(Char)
			Box.Visible = Settings.box_esp and Visible or false
			Name.Visible = Settings.name_esp and Visible or false
			Distance.Visible = Settings.distance_esp and Visible or false
			Tracer.Visible = Settings.tracer_esp and Visible or false
			Box.Color = Settings.color
			Name.Color = Settings.color
			Distance.Color = Settings.color
			Tracer.Color = Settings.color
			Started = true
			if Settings.box_esp then
				for i, v in pairs(Corners) do
					Box[i] = v
				end
			end
			if Settings.tracer_esp then
				Tracer.To = Vector2.new(Position.X, Corners.PointC.Y)
			end
			if Settings.name_esp then
				Name.Position = Position - Vector2.new(0, 50)
			end
			if Settings.distance_esp and LocalPlayer.Character and FindFirstChild(LocalPlayer.Character, "Head") then
				Distance.Position = Position - Vector2.new(0, 37)
				Distance.Text = "[ " .. tostring(math.floor((LocalPlayer.Character.Head.Position - Char.head.Position).Magnitude + 0.5)) .. " ]"
			end
		elseif Started then
			Box:Remove()
			Name:Remove()
			Distance:Remove()
			Tracer:Remove()
			RunService:UnbindFromRenderStep(Tag)
		end
	end)
end
for i, v in pairs(Chars) do
    Visuals(i, v)
end
setmetatable(Chars, {
    __newindex = function(self, Player, Char)
        Visuals(Player, Char)
        return rawset(self, Player, Char)
    end
})
local Fov = Drawing.new("Circle")
Fov.Radius = Client.fov
Fov.Visible = Client.fov_used
Fov.NumSides = 100
Fov.Filled = false
Fov.Transparency = 1
Fov.Thickness = 1
Fov.Color = Settings.color
local SpinAddition = 0
local RealSpeed = 0
function network.send(self, func, ...)
    if func == "newbullets" and Settings.silent_aim then
        local Args = {...}
        local Target = FindTarget()
        if Target then
            local Head = Settings.bone == "Head" and Chars[Target].head or Chars[Target].torso
            local Velocity, Time = trajectory(Args[1].firepos, Vector3.new(0, -196.19999694824, 0), Head.Position, gamelogic.currentgun.data.bulletspeed)
            local Data = Args[1].bullets[1]
            Args[1].bullets[1][1] = Velocity
            delay(Time, function()
                Send(self, "bullethit", Target, Head.Position, Head, Args[1].bullets[1][2])
            end)
            return Send(self, func, unpack(Args))
        end
        return Send(self, func, unpack(Args))
    end
    if func == "repupdate" then
        local Args = {...}
        if Settings.dir then
            Args[2] = Vector2.new(-1.5 + 1 / 180 * Settings.pitch * 3, Args[2].Y + (-3.25 + 1 / 360 * Settings.yaw * 6.5))
        end
        if Settings.spin then
            Args[2] = Vector2.new(Args[2].X, SpinAddition)
            SpinAddition = SpinAddition + Settings.speed / 100
        end
        return Send(self, func, unpack(Args))
    end
    if func == "stance" and Settings.spoof then
        return Send(self, func, Settings.stance)
    end
    if func == "falldamage" and Settings.fall then
        return
    end
    return Send(self, func, ...)
end
function char.jump(self, Height)
    return jump(self, Height + Settings.jumppower)
end
function char.setbasewalkspeed(self, Speed)
    RealSpeed = Settings.walkspeed
    return setbasewalkspeed(self, Speed + Settings.walkspeed)
end
function gundata.getGunModule(gun)
    local module = game:GetService("ReplicatedStorage").GunModules[gun]:Clone()
    local data = require(module)
    if Settings.recoil and data["camkickspeed"] and data["aimcamkickspeed"] and data["modelkickspeed"] then
        data.camkickspeed = 999999
        data.aimcamkickspeed = 999999
        data.modelkickspeed = 999999
    end
    if Settings.sway and data["swayamp"] and data["swayspeed"] and data["steadyspeed"] and data["breathspeed"] then
        data.swayamp = 0.000000001
        data.swayspeed = 0.000000001
        data.steadyspeed = 0.000000001
        data.breathspeed = 0.000000001
    end
    if Settings.spread and data["hipfirespread"] and data["hipfirestability"] and data["hipfirespreadrecover"] then
        data.hipfirespread = 0.000000001
        data.hipfirestability = 0.000000001
        data.hipfirespreadrecover = 999999
    end
    if Settings.auto and data["firemodes"] then
        data.firemodes = {true}
    end
    if Settings.combine and data["sparerounds"] and data.animations["magsize"] then
        data.magsize = data.magsize + data.sparerounds
        data.sparerounds = 0
    end
    return module
end
RunService.RenderStepped:Connect(function()
    local Mouse = UserInputService:GetMouseLocation()
    Fov.Position = Vector2.new(Mouse.X, Mouse.Y)
	if Settings.fov_used ~= nil then
		Fov.Visible = Settings.fov_used
	end
	Fov.Radius = Settings.fov or Fov.Radius
	Fov.Color = Settings.color
	Workspace.Gravity = Gravity - Gravity * 0.01 * Settings.gravity
    if RealSpeed ~= Settings.walkspeed and rawget(gamelogic, "currentgun") and rawget(gamelogic.currentgun, "data") then
        RealSpeed = Settings.walkspeed
        setbasewalkspeed(self, gamelogic.currentgun.data.walkspeed + Settings.walkspeed)
    end
    if Settings.bhop and UserInputService:IsKeyDown(Enum.KeyCode.Space) and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.Jump = true
    end
end)
local Shooting = false
while wait(0) do
    if Settings.aimbot and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local Target = FindTarget()
        if Target and Chars[Target] and Chars[Target]["head"] and Chars[Target]["torso"] then
            local Position = Camera:WorldToViewportPoint(Settings.bone == "Head" and Chars[Target].head.Position or Chars[Target].torso.Position)
            local Mouse = UserInputService:GetMouseLocation()
            mousemoverel((Position.X - Mouse.X) / ((Settings.smoothness or 100) / 10), (Position.Y - Mouse.Y) / ((Settings.smoothness or 100) / 10))
        end
    end
end
