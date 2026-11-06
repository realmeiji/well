--!nocheck
-- Project Iris — Combined build
-- ESP + Aimbot + Silent Aim + Cosmetics
--
-- Usage: execute in a Roblox exploit environment (Linoria-dependent).

-- ============================================================================
-- SERVICES & BOOTSTRAP
-- ============================================================================

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local InsertService    = game:GetService("InsertService")
local Camera           = workspace.CurrentCamera
local LocalPlayer      = Players.LocalPlayer
local Mouse            = LocalPlayer:GetMouse()

local repo = "https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/"

local Library      = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager  = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

-- ============================================================================
-- SHARED STATE
-- ============================================================================

local State = {
    -- Silent Aim
    SilentAimEnabled   = false,
    SilentFOVEnabled   = true,
    SilentFOVRadius    = 120,
    SilentFOVVisible   = true,
    SilentHitChance    = 100,
    SilentTargetPart   = "Head",
    SilentPriority     = "Closest to Cursor",
    SilentSticky       = false,
    SilentTeamCheck    = true,
    SilentVisCheck     = false,
    SilentIndicator    = true,
    SilentMethod       = "Raycast",
    SilentDynamicFOV   = false,
    SilentFOVColor     = Color3.fromRGB(255, 255, 255),
    SilentFOVThickness = 1,
    SilentFOVTransparency = 0,
    SilentFOVFilled    = false,
    SilentShowName     = true,
    SilentTarget       = nil,

    -- Aimbot
    AimbotEnabled      = false,
    AimbotTargetPart   = "Head",
    AimbotPriority     = "Closest to Cursor",
    AimbotSticky       = false,
    AimbotSwitching    = false,
    AimbotMaxDist      = 500,
    AimbotFOVEnabled   = true,
    AimbotFOVRadius    = 150,
    AimbotFOVThickness = 1,
    AimbotFOVColor     = Color3.fromRGB(255, 255, 255),
    AimbotFOVTransp    = 0.5,
    AimbotDynamicFOV   = false,
    AimbotFilledFOV    = false,
    AimbotTeamCheck    = true,
    AimbotVisCheck     = false,
    AimbotAliveCheck   = true,
    AimbotKnockedCheck = false,
    AimbotFriendCheck  = false,
    AimbotHighlight    = true,
    AimbotIndicator    = true,
    AimbotShowName     = true,
    AimbotShowDist     = true,
    AimbotLockStatus   = true,
    AimbotTarget       = nil,

    -- Cosmetics
    HeadlessEnabled    = false,
    KorbloxEnabled     = false,

    -- ESP
    ESPEnabled         = false,
    ESPBox             = true,
    ESPName            = true,
    ESPHealthBar       = true,
    ESPHealthText      = false,
    ESPHealthPct       = false,
    ESPHealthColor     = Color3.fromRGB(0, 255, 100),
    ESPGradientHealth  = false,
    ESPHealthOutline   = true,
    ESPDistance        = true,
    ESPDistUnit        = "Studs",
    ESPMaxDist         = 1000,
    ESPDistColor       = Color3.fromRGB(220, 220, 220),
    ESPTracers         = false,
    ESPTracerOrigin    = "Bottom",
    ESPTracerColor     = Color3.fromRGB(255, 255, 255),
    ESPTracerThickness = 1,
    ESPTracerTransp    = 0.4,
    ESPItemESP         = false,
    ESPWeaponESP       = false,
    ESPDroppedItem     = false,
    ESPObjective       = false,
    ESPNPC             = false,
    ESPVehicle         = false,
    ESPFont            = Drawing.Fonts.GothamBold,
    ESPTextSize        = 11,
    ESPOutline         = true,
    ESPRainbow         = false,
    ESPTeamColors      = false,
}

-- ============================================================================
-- WINDOW & TABS
-- ============================================================================

local Window = Library:CreateWindow({
    Title        = "Project Iris",
    Center       = true,
    AutoShow     = true,
    TabPadding   = 8,
    MenuFadeTime = 0.2,
})

local Tabs = {
    SilentAim = Window:AddTab("Silent Aim"),
    Aimbot    = Window:AddTab("Aimbot"),
    Visual    = Window:AddTab("Visuals"),
    ESP       = Window:AddTab("ESP"),
    Config    = Window:AddTab("Config"),
}

-- ============================================================================
-- MODULE: SILENT AIM
-- ============================================================================

