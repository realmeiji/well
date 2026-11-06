local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Tween = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Http = game:GetService("HttpService")

local lp = Players.LocalPlayer
local cam = workspace.CurrentCamera

if CoreGui:FindFirstChild("olliehub") then CoreGui.olliehub:Destroy() end

local S = {
    aim = {on=false, method="Raycast", part="Head", hitchance=100},
    esp = {on=false, hl=true, name=true, hp=true, trace=false, box=true, studs=5000},
    mv  = {noclip=false, speed=false, spd=16, jump=false, jmp=50, fly=false, vfly=false},
    cos = {headless=false, korblox=false},
}

-- platform detection
local isMobile = UIS.TouchEnabled and not UIS.KeyboardEnabled
local isConsole = UIS.GamepadEnabled and not UIS.KeyboardEnabled
local isPC = UIS.KeyboardEnabled
local platform = isMobile and "Mobile" or isConsole and "Console" or "PC"

-- otg check is garbage but people ask
local hasOTG = isMobile and #UIS:GetConnectedGamepads() > 0

local colors = {
    bg = Color3.fromRGB(16,16,20),
    glass = Color3.fromRGB(255,255,255),
    accent = Color3.fromRGB(140,110,255),
    text = Color3.fromRGB(235,235,245),
    dim = Color3.fromRGB(140,140,160),
}

local function corner(o,r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 10)
    c.Parent = o
    return c
end

local function stroke(o, col, tr)
    local s = Instance.new("UIStroke")
    s.Color = col or colors.glass
    s.Transparency = tr or 0.88
    s.Thickness = 1
    s.Parent = o
    return s
end

local function drag(frame, handle)
    handle = handle or frame
    local active = false
    local start, origin
    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
            active = true
            start = i.Position
            origin = frame.Position
        end
    end)
    handle.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
            active = false
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if active and (i.UserInputType == Enum.UserInputType.MouseMovement
        or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - start
            frame.Position = UDim2.new(origin.X.Scale, origin.X.Offset + d.X,
                                       origin.Y.Scale, origin.Y.Offset + d.Y)
        end
    end)
end

-- root
local gui = Instance.new("ScreenGui")
gui.Name = "olliehub"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.DisplayOrder = 999
gui.Parent = CoreGui

-- scale based on platform
local scale = isMobile and UDim2.new(0, 380, 0, 300) or UDim2.new(0, 520, 0, 380)
local mainPos = isMobile and UDim2.new(0.5, -190, 0.5, -150) or UDim2.new(0.5, -260, 0.5, -190)

local main = Instance.new("Frame")
main.Size = scale
main.Position = mainPos
main.BackgroundColor3 = colors.bg
main.BackgroundTransparency = 0.12
main.BorderSizePixel = 0
main.ClipsDescendants = true
main.Active = true
main.Parent = gui
corner(main, 14)
stroke(main)

local glass = Instance.new("Frame")
glass.Size = UDim2.new(1,0,1,0)
glass.BackgroundColor3 = colors.glass
glass.BackgroundTransparency = 0.94
glass.BorderSizePixel = 0
glass.ZIndex = 1
glass.Parent = main
corner(glass, 14)

local tbar = Instance.new("Frame")
tbar.Size = UDim2.new(1,0,0,40)
tbar.BackgroundTransparency = 1
tbar.ZIndex = 4
tbar.Parent = main
drag(main, tbar)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,-90,1,0)
title.Position = UDim2.new(0,16,0,0)
title.BackgroundTransparency = 1
title.Text = "ollie // " .. platform
title.TextColor3 = colors.text
title.TextXAlignment = Enum.TextXAlignment.Left
title.Font = Enum.Font.GothamBold
title.TextSize = isMobile and 14 or 16
title.ZIndex = 5
title.Parent = tbar

-- close
local close = Instance.new("TextButton")
close.Size = UDim2.new(0,26,0,26)
close.Position = UDim2.new(1,-36,0,7)
close.BackgroundColor3 = Color3.fromRGB(220,70,80)
close.BackgroundTransparency = 0.4
close.Text = "×"
close.TextColor3 = colors.text
close.Font = Enum.Font.GothamBold
close.TextSize = 16
close.ZIndex = 5
close.Parent = tbar
corner(close, 6)
close.MouseButton1Click:Connect(function() gui:Destroy() end)

-- minimize
local min = Instance.new("TextButton")
min.Size = UDim2.new(0,26,0,26)
min.Position = UDim2.new(1,-68,0,7)
min.BackgroundColor3 = colors.accent
min.BackgroundTransparency = 0.4
min.Text = "—"
min.TextColor3 = colors.text
min.Font = Enum.Font.GothamBold
min.TextSize = 16
min.ZIndex = 5
min.Parent = tbar
corner(min, 6)
local minimized = false
min.MouseButton1Click:Connect(function()
    minimized = not minimized
    Tween:Create(main, TweenInfo.new(0.2), {
        Size = minimized and UDim2.new(scale.X.Scale, scale.X.Offset, 0, 40) or scale
    }):Play()
end)

-- sidebar
local side = Instance.new("Frame")
side.Size = UDim2.new(0, isMobile and 90 or 118, 1, -54)
side.Position = UDim2.new(0, 10, 0, 46)
side.BackgroundTransparency = 1
side.ZIndex = 3
side.Parent = main
local sl = Instance.new("UIListLayout")
sl.Padding = UDim.new(0,5)
sl.SortOrder = Enum.SortOrder.LayoutOrder
sl.Parent = side

local content = Instance.new("Frame")
content.Size = UDim2.new(1, isMobile and -110 or -138, 1, -54)
content.Position = UDim2.new(0, isMobile and 100 or 128, 0, 46)
content.BackgroundTransparency = 1
content.ClipsDescendants = true
content.ZIndex = 3
content.Parent = main

local function tab(name)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1,0,0,30)
    b.BackgroundColor3 = colors.glass
    b.BackgroundTransparency = 0.93
    b.BorderSizePixel = 0
    b.Text = "  " .. name
    b.TextColor3 = colors.text
    b.TextXAlignment = Enum.TextXAlignment.Left
    b.Font = Enum.Font.Gotham
    b.TextSize = isMobile and 11 or 12
    b.AutoButtonColor = false
    b.Parent = side
    corner(b, 7)
    return b
end

local function page(name)
    local p = Instance.new("ScrollingFrame")
    p.Name = name
    p.Size = UDim2.new(1,0,1,0)
    p.BackgroundTransparency = 1
    p.Visible = false
    p.BorderSizePixel = 0
    p.ScrollBarThickness = 3
    p.ScrollBarImageColor3 = colors.accent
    p.CanvasSize = UDim2.new(0,0,0,0)
    p.AutomaticCanvasSize = Enum.AutomaticSize.Y
    p.Parent = content
    local l = Instance.new("UIListLayout")
    l.Padding = UDim.new(0,5)
    l.SortOrder = Enum.SortOrder.LayoutOrder
    l.Parent = p
    return p
end

local function toggle(parent, label, init, cb)
    local r = Instance.new("Frame")
    r.Size = UDim2.new(1,0,0,28)
    r.BackgroundColor3 = colors.glass
    r.BackgroundTransparency = 0.94
    r.BorderSizePixel = 0
    r.Parent = parent
    corner(r, 6)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,-60,1,0)
    lbl.Position = UDim2.new(0,10,0,0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = colors.text
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = isMobile and 11 or 12
    lbl.Parent = r

    local track = Instance.new("Frame")
    track.Size = UDim2.new(0,36,0,18)
    track.Position = UDim2.new(1,-46,0.5,-9)
    track.BackgroundColor3 = init and colors.accent or Color3.fromRGB(55,55,65)
    track.BorderSizePixel = 0
    track.Parent = r
    corner(track, 999)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0,14,0,14)
    knob.Position = init and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7)
    knob.BackgroundColor3 = Color3.fromRGB(255,255,255)
    knob.BorderSizePixel = 0
    knob.Parent = track
    corner(knob, 999)

    local st = init
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1,0,1,0)
    b.BackgroundTransparency = 1
    b.Text = ""
    b.Parent = r
    b.MouseButton1Click:Connect(function()
        st = not st
        cb(st)
        Tween:Create(track, TweenInfo.new(0.15),
            {BackgroundColor3 = st and colors.accent or Color3.fromRGB(55,55,65)}):Play()
        Tween:Create(knob, TweenInfo.new(0.15),
            {Position = st and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7)}):Play()
    end)