do
    local Tab = Tabs.SilentAim

    local function getCharacter(player) return player and player.Character end
    local function getHumanoid(character)
        return character and character:FindFirstChildOfClass("Humanoid")
    end
    local function isAlive(player)
        local char = getCharacter(player)
        if not char then return false end
        local hum = getHumanoid(char)
        return hum and hum.Health > 0
    end
    local function isTeammate(player)
        return player.Team ~= nil and player.Team == LocalPlayer.Team
    end
    local function isVisible(character, targetPart)
        local part = character:FindFirstChild(targetPart)
        if not part then return false end
        local origin    = Camera.CFrame.Position
        local direction = (part.Position - origin)
        local ray       = Ray.new(origin, direction)
        local ignoreList = { LocalPlayer.Character, Camera }
        local hit = workspace:FindPartOnRayWithIgnoreList(ray, ignoreList)
        return hit and hit:IsDescendantOf(character)
    end
    local function getPartPosition(character, partName)
        if partName == "Random Part" then
            local parts = { "Head", "Torso", "HumanoidRootPart", "UpperTorso", "LowerTorso" }
            local valid = {}
            for _, p in ipairs(parts) do
                if character:FindFirstChild(p) then table.insert(valid, p) end
            end
            if #valid > 0 then partName = valid[math.random(#valid)] end
        end
        local part = character:FindFirstChild(partName)
        return part and part.Position
    end
    local function screenDistFromMouse(character, partName)
        local pos = getPartPosition(character, partName)
        if not pos then return math.huge end
        local screenPos, onScreen = Camera:WorldToViewportPoint(pos)
        if not onScreen then return math.huge end
        local dx = screenPos.X - Mouse.X
        local dy = screenPos.Y - Mouse.Y
        return math.sqrt(dx * dx + dy * dy)
    end
    local function distFromCenter(character, partName)
        local pos = getPartPosition(character, partName)
        if not pos then return math.huge end
        local vp = Camera.ViewportSize
        local screenPos, onScreen = Camera:WorldToViewportPoint(pos)
        if not onScreen then return math.huge end
        local dx = screenPos.X - vp.X / 2
        local dy = screenPos.Y - vp.Y / 2
        return math.sqrt(dx * dx + dy * dy)
    end
    local function getTarget()
        local best, bestDist = nil, math.huge
        for _, player in ipairs(Players:GetPlayers()) do
            if player == LocalPlayer then continue end
            if State.SilentTeamCheck and isTeammate(player) then continue end
            if not isAlive(player) then continue end
            local char = getCharacter(player)
            if not char then continue end
            if State.SilentVisCheck and not isVisible(char, State.SilentTargetPart) then continue end
            local d = (State.SilentPriority == "Closest to Cursor")
                and screenDistFromMouse(char, State.SilentTargetPart)
                or  distFromCenter(char, State.SilentTargetPart)
            if State.SilentFOVEnabled and d > State.SilentFOVRadius then continue end
            if d < bestDist then bestDist = d; best = player end
        end
        return best
    end

    -- Drawings
    local fovCircle = Drawing.new("Circle")
    fovCircle.Color        = State.SilentFOVColor
    fovCircle.Radius       = State.SilentFOVRadius
    fovCircle.Thickness    = State.SilentFOVThickness
    fovCircle.Transparency = 1
    fovCircle.Filled       = false
    fovCircle.Visible      = false
    fovCircle.NumSides     = 64

    local targetIndicator = Drawing.new("Circle")
    targetIndicator.Color     = Color3.fromRGB(255, 80, 80)
    targetIndicator.Radius    = 5
    targetIndicator.Thickness = 2
    targetIndicator.Filled    = true
    targetIndicator.Visible   = false
    targetIndicator.NumSides  = 16

    local targetLabel = Drawing.new("Text")
    targetLabel.Color    = Color3.fromRGB(255, 255, 255)
    targetLabel.Size     = 13
    targetLabel.Font     = Drawing.Fonts.GothamBold
    targetLabel.Center   = true
    targetLabel.Outline  = true
    targetLabel.Visible  = false

    -- Hooks
    local mt          = getrawmetatable(game)
    local oldIndex    = mt.__index
    setreadonly(mt, false)

    local function getHitPosition()
        if not State.SilentAimEnabled then return nil end
        if math.random(1, 100) > State.SilentHitChance then return nil end
        local target = State.SilentSticky and State.SilentTarget or getTarget()
        State.SilentTarget = target
        if not target then return nil end
        local char = getCharacter(target)
        if not char then return nil end
        return getPartPosition(char, State.SilentTargetPart)
    end

    mt.__index = newcclosure(function(self, key)
        if State.SilentAimEnabled and State.SilentMethod == "Mouse.Hit/Target" then
            if self == Mouse then
                local pos = getHitPosition()
                if pos then
                    if key == "Hit" then return CFrame.new(pos) end
                    if key == "Target" then
                        local target = State.SilentTarget
                        if target then
                            local char = getCharacter(target)
                            return char and char:FindFirstChild(State.SilentTargetPart) or rawget(self, key)
                        end
                    end
                end
            end
        end
        return oldIndex(self, key)
    end)

    local oldRaycast  = workspace.Raycast
    workspace.Raycast = newcclosure(function(ws, origin, direction, params)
        if State.SilentAimEnabled and State.SilentMethod == "Raycast" then
            local pos = getHitPosition()
            if pos then direction = (pos - origin).Unit * direction.Magnitude end
        end
        return oldRaycast(ws, origin, direction, params)
    end)

    local oldWhitelist = workspace.FindPartOnRayWithWhitelist
    workspace.FindPartOnRayWithWhitelist = newcclosure(function(ws, ray, whitelist, ignoreWater)
        if State.SilentAimEnabled and State.SilentMethod == "FindPartOnRayWithWhitelist" then
            local pos = getHitPosition()
            if pos then ray = Ray.new(ray.Origin, (pos - ray.Origin).Unit * ray.Direction.Magnitude) end
        end
        return oldWhitelist(ws, ray, whitelist, ignoreWater)
    end)

    local oldIgnore = workspace.FindPartOnRayWithIgnoreList
    workspace.FindPartOnRayWithIgnoreList = newcclosure(function(ws, ray, ignoreList, ignoreWater)
        if State.SilentAimEnabled and State.SilentMethod == "FindPartOnRayWithIgnoreList" then
            local pos = getHitPosition()
            if pos then ray = Ray.new(ray.Origin, (pos - ray.Origin).Unit * ray.Direction.Magnitude) end
        end
        return oldIgnore(ws, ray, ignoreList, ignoreWater)
    end)

    setreadonly(mt, true)

    local renderConn = RunService.RenderStepped:Connect(function()
        local showFOV = State.SilentFOVEnabled and State.SilentFOVVisible and State.SilentAimEnabled
        fovCircle.Visible      = showFOV
        fovCircle.Position     = Vector2.new(Mouse.X, Mouse.Y)
        fovCircle.Radius       = State.SilentDynamicFOV
            and State.SilentFOVRadius * (Camera.FieldOfView / 70)
            or  State.SilentFOVRadius
        fovCircle.Color        = State.SilentFOVColor
        fovCircle.Thickness    = State.SilentFOVThickness
        fovCircle.Transparency = 1 - State.SilentFOVTransparency
        fovCircle.Filled       = State.SilentFOVFilled

        local target = State.SilentAimEnabled and State.SilentTarget
        if target and State.SilentIndicator then
            local char = getCharacter(target)
            if char then
                local pos = getPartPosition(char, State.SilentTargetPart)
                if pos then
                    local sp, onscreen = Camera:WorldToViewportPoint(pos)
                    targetIndicator.Visible  = onscreen
                    targetIndicator.Position = Vector2.new(sp.X, sp.Y)
                    if State.SilentShowName then
                        targetLabel.Visible  = onscreen
                        targetLabel.Position = Vector2.new(sp.X, sp.Y - 16)
                        local dist = math.floor((Camera.CFrame.Position - pos).Magnitude)
                        targetLabel.Text = target.DisplayName .. " [" .. dist .. "]"
                    else
                        targetLabel.Visible = false
                    end
                else
                    targetIndicator.Visible = false
                    targetLabel.Visible = false
                end
            end
        else
            targetIndicator.Visible = false
            targetLabel.Visible = false
        end

        if not State.SilentSticky then State.SilentTarget = getTarget() end
    end)

    -- UI
    local GroupMain    = Tab:AddLeftGroupbox("Silent Aim")
    local GroupFOV     = Tab:AddLeftGroupbox("FOV Settings")
    local GroupVisuals = Tab:AddRightGroupbox("Visuals")
    local GroupAdv     = Tab:AddRightGroupbox("Advanced")

    GroupMain:AddToggle("SilentEnabled", {
        Text = "Silent Aim Enabled", Default = false,
        Tooltip = "Silently redirect your shots toward the target part",
    }):OnChanged(function(v) State.SilentAimEnabled = v end)

    GroupMain:AddDropdown("SilentMethod", {
        Text = "Method",
        Values = { "Raycast", "FindPartOnRayWithWhitelist", "FindPartOnRayWithIgnoreList", "Mouse.Hit/Target" },
        Default = "Raycast",
    }):OnChanged(function(v) State.SilentMethod = v end)

    GroupMain:AddDropdown("SilentTargetPart", {
        Text = "Target Part",
        Values = { "Head", "Torso", "HumanoidRootPart", "UpperTorso", "LowerTorso", "Random Part" },
        Default = "Head",
    }):OnChanged(function(v) State.SilentTargetPart = v end)

    GroupMain:AddDropdown("SilentPriority", {
        Text = "Target Priority",
        Values = { "Closest to Cursor", "Closest to Center" },
        Default = "Closest to Cursor",
    }):OnChanged(function(v) State.SilentPriority = v end)

    GroupMain:AddSlider("SilentHitChance", {
        Text = "Hit Chance", Min = 1, Max = 100, Default = 100, Suffix = "%",
    }):OnChanged(function(v) State.SilentHitChance = v end)

    GroupMain:AddToggle("SilentSticky", {
        Text = "Sticky Target", Default = false,
    }):OnChanged(function(v)
        State.SilentSticky = v
        if not v then State.SilentTarget = nil end
    end)

    GroupMain:AddToggle("SilentTeamCheck", {
        Text = "Team Check", Default = true,
    }):OnChanged(function(v) State.SilentTeamCheck = v end)

    GroupMain:AddToggle("SilentVisCheck", {
        Text = "Visibility Check", Default = false,
    }):OnChanged(function(v) State.SilentVisCheck = v end)

    GroupFOV:AddToggle("SilentFOVEnabled", {
        Text = "FOV Enabled", Default = true,
    }):OnChanged(function(v) State.SilentFOVEnabled = v end)

    GroupFOV:AddToggle("SilentFOVVisible", {
        Text = "Show FOV Circle", Default = true,
    }):OnChanged(function(v) State.SilentFOVVisible = v end)

    GroupFOV:AddSlider("SilentFOVRadius", {
        Text = "FOV Radius", Min = 10, Max = 500, Default = 120, Suffix = "px",
    }):OnChanged(function(v) State.SilentFOVRadius = v end)

    GroupVisuals:AddToggle("SilentIndicator", {
        Text = "Target Indicator", Default = true,
    }):OnChanged(function(v) State.SilentIndicator = v end)

    GroupVisuals:AddToggle("SilentShowName", {
        Text = "Target Name + Distance", Default = true,
    }):OnChanged(function(v) State.SilentShowName = v end)

    GroupVisuals:AddColorPicker("SilentFOVColor", {
        Text = "FOV Color", Default = Color3.fromRGB(255, 255, 255),
    }):OnChanged(function(v) State.SilentFOVColor = v end)

    GroupVisuals:AddSlider("SilentFOVThickness", {
        Text = "FOV Thickness", Min = 1, Max = 5, Default = 1,
    }):OnChanged(function(v) State.SilentFOVThickness = v end)

    GroupVisuals:AddSlider("SilentFOVTransparency", {
        Text = "FOV Transparency", Min = 0, Max = 1, Default = 0,
    }):OnChanged(function(v) State.SilentFOVTransparency = v end)

    GroupVisuals:AddToggle("SilentFOVFilled", {
        Text = "FOV Filled", Default = false,
    }):OnChanged(function(v) State.SilentFOVFilled = v end)

    GroupAdv:AddToggle("SilentDynamicFOV", {
        Text = "Dynamic FOV", Default = false,
    }):OnChanged(function(v) State.SilentDynamicFOV = v end)

    GroupAdv:AddKeybind("SilentKeybind", {
        Text = "Toggle Silent Aim",
        Default = Enum.KeyCode.F,
        Callback = function()
            State.SilentAimEnabled = not State.SilentAimEnabled
            if Toggles.SilentEnabled then Toggles.SilentEnabled:SetValue(State.SilentAimEnabled) end
        end,
    })

    Library:OnUnload(function()
        renderConn:Disconnect()
        fovCircle:Remove(); targetIndicator:Remove(); targetLabel:Remove()
        setreadonly(mt, false)
        mt.__index = oldIndex
        workspace.Raycast = oldRaycast
        workspace.FindPartOnRayWithWhitelist = oldWhitelist
        workspace.FindPartOnRayWithIgnoreList = oldIgnore
        setreadonly(mt, true)
    end)