end

local function slider(parent, label, mn, mx, init, cb)
    local r = Instance.new("Frame")
    r.Size = UDim2.new(1,0,0,40)
    r.BackgroundColor3 = colors.glass
    r.BackgroundTransparency = 0.94
    r.BorderSizePixel = 0
    r.Parent = parent
    corner(r, 6)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,-90,0,16)
    lbl.Position = UDim2.new(0,10,0,3)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = colors.text
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = isMobile and 11 or 12
    lbl.Parent = r

    local val = Instance.new("TextLabel")
    val.Size = UDim2.new(0,60,0,16)
    val.Position = UDim2.new(1,-70,0,3)
    val.BackgroundTransparency = 1
    val.Text = tostring(init)
    val.TextColor3 = colors.accent
    val.TextXAlignment = Enum.TextXAlignment.Right
    val.Font = Enum.Font.GothamBold
    val.TextSize = isMobile and 11 or 12
    val.Parent = r

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1,-20,0,4)
    bar.Position = UDim2.new(0,10,1,-10)
    bar.BackgroundColor3 = Color3.fromRGB(55,55,65)
    bar.BorderSizePixel = 0
    bar.Parent = r
    corner(bar, 999)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((init-mn)/(mx-mn),0,1,0)
    fill.BackgroundColor3 = colors.accent
    fill.BorderSizePixel = 0
    fill.Parent = bar
    corner(fill, 999)

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,0,1,0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Parent = bar

    local down = false
    btn.MouseButton1Down:Connect(function() down = true end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then down = false end
    end)
    UIS.InputChanged:Connect(function(i)
        if not down then return end
        if i.UserInputType ~= Enum.UserInputType.MouseMovement
        and i.UserInputType ~= Enum.UserInputType.Touch then return end
        local mx2 = isMobile and i.Position.X or UIS:GetMouseLocation().X
        local ax = bar.AbsolutePosition.X
        local aw = bar.AbsoluteSize.X
        local pct = math.clamp((mx2-ax)/aw, 0, 1)
        local v = mn + (mx-mn)*pct
        fill.Size = UDim2.new(pct,0,1,0)
        val.Text = tostring(math.floor(v))
        cb(v)
    end)
end