end

-- ============================================================================
-- MODULE: AIMBOT
-- ============================================================================

do
    local Tab = Tabs.Aimbot

    local function getCharacter(player) return player and player.Character end
    local function getHumanoid(character)
        return character and character:FindFirstChildOfClass("Humanoid")
    end
    local function isAlive(player)
        local char = getCharacter(player)
        if not char then return false end
        local hum = getHumanoid(char)
        return hum and hum.Health > 0
    end
    local function isKnocked(player)
        local char = getCharacter(player)
        if not char then return true end
        local hum = getHumanoid(char)
        return hum and hum.Health <= 0
    end
    local function isTeammate(player)
        return player.Team ~= nil and player.Team == LocalPlayer.Team
    end
    local function isFriend(player)
        local ok, res = pcall(function() return LocalPlayer:IsFriendsWith(player.UserId) end)
        return ok and res
    end
    local function isVisible(character, partName)
        local part = character:FindFirstChild(partName)
        if not part then return false end
        local origin    = Camera.CFrame.Position
        local direction = part.Position - origin
        local ray       = Ray.new(origin, direction)
        local hit = workspace:FindPartOnRayWithIgnoreList(ray, { LocalPlayer.Character })
        return hit and hit:IsDescendantOf(character)
    end
    local function getPartPos(character, partName)
        local part = character:FindFirstChild(partName)
        return part and part.Position
    end
    local function screenDist(worldPos, cx, cy)
        local sp, onScreen = Camera:WorldToViewportPoint(worldPos)
        if not onScreen then return math.huge end
        local dx = sp.X - cx
        local dy = sp.Y - cy
        return math.sqrt(dx * dx + dy * dy), sp
    end
    local function getTarget()
        local vp = Camera.ViewportSize
        local cx, cy = vp.X / 2, vp.Y / 2
        if State.AimbotPriority == "Closest to Cursor" then cx, cy = Mouse.X, Mouse.Y end

        local best, bestDist, bestScreenPos = nil, math.huge, nil
        for _, player in ipairs(Players:GetPlayers()) do
            if player == LocalPlayer then continue end
            if State.AimbotTeamCheck   and isTeammate(player) then continue end
            if State.AimbotFriendCheck and isFriend(player)   then continue end
            if State.AimbotAliveCheck  and not isAlive(player) then continue end
            if State.AimbotKnockedCheck and isKnocked(player)  then continue end

            local char = getCharacter(player)
            if not char then continue end
            local pos = getPartPos(char, State.AimbotTargetPart)
            if not pos then continue end

            local worldDist = (Camera.CFrame.Position - pos).Magnitude
            if worldDist > State.AimbotMaxDist then continue end
            if State.AimbotVisCheck and not isVisible(char, State.AimbotTargetPart) then continue end

            local d, sp = screenDist(pos, cx, cy)
            if State.AimbotFOVEnabled then
                local fovRadius = State.AimbotDynamicFOV
                    and State.AimbotFOVRadius * (Camera.FieldOfView / 70)
                    or  State.AimbotFOVRadius
                if d > fovRadius then continue end
            end
            if d < bestDist then bestDist = d; best = player; bestScreenPos = sp end
        end
        return best, bestScreenPos
    end

    -- Drawings
    local fovCircle = Drawing.new("Circle")
    fovCircle.Radius       = State.AimbotFOVRadius
    fovCircle.Thickness    = 1
    fovCircle.Color        = State.AimbotFOVColor
    fovCircle.Transparency = 1
    fovCircle.Filled       = false
    fovCircle.Visible      = false
    fovCircle.NumSides     = 64

    local lockLine = Drawing.new("Line")
    lockLine.Color = Color3.fromRGB(255, 80, 80)
    lockLine.Thickness = 1
    lockLine.Transparency = 1
    lockLine.Visible = false

    local lockLabel = Drawing.new("Text")
    lockLabel.Color = Color3.fromRGB(255, 255, 255)
    lockLabel.Size = 12
    lockLabel.Font = Drawing.Fonts.GothamBold
    lockLabel.Center = true
    lockLabel.Outline = true
    lockLabel.Visible = false

    local holding = false
    local inputBegan = UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.UserInputType == Enum.UserInputType.MouseButton2 then holding = true end
    end)
    local inputEnded = UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton2 then
            holding = false
            if not State.AimbotSticky then State.AimbotTarget = nil end
        end
    end)

    local renderConn = RunService.RenderStepped:Connect(function(dt)
        local vp = Camera.ViewportSize
        local fovX, fovY = vp.X / 2, vp.Y / 2
        if State.AimbotPriority == "Closest to Cursor" then fovX, fovY = Mouse.X, Mouse.Y end

        local showFov = State.AimbotFOVEnabled and State.AimbotEnabled
        fovCircle.Visible      = showFov
        fovCircle.Position     = Vector2.new(fovX, fovY)
        fovCircle.Color        = State.AimbotFOVColor
        fovCircle.Thickness    = State.AimbotFOVThickness
        fovCircle.Transparency = 1 - State.AimbotFOVTransp
        fovCircle.Filled       = State.AimbotFilledFOV
        fovCircle.Radius       = State.AimbotDynamicFOV
            and State.AimbotFOVRadius * (Camera.FieldOfView / 70)
            or  State.AimbotFOVRadius

        if not (State.AimbotEnabled and holding) then
            State.AimbotTarget = nil
            lockLine.Visible = false
            lockLabel.Visible = false
            return
        end

        if not State.AimbotSticky or not State.AimbotTarget or not isAlive(State.AimbotTarget) then
            State.AimbotTarget = getTarget()
        elseif State.AimbotSwitching then
            local newTarget = getTarget()
            if newTarget and newTarget ~= State.AimbotTarget then State.AimbotTarget = newTarget end
        end

        local target = State.AimbotTarget
        if not target then lockLine.Visible = false; lockLabel.Visible = false; return end

        local char = getCharacter(target)
        if not char then return end
        local pos = getPartPos(char, State.AimbotTargetPart)
        if not pos then return end

        local targetCF = CFrame.new(Camera.CFrame.Position, pos)
        Camera.CFrame = Camera.CFrame:Lerp(targetCF, math.min(1, dt * 60))

        local sp, onscreen = Camera:WorldToViewportPoint(pos)

        if State.AimbotIndicator and onscreen then
            lockLine.Visible = true
            lockLine.From = Vector2.new(vp.X / 2, vp.Y)
            lockLine.To   = Vector2.new(sp.X, sp.Y)
        else
            lockLine.Visible = false
        end

        if State.AimbotLockStatus and onscreen then
            lockLabel.Visible  = true
            lockLabel.Position = Vector2.new(sp.X, sp.Y - 20)
            local dist = math.floor((Camera.CFrame.Position - pos).Magnitude)
            local info = {}
            if State.AimbotShowName then table.insert(info, target.DisplayName) end
            if State.AimbotShowDist then table.insert(info, dist .. " studs") end
            lockLabel.Text = table.concat(info, " | ")
        else
            lockLabel.Visible = false
        end
    end)

    -- UI
    local GroupMain    = Tab:AddLeftGroupbox("Aimbot")
    local GroupFOV     = Tab:AddLeftGroupbox("FOV")
    local GroupChecks  = Tab:AddRightGroupbox("Checks")
    local GroupVisuals = Tab:AddRightGroupbox("Visuals")

    GroupMain:AddToggle("AimbotEnabled", {
        Text = "Aimbot Enabled", Default = false,
        Tooltip = "Hold right-click to lock onto target",
    }):OnChanged(function(v) State.AimbotEnabled = v end)

    GroupMain:AddDropdown("AimbotTargetPart", {
        Text = "Target Part",
        Values = { "Head", "Torso", "HumanoidRootPart", "UpperTorso", "LowerTorso" },
        Default = "Head",
    }):OnChanged(function(v) State.AimbotTargetPart = v end)

    GroupMain:AddDropdown("AimbotPriority", {
        Text = "Target Priority",
        Values = { "Closest to Cursor", "Closest to Center" },
        Default = "Closest to Cursor",
    }):OnChanged(function(v) State.AimbotPriority = v end)

    GroupMain:AddToggle("AimbotSticky", {
        Text = "Sticky Target", Default = false,
    }):OnChanged(function(v)
        State.AimbotSticky = v
        if not v then State.AimbotTarget = nil end
    end)

    GroupMain:AddToggle("AimbotSwitching", {
        Text = "Target Switching", Default = false,
    }):OnChanged(function(v) State.AimbotSwitching = v end)

    GroupMain:AddSlider("AimbotMaxDist", {
        Text = "Maximum Distance", Min = 50, Max = 2000, Default = 500, Suffix = " studs",
    }):OnChanged(function(v) State.AimbotMaxDist = v end)

    GroupFOV:AddToggle("AimbotFOVEnabled", {
        Text = "FOV Enabled", Default = true,
    }):OnChanged(function(v) State.AimbotFOVEnabled = v end)

    GroupFOV:AddSlider("AimbotFOVRadius", {
        Text = "FOV Radius", Min = 10, Max = 600, Default = 150, Suffix = "px",
    }):OnChanged(function(v) State.AimbotFOVRadius = v end)

    GroupFOV:AddSlider("AimbotFOVThickness", {
        Text = "Thickness", Min = 1, Max = 5, Default = 1,
    }):OnChanged(function(v) State.AimbotFOVThickness = v end)

    GroupFOV:AddColorPicker("AimbotFOVColor", {
        Text = "FOV Color", Default = Color3.fromRGB(255, 255, 255),
    }):OnChanged(function(v) State.AimbotFOVColor = v end)

    GroupFOV:AddSlider("AimbotFOVTransp", {
        Text = "Transparency", Min = 0, Max = 1, Default = 0.5,
    }):OnChanged(function(v) State.AimbotFOVTransp = v end)

    GroupFOV:AddToggle("AimbotDynamicFOV", {
        Text = "Dynamic FOV", Default = false,
    }):OnChanged(function(v) State.AimbotDynamicFOV = v end)

    GroupFOV:AddToggle("AimbotFilledFOV", {
        Text = "Filled FOV", Default = false,
    }):OnChanged(function(v) State.AimbotFilledFOV = v end)

    GroupChecks:AddToggle("AimbotTeamCheck", {
        Text = "Team Check", Default = true,
    }):OnChanged(function(v) State.AimbotTeamCheck = v end)

    GroupChecks:AddToggle("AimbotVisCheck", {
        Text = "Visibility Check", Default = false,
    }):OnChanged(function(v) State.AimbotVisCheck = v end)

    GroupChecks:AddToggle("AimbotAliveCheck", {
        Text = "Alive Check", Default = true,
    }):OnChanged(function(v) State.AimbotAliveCheck = v end)

    GroupChecks:AddToggle("AimbotKnockedCheck", {
        Text = "Knocked Check", Default = false,
    }):OnChanged(function(v) State.AimbotKnockedCheck = v end)

    GroupChecks:AddToggle("AimbotFriendCheck", {
        Text = "Friend Check", Default = false,
    }):OnChanged(function(v) State.AimbotFriendCheck = v end)

    GroupVisuals:AddToggle("AimbotIndicator", {
        Text = "Lock Line", Default = true,
    }):OnChanged(function(v) State.AimbotIndicator = v end)

    GroupVisuals:AddToggle("AimbotShowName", {
        Text = "Target Name", Default = true,
    }):OnChanged(function(v) State.AimbotShowName = v end)

    GroupVisuals:AddToggle("AimbotShowDist", {
        Text = "Target Distance", Default = true,
    }):OnChanged(function(v) State.AimbotShowDist = v end)

    GroupVisuals:AddToggle("AimbotLockStatus", {
        Text = "Lock Status", Default = true,
    }):OnChanged(function(v) State.AimbotLockStatus = v end)

    GroupVisuals:AddKeybind("AimbotKeybind", {
        Text = "Toggle Aimbot",
        Default = Enum.KeyCode.X,
        Callback = function()
            State.AimbotEnabled = not State.AimbotEnabled
            if Toggles.AimbotEnabled then Toggles.AimbotEnabled:SetValue(State.AimbotEnabled) end
        end,
    })

    Library:OnUnload(function()
        renderConn:Disconnect()
        inputBegan:Disconnect()
        inputEnded:Disconnect()
        fovCircle:Remove(); lockLine:Remove(); lockLabel:Remove()
    end)
end

-- ============================================================================
-- MODULE: VISUALS (COSMETICS)
-- ============================================================================

do
    local Tab = Tabs.Visual
    local KORBLOX_ID = 139607718

    local function getCharacter()
        return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    end
    local function getHumanoid()
        return getCharacter():FindFirstChildOfClass("Humanoid")
    end
    local function removeTagged(character, tag)
        for _, obj in ipairs(character:GetChildren()) do
            if obj:IsA("Accessory") and obj:GetAttribute("IrisTag") == tag then
                obj:Destroy()
            end
        end
    end
    local function applyAccessory(assetId, tag)
        local character = getCharacter()
        removeTagged(character, tag)
        local ok, model = pcall(function()
            return InsertService:LoadAsset(assetId)
        end)
        if not ok or not model then
            Library:Notify("Failed to load asset " .. assetId, 3)
            return
        end
        local acc = model:FindFirstChildOfClass("Accessory") or model:FindFirstChildOfClass("Hat")
        if not acc then
            model:Destroy()
            Library:Notify("No accessory found in asset " .. assetId, 3)
            return
        end
        acc:SetAttribute("IrisTag", tag)
        acc.Parent = character
        local hum = getHumanoid()
        if hum then hum:AddAccessory(acc) end
        model:Destroy()
    end
    local function removeAccessory(tag)
        local character = getCharacter()
        if character then removeTagged(character, tag) end
    end
    local function applyHeadless()
        local character = getCharacter()
        local head = character:FindFirstChild("Head")
        if not head then return end
        for _, desc in ipairs(head:GetDescendants()) do
            if desc:IsA("Decal") or desc:IsA("SpecialMesh") then desc:Destroy() end
        end
        head.Transparency = 1
        head:SetAttribute("WasHeadless", true)
    end
    local function removeHeadless()
        local character = getCharacter()
        if not character then return end
        local head = character:FindFirstChild("Head")
        if head and head:GetAttribute("WasHeadless") then
            head.Transparency = 0
            head:SetAttribute("WasHeadless", nil)
        end
    end

    local GroupCosmetics = Tab:AddLeftGroupbox("Cosmetics")
    local GroupInfo      = Tab:AddRightGroupbox("Info")

    GroupCosmetics:AddToggle("HeadlessEnabled", {
        Text = "Headless Head", Default = false,
    }):OnChanged(function(v)
        State.HeadlessEnabled = v
        if v then applyHeadless() else removeHeadless() end
    end)

    GroupCosmetics:AddToggle("KorbloxEnabled", {
        Text = "Korblox Deathspeaker", Default = false,
    }):OnChanged(function(v)
        State.KorbloxEnabled = v
        if v then applyAccessory(KORBLOX_ID, "Korblox") else removeAccessory("Korblox") end
    end)

    GroupCosmetics:AddButton("Reapply All", function()
        if State.HeadlessEnabled then applyHeadless() end
        if State.KorbloxEnabled  then applyAccessory(KORBLOX_ID, "Korblox") end
        Library:Notify("Cosmetics reapplied.", 2)
    end)

    local charConn = LocalPlayer.CharacterAdded:Connect(function()
        task.wait(1)
        if State.HeadlessEnabled then applyHeadless() end
        if State.KorbloxEnabled  then applyAccessory(KORBLOX_ID, "Korblox") end
    end)

    GroupInfo:AddLabel("These are local-only cosmetics.")
    GroupInfo:AddLabel("Other players see your real look.")

    Library:OnUnload(function()
        charConn:Disconnect()
        removeHeadless()
        removeAccessory("Korblox")
    end)