local function dropdown(parent, label, opts, init, cb)
    local r = Instance.new("Frame")
    r.Size = UDim2.new(1,0,0,28)
    r.BackgroundColor3 = colors.glass
    r.BackgroundTransparency = 0.94
    r.BorderSizePixel = 0
    r.ClipsDescendants = true
    r.Parent = parent
    corner(r, 6)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,-100,0,28)
    lbl.Position = UDim2.new(0,10,0,0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = colors.text
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = isMobile and 11 or 12
    lbl.Parent = r

    local sel = Instance.new("TextLabel")
    sel.Size = UDim2.new(0,80,0,20)
    sel.Position = UDim2.new(1,-90,0,4)
    sel.BackgroundColor3 = Color3.fromRGB(35,35,45)
    sel.Text = init or opts[1]
    sel.TextColor3 = colors.accent
    sel.Font = Enum.Font.GothamBold
    sel.TextSize = 11
    sel.Parent = r
    corner(sel, 4)

    local open = false
    local list = Instance.new("Frame")
    list.Size = UDim2.new(1,-8,0,#opts*22+4)
    list.Position = UDim2.new(0,4,0,30)
    list.BackgroundColor3 = Color3.fromRGB(22,22,28)
    list.BorderSizePixel = 0
    list.Visible = false
    list.Parent = r
    corner(list, 6)
    local ll = Instance.new("UIListLayout"); ll.Parent = list

    for _,o in ipairs(opts) do
        local ob = Instance.new("TextButton")
        ob.Size = UDim2.new(1,0,0,22)
        ob.BackgroundTransparency = 0.95
        ob.Text = "  " .. o
        ob.TextColor3 = colors.text
        ob.TextXAlignment = Enum.TextXAlignment.Left
        ob.Font = Enum.Font.Gotham
        ob.TextSize = 11
        ob.Parent = list
        ob.MouseButton1Click:Connect(function()
            sel.Text = o
            open = false
            list.Visible = false
            r.ClipsDescendants = true
            r.Size = UDim2.new(1,0,0,28)
            cb(o)
        end)
    end

    local tbtn = Instance.new("TextButton")
    tbtn.Size = UDim2.new(0,80,0,20)
    tbtn.Position = UDim2.new(1,-90,0,4)
    tbtn.BackgroundTransparency = 1
    tbtn.Text = ""
    tbtn.Parent = r
    tbtn.MouseButton1Click:Connect(function()
        open = not open
        list.Visible = open
        r.ClipsDescendants = not open
        r.Size = open and UDim2.new(1,0,0,32+#opts*22+4) or UDim2.new(1,0,0,28)
    end)
end

local function label(parent, txt, col, size)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1,0,0,size or 20)
    l.BackgroundTransparency = 1
    l.Text = txt
    l.TextColor3 = col or colors.text
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Font = Enum.Font.Gotham
    l.TextSize = 11
    l.Parent = parent
    return l
end

-- tabs
local tabs = {
    {n="Aim"}, {n="ESP"}, {n="Move"}, {n="Cos"}, {n="Info"}
}
local pageMap = {}
local tabBtnMap = {}
local current

local function selectTab(idx)
    for i,t in pairs(tabs) do
        pageMap[i].Visible = (i == idx)
        tabBtnMap[i].BackgroundTransparency = (i == idx) and 0.82 or 0.93
        tabBtnMap[i].TextColor3 = (i == idx) and colors.accent or colors.text
    end
    current = idx
end

for i,t in ipairs(tabs) do
    tabBtnMap[i] = tab(t.n)
    pageMap[i] = page(t.n)
    tabBtnMap[i].MouseButton1Click:Connect(function() selectTab(i) end)
end
selectTab(1)

-- AIM
local pAim = pageMap[1]
toggle(pAim, "Silent Aim", false, function(v) S.aim.on = v end)
dropdown(pAim, "Method",
    {"Raycast","FindPartOnRayWithWhitelist","FindPartOnRayWithIgnoreList","Mouse.Hit"},
    "Raycast", function(v) S.aim.method = v end)
dropdown(pAim, "Target Part",
    {"Head","Torso","LeftLeg","RightLeg","LeftArm","RightArm","HumanoidRootPart","Random"},
    "Head", function(v) S.aim.part = v end)
slider(pAim, "Hitchance", 0, 100, 100, function(v) S.aim.hitchance = v end)

-- ESP
local pEsp = pageMap[2]
toggle(pEsp, "ESP Enabled", false, function(v) S.esp.on = v end)
toggle(pEsp, "Highlight", true, function(v) S.esp.hl = v end)
toggle(pEsp, "Name", true, function(v) S.esp.name = v end)
toggle(pEsp, "Health Bar", true, function(v) S.esp.hp = v end)
toggle(pEsp, "Trace", false, function(v) S.esp.trace = v end)
toggle(pEsp, "Box", true, function(v) S.esp.box = v end)
slider(pEsp, "Max Studs", 0, 5000, 5000, function(v) S.esp.studs = v end)

-- MOVE
local pMv = pageMap[3]
toggle(pMv, "Noclip", false, function(v) S.mv.noclip = v end)
toggle(pMv, "Speed", false, function(v) S.mv.speed = v end)
slider(pMv, "Speed Value", 16, 200, 16, function(v) S.mv.spd = v end)
toggle(pMv, "Jump Power", false, function(v) S.mv.jump = v end)
slider(pMv, "Jump Value", 50, 300, 50, function(v) S.mv.jmp = v end)
toggle(pMv, "Fly", false, function(v) S.mv.fly = v end)
toggle(pMv, "Vehicle Fly", false, function(v) S.mv.vfly = v end)

-- COSMETICS
local pCos = pageMap[4]
toggle(pCos, "Headless", false, function(v) S.cos.headless = v end)
toggle(pCos, "Korblox", false, function(v) S.cos.korblox = v end)
label(pCos, "Headless mesh id: 13408400623 (rbxassetid)", colors.dim, 18)
label(pCos, "Korblox leg mesh id: 13233044306 (rbxassetid)", colors.dim, 18)
label(pCos, "attach via Humanoid Description / accessory", colors.dim, 18)

-- INFO
local pInfo = pageMap[5]
label(pInfo, "platform: " .. platform, colors.accent, 18)
label(pInfo, "otg: " .. (hasOTG and "yes" or "no"), colors.dim, 16)
label(pInfo, "changelog:", colors.accent, 18)
label(pInfo, "v0.1 - initial build", colors.dim, 16)
label(pInfo, "v0.2 - esp options added", colors.dim, 16)
label(pInfo, "v0.3 - mobile scaling + otg", colors.dim, 16)
label(pInfo, "profile: ollie", colors.accent, 18)
label(pInfo, "user: " .. lp.Name, colors.dim, 16)
label(pInfo, "id: " .. lp.UserId, colors.dim, 16)

-- ============================================================
-- cheat logic
-- ============================================================

local function pickTarget()
    local best, bestD
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr ~= lp and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = plr.Character.HumanoidRootPart
            local d = (hrp.Position - cam.CFrame.Position).Magnitude
            if d < S.esp.studs and (not bestD or d < bestD) then
                best, bestD = plr, d
            end
        end
    end
    return best
end

local function getPart(plr)
    if not plr or not plr.Character then return nil end
    local want = S.aim.part
    if want == "Random" then
        local parts = {"Head","Torso","LeftLeg","RightLeg","LeftArm","RightArm","HumanoidRootPart"}
        want = parts[math.random(1,#parts)]
    end
    if want == "Torso" then
        return plr.Character:FindFirstChild("Torso")
            or plr.Character:FindFirstChild("UpperTorso")
    end
    return plr.Character:FindFirstChild(want)
end

RunService.RenderStepped:Connect(function()
    if not S.aim.on then return end
    if math.random(1,100) > S.aim.hitchance then return end

    local t = pickTarget()
    if not t then return end
    local part = getPart(t)
    if not part then return end

    local origin = cam.CFrame.Position
    local dir = (part.Position - origin).Unit * 5000

    if S.aim.method == "Raycast" then
        local rp = RaycastParams.new()
        rp.FilterType = Enum.RaycastFilterType.Exclude
        rp.FilterDescendantsInstances = {lp.Character}
        local res = workspace:Raycast(origin, dir, rp)
        if res then
            cam.CFrame = CFrame.new(origin, res.Position)
        end
    elseif S.aim.method == "FindPartOnRayWithWhitelist" then
        local ray = Ray.new(origin, dir)
        local hit = workspace:FindPartOnRayWithWhitelist(ray, {t.Character})
        if hit then cam.CFrame = CFrame.new(origin, hit.Position) end
    elseif S.aim.method == "FindPartOnRayWithIgnoreList" then
        local ray = Ray.new(origin, dir)
        local hit = workspace:FindPartOnRayWithIgnoreList(ray, {lp.Character})
        if hit then cam.CFrame = CFrame.new(origin, hit.Position) end
    elseif S.aim.method == "Mouse.Hit" then
        cam.CFrame = CFrame.new(origin, part.Position)
    end
end)

-- ESP via highlight only (box/trace/name/hp via billboard gui)
local espFolder = Instance.new("Folder")
espFolder.Name = "ollie_esp"
espFolder.Parent = gui

local espCache = {}

local function clearESP(plr)
    if espCache[plr] then
        for _,o in ipairs(espCache[plr]) do
            if o and o.Parent then o:Destroy() end
        end
        espCache[plr] = nil
    end
end

local function buildESP(plr)
    clearESP(plr)
    if not plr.Character then return end
    local parts = {}
    if S.esp.hl then
        local h = Instance.new("Highlight")
        h.FillColor = colors.accent
        h.OutlineColor = Color3.fromRGB(255,255,255)
        h.FillTransparency = 0.6
        h.Parent = plr.Character
        table.insert(parts, h)
    end
    if S.esp.box or S.esp.name or S.esp.hp or S.esp.trace then
        local bb = Instance.new("BillboardGui")
        bb.Adornee = plr.Character:FindFirstChild("HumanoidRootPart")
        bb.Size = UDim2.new(0,100,0,120)
        bb.StudsOffset = Vector3.new(0,3,0)
        bb.AlwaysOnTop = true
        bb.Parent = plr.Character

        if S.esp.box then
            local b = Instance.new("Frame")
            b.Size = UDim2.new(1,0,1,0)
            b.BackgroundTransparency = 1
            b.BorderSizePixel = 2
            b.BorderColor3 = colors.accent
            b.Parent = bb
        end

        if S.esp.name then
            local n = Instance.new("TextLabel")
            n.Size = UDim2.new(1,0,0,16)
            n.Position = UDim2.new(0,0,0,-18)
            n.BackgroundTransparency = 1
            n.Text = plr.Name
            n.TextColor3 = Color3.fromRGB(255,255,255)
            n.TextStrokeTransparency = 0.3
            n.Font = Enum.Font.GothamBold
            n.TextSize = 12
            n.Parent = bb
        end

        if S.esp.hp then
            local hp = Instance.new("Frame")
            hp.Size = UDim2.new(0,4,1,0)
            hp.Position = UDim2.new(-1,-4,0,0)
            hp.BackgroundColor3 = Color3.fromRGB(0,200,80)
            hp.BorderSizePixel = 0
            hp.Parent = bb
            local h = plr.Character:FindFirstChildOfClass("Humanoid")
            if h then
                hp.Size = UDim2.new(0,4,h.Health/h.MaxHealth,0)
            end
        end

        table.insert(parts, bb)
    end
    espCache[plr] = parts
end

Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function()
        task.wait(0.5)
        if S.esp.on then buildESP(p) end
    end)
end)

Players.PlayerRemoving:Connect(function(p) clearESP(p) end)

task.spawn(function()
    while gui.Parent do
        if S.esp.on then
            for _,p in ipairs(Players:GetPlayers()) do
                if p ~= lp and p.Character then
                    if not espCache[p] then buildESP(p) end
                    -- distance cull
                    local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                    if hrp and espCache[p] then
                        local d = (hrp.Position - cam.CFrame.Position).Magnitude
                        for _,o in ipairs(espCache[p]) do
                            if o:IsA("Highlight") or o:IsA("BillboardGui") then
                                o.Enabled = d <= S.esp.studs
                            end
                        end
                    end
                end
            end
        else
            for p,_ in pairs(espCache) do clearESP(p) end
        end
        task.wait(0.5)
    end
end)

-- MOVE handlers
RunService.Heartbeat:Connect(function()
    if not lp.Character then return end
    local h = lp.Character:FindFirstChildOfClass("Humanoid")
    if not h then return end

    if S.mv.noclip then
        for _,v in ipairs(lp.Character:GetDescendants()) do
            if v:IsA("BasePart") and v.CanCollide then
                v.CanCollide = false
            end
        end
    end

    if S.mv.speed then
        h.WalkSpeed = S.mv.spd
    else
        h.WalkSpeed = 16
    end

    if S.mv.jump then
        h.UseJumpPower = true
        h.JumpPower = S.mv.jmp
    end

    if S.mv.fly then
        local hrp = lp.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local move = Vector3.zero
            if UIS:IsKeyDown(Enum.KeyCode.W) then move += cam.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.S) then move -= cam.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.A) then move -= cam.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.D) then move += cam.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0,1,0) end
            if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then move -= Vector3.new(0,1,0) end
            if move.Magnitude > 0 then
                hrp.CFrame = hrp.CFrame + move.Unit * S.mv.spd * 0.1
            end
        end
    end

    if S.mv.vfly then
        local seat = lp.Character:FindFirstChildOfClass("Humanoid").SeatPart
        if seat then
            local move = Vector3.zero
            if UIS:IsKeyDown(Enum.KeyCode.W) then move += cam.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.S) then move -= cam.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.A) then move -= cam.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.D) then move += cam.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0,1,0) end
            if move.Magnitude > 0 then
                seat.Velocity = move.Unit * 50
            end
        end
    end
end)

-- COSMETICS
local function applyHeadless(on)
    local h = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
    if not h then return end
    local desc = h:FindFirstChildOfClass("HumanoidDescription")
    if not desc then return end
    desc.Head = on and 13408400623 or 0
end

local function applyKorblox(on)
    local h = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
    if not h then return end
    local desc = h:FindFirstChildOfClass("HumanoidDescription")
    if not desc then return end
    desc.RightLeg = on and 13233044306 or 0
end

task.spawn(function()
    while gui.Parent do
        if S.cos.headless then applyHeadless(true) end
        if S.cos.korblox then applyKorblox(true) end
        task.wait(2)
    end
end)

print("[ollie] loaded on " .. platform)