end

-- ============================================================================
-- MODULE: ESP
-- ============================================================================

do
    local Tab = Tabs.ESP
    local pool = {}

    local function newDrawing(kind, props)
        local d = Drawing.new(kind)
        for k, v in pairs(props) do d[k] = v end
        return d
    end

    local function getOrCreate(player)
        if pool[player] then return pool[player] end
        local d = {}
        d.boxLines = {}
        for i = 1, 4 do
            d.boxLines[i] = newDrawing("Line", {
                Color = Color3.fromRGB(255, 255, 255), Thickness = 1, Transparency = 1, Visible = false,
            })
        end
        d.name = newDrawing("Text", {
            Color = Color3.fromRGB(255, 255, 255), Size = 11, Font = Drawing.Fonts.GothamBold,
            Center = true, Outline = true, Visible = false,
        })
        d.healthBg = newDrawing("Line", {
            Color = Color3.fromRGB(0, 0, 0), Thickness = 4, Transparency = 1, Visible = false,
        })
        d.healthFg = newDrawing("Line", {
            Color = Color3.fromRGB(0, 255, 100), Thickness = 2, Transparency = 1, Visible = false,
        })
        d.healthLabel = newDrawing("Text", {
            Color = Color3.fromRGB(255, 255, 255), Size = 10, Font = Drawing.Fonts.Gotham,
            Center = true, Outline = true, Visible = false,
        })
        d.tracer = newDrawing("Line", {
            Color = Color3.fromRGB(255, 255, 255), Thickness = 1, Transparency = 1, Visible = false,
        })
        d.distLabel = newDrawing("Text", {
            Color = Color3.fromRGB(220, 220, 220), Size = 10, Font = Drawing.Fonts.Gotham,
            Center = true, Outline = true, Visible = false,
        })
        pool[player] = d
        return d
    end

    local function removePlayer(player)
        local d = pool[player]
        if not d then return end
        for _, line in ipairs(d.boxLines) do line:Remove() end
        d.name:Remove(); d.healthBg:Remove(); d.healthFg:Remove()
        d.healthLabel:Remove(); d.tracer:Remove(); d.distLabel:Remove()
        pool[player] = nil
    end

    local function getCharacter(player) return player and player.Character end
    local function getHumanoid(character)
        return character and character:FindFirstChildOfClass("Humanoid")
    end
    local function getTeamColor(player)
        if State.ESPTeamColors and player.Team then return player.TeamColor.Color end
        return Color3.fromRGB(255, 255, 255)
    end
    local function getBoundingBox(character)
        local minX, minY, maxX, maxY = math.huge, math.huge, -math.huge, -math.huge
        local anyOnScreen = false
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") and not part.Name:find("HumanoidRootPart") then
                local size, cf = part.Size, part.CFrame
                local corners = {
                    cf * CFrame.new( size.X/2,  size.Y/2,  size.Z/2),
                    cf * CFrame.new(-size.X/2,  size.Y/2,  size.Z/2),
                    cf * CFrame.new( size.X/2, -size.Y/2,  size.Z/2),
                    cf * CFrame.new(-size.X/2, -size.Y/2,  size.Z/2),
                    cf * CFrame.new( size.X/2,  size.Y/2, -size.Z/2),
                    cf * CFrame.new(-size.X/2,  size.Y/2, -size.Z/2),
                    cf * CFrame.new( size.X/2, -size.Y/2, -size.Z/2),
                    cf * CFrame.new(-size.X/2, -size.Y/2, -size.Z/2),
                }
                for _, corner in ipairs(corners) do
                    local sp, onScreen = Camera:WorldToViewportPoint(corner.Position)
                    if onScreen then
                        anyOnScreen = true
                        if sp.X < minX then minX = sp.X end
                        if sp.Y < minY then minY = sp.Y end
                        if sp.X > maxX then maxX = sp.X end
                        if sp.Y > maxY then maxY = sp.Y end
                    end
                end
            end
        end
        if not anyOnScreen then return nil end
        return minX, minY, maxX, maxY
    end
    local function drawBox(d, x1, y1, x2, y2, color, thickness)
        local lines = d.boxLines
        lines[1].From = Vector2.new(x1, y1); lines[1].To = Vector2.new(x2, y1)
        lines[2].From = Vector2.new(x1, y2); lines[2].To = Vector2.new(x2, y2)
        lines[3].From = Vector2.new(x1, y1); lines[3].To = Vector2.new(x1, y2)
        lines[4].From = Vector2.new(x2, y1); lines[4].To = Vector2.new(x2, y2)
        for _, l in ipairs(lines) do
            l.Color = color; l.Thickness = thickness or 1; l.Visible = true
        end
    end
    local function hideBox(d) for _, l in ipairs(d.boxLines) do l.Visible = false end end
    local function getHealthColor(pct)
        if State.ESPGradientHealth then
            if pct >= 0.5 then
                local t = (pct - 0.5) * 2
                return Color3.fromRGB(math.floor((1 - t) * 255), 255, 0)
            else
                local t = pct * 2
                return Color3.fromRGB(255, math.floor(t * 255), 0)
            end
        end
        return State.ESPHealthColor
    end
    local rainbowHue = 0
    local function getTracerOrigin()
        local vp = Camera.ViewportSize
        if State.ESPTracerOrigin == "Bottom" then return Vector2.new(vp.X / 2, vp.Y) end
        if State.ESPTracerOrigin == "Top"    then return Vector2.new(vp.X / 2, 0) end
        if State.ESPTracerOrigin == "Mouse"  then return Vector2.new(Mouse.X, Mouse.Y) end
        return Vector2.new(vp.X / 2, vp.Y)
    end

    local renderConn = RunService.RenderStepped:Connect(function()
        if State.ESPRainbow then rainbowHue = (rainbowHue + 0.005) % 1 end

        for _, player in ipairs(Players:GetPlayers()) do
            if player == LocalPlayer then continue end
            local d = getOrCreate(player)
            local char = getCharacter(player)

            local function hideAll()
                hideBox(d)
                d.name.Visible = false; d.healthBg.Visible = false; d.healthFg.Visible = false
                d.healthLabel.Visible = false; d.tracer.Visible = false; d.distLabel.Visible = false
            end

            if not State.ESPEnabled or not char then hideAll(); continue end
            local hum = getHumanoid(char)
            if not hum or hum.Health <= 0 then hideAll(); continue end
            local root = char:FindFirstChild("HumanoidRootPart")
            if not root then hideAll(); continue end

            local dist = (Camera.CFrame.Position - root.Position).Magnitude
            if dist > State.ESPMaxDist then hideAll(); continue end

            local x1, y1, x2, y2 = getBoundingBox(char)
            if not x1 then hideAll(); continue end

            local espColor = State.ESPRainbow and Color3.fromHSV(rainbowHue, 1, 1) or getTeamColor(player)

            if State.ESPBox then
                drawBox(d, x1, y1, x2, y2, espColor, 1)
                if State.ESPOutline then
                    drawBox(d, x1 - 1, y1 - 1, x2 + 1, y2 + 1, Color3.fromRGB(0, 0, 0), 1)
                end
            else
                hideBox(d)
            end

            if State.ESPName then
                d.name.Visible  = true
                d.name.Position = Vector2.new((x1 + x2) / 2, y1 - 14)
                d.name.Text     = player.DisplayName
                d.name.Color    = espColor
                d.name.Size     = State.ESPTextSize or 11
            else
                d.name.Visible = false
            end

            if State.ESPHealthBar then
                local hp, maxHp = hum.Health, hum.MaxHealth
                local pct  = math.clamp(hp / math.max(maxHp, 1), 0, 1)
                local barH = y2 - y1
                local barX = x1 - 5
                d.healthBg.Visible   = true
                d.healthBg.From      = Vector2.new(barX, y1)
                d.healthBg.To        = Vector2.new(barX, y2)
                d.healthBg.Thickness = 3
                d.healthFg.Visible   = true
                d.healthFg.From      = Vector2.new(barX, y2)
                d.healthFg.To        = Vector2.new(barX, y2 - barH * pct)
                d.healthFg.Thickness = 2
                d.healthFg.Color     = getHealthColor(pct)
                if State.ESPHealthText or State.ESPHealthPct then
                    d.healthLabel.Visible  = true
                    d.healthLabel.Position = Vector2.new(barX - 10, (y1 + y2) / 2)
                    d.healthLabel.Text = State.ESPHealthPct
                        and (math.floor(pct * 100) .. "%")
                        or  (math.floor(hp) .. "/" .. math.floor(maxHp))
                else
                    d.healthLabel.Visible = false
                end
            else
                d.healthBg.Visible = false; d.healthFg.Visible = false; d.healthLabel.Visible = false
            end

            if State.ESPDistance then
                local unit   = State.ESPDistUnit == "Meters" and math.floor(dist * 0.28) or math.floor(dist)
                local suffix = State.ESPDistUnit == "Meters" and "m" or " studs"
                d.distLabel.Visible  = true
                d.distLabel.Position = Vector2.new((x1 + x2) / 2, y2 + 2)
                d.distLabel.Text     = unit .. suffix
                d.distLabel.Color    = State.ESPDistColor
                d.distLabel.Size     = State.ESPTextSize or 10
            else
                d.distLabel.Visible = false
            end

            if State.ESPTracers then
                local sp, onScreen = Camera:WorldToViewportPoint(root.Position)
                if onScreen then
                    d.tracer.Visible      = true
                    d.tracer.From         = getTracerOrigin()
                    d.tracer.To           = Vector2.new(sp.X, sp.Y)
                    d.tracer.Color        = State.ESPRainbow
                        and Color3.fromHSV(rainbowHue, 1, 1)
                        or  State.ESPTracerColor
                    d.tracer.Thickness    = State.ESPTracerThickness
                    d.tracer.Transparency = 1 - State.ESPTracerTransp
                else
                    d.tracer.Visible = false
                end
            else
                d.tracer.Visible = false
            end
        end
    end)

    local playerRemovedConn = Players.PlayerRemoving:Connect(removePlayer)

    -- UI
    local GroupMain    = Tab:AddLeftGroupbox("ESP")
    local GroupHealth  = Tab:AddLeftGroupbox("Health")
    local GroupDist    = Tab:AddLeftGroupbox("Distance")
    local GroupTracers = Tab:AddRightGroupbox("Tracers")
    local GroupCustom  = Tab:AddRightGroupbox("Customization")

    GroupMain:AddToggle("ESPEnabled", {
        Text = "ESP Enabled", Default = false,
    }):OnChanged(function(v) State.ESPEnabled = v end)

    GroupMain:AddToggle("ESPBox",  { Text = "Box ESP",  Default = true }):OnChanged(function(v) State.ESPBox  = v end)
    GroupMain:AddToggle("ESPName", { Text = "Name ESP", Default = true }):OnChanged(function(v) State.ESPName = v end)

    GroupHealth:AddToggle("ESPHealthBar",  { Text = "Health Bar",        Default = true  }):OnChanged(function(v) State.ESPHealthBar  = v end)
    GroupHealth:AddToggle("ESPHealthText", { Text = "Health Text",       Default = false }):OnChanged(function(v) State.ESPHealthText = v end)
    GroupHealth:AddToggle("ESPHealthPct",  { Text = "Health Percentage", Default = false }):OnChanged(function(v) State.ESPHealthPct  = v end)
    GroupHealth:AddColorPicker("ESPHealthColor", {
        Text = "Health Color", Default = Color3.fromRGB(0, 255, 100),
    }):OnChanged(function(v) State.ESPHealthColor = v end)
    GroupHealth:AddToggle("ESPGradientHealth", { Text = "Gradient Health", Default = false }):OnChanged(function(v) State.ESPGradientHealth = v end)

    GroupDist:AddToggle("ESPDistance", { Text = "Show Distance", Default = true }):OnChanged(function(v) State.ESPDistance = v end)
    GroupDist:AddDropdown("ESPDistUnit", {
        Text = "Distance Unit", Values = { "Studs", "Meters" }, Default = "Studs",
    }):OnChanged(function(v) State.ESPDistUnit = v end)
    GroupDist:AddSlider("ESPMaxDist", {
        Text = "Max Distance", Min = 50, Max = 2000, Default = 1000, Suffix = " studs",
    }):OnChanged(function(v) State.ESPMaxDist = v end)
    GroupDist:AddColorPicker("ESPDistColor", {
        Text = "Distance Color", Default = Color3.fromRGB(220, 220, 220),
    }):OnChanged(function(v) State.ESPDistColor = v end)

    GroupTracers:AddToggle("ESPTracers", { Text = "Tracers Enabled", Default = false }):OnChanged(function(v) State.ESPTracers = v end)
    GroupTracers:AddDropdown("ESPTracerOrigin", {
        Text = "Tracer Origin", Values = { "Bottom", "Top", "Mouse" }, Default = "Bottom",
    }):OnChanged(function(v) State.ESPTracerOrigin = v end)
    GroupTracers:AddColorPicker("ESPTracerColor", {
        Text = "Tracer Color", Default = Color3.fromRGB(255, 255, 255),
    }):OnChanged(function(v) State.ESPTracerColor = v end)
    GroupTracers:AddSlider("ESPTracerThickness", {
        Text = "Tracer Thickness", Min = 1, Max = 5, Default = 1,
    }):OnChanged(function(v) State.ESPTracerThickness = v end)
    GroupTracers:AddSlider("ESPTracerTransp", {
        Text = "Tracer Transparency", Min = 0, Max = 1, Default = 0.4,
    }):OnChanged(function(v) State.ESPTracerTransp = v end)

    GroupCustom:AddSlider("ESPTextSize", {
        Text = "Text Size", Min = 8, Max = 18, Default = 11,
    }):OnChanged(function(v) State.ESPTextSize = v end)
    GroupCustom:AddToggle("ESPOutline",    { Text = "ESP Outline",        Default = true  }):OnChanged(function(v) State.ESPOutline    = v end)
    GroupCustom:AddToggle("ESPRainbow",    { Text = "Rainbow Mode",       Default = false }):OnChanged(function(v) State.ESPRainbow    = v end)
    GroupCustom:AddToggle("ESPTeamColors", { Text = "Team-Based Colors",  Default = false }):OnChanged(function(v) State.ESPTeamColors = v end)

    Library:OnUnload(function()
        renderConn:Disconnect()
        playerRemovedConn:Disconnect()
        for player in pairs(pool) do removePlayer(player) end
    end)
end

-- ============================================================================
-- CONFIG TAB
-- ============================================================================

local ConfigLeft, ConfigRight = Tabs.Config:AddLeftGroupbox("Presets"), Tabs.Config:AddRightGroupbox("Interface")

SaveManager:SetLibrary(Library)
ThemeManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetFolder("ProjectIris")
SaveManager:BuildConfigSection(ConfigLeft)
ThemeManager:BuildThemeSection(ConfigRight)

-- ============================================================================
-- DONE
-- ============================================================================

Library.Notify("Project Iris loaded.", 3)
