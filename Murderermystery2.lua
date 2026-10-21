--==================================================
-- MM2 PREMIUM / NORMAL HUB
-- Keys: MEI (Normal) | MEI-PREMUIM-1 (Premium)
-- Features: Draggable UI, Floating Toggle, Compact
--==================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local LP = Players.LocalPlayer
local PlayerGui = LP:WaitForChild("PlayerGui")

local CFG = {
    BG      = Color3.fromRGB(15, 15, 20),
    Panel   = Color3.fromRGB(25, 25, 35),
    Accent  = Color3.fromRGB(255, 60, 60),
    Text    = Color3.fromRGB(255, 255, 255),
    Muted   = Color3.fromRGB(150, 150, 160),
    Good    = Color3.fromRGB(60, 255, 120),
}

local KEY_NORMAL = "MEI"
local KEY_PREMIUM = "MEI-PREMUIM-1"
local isPremiumUnlocked = false

local State = {
    ESP = false, CoinFarm = false, AutoWin = false,
    SilentAim = false, AntiThrow = false, WalkSpeed = 16
}

-- Cleanup
for _, name in ipairs({"MM2_Hub", "MM2_KeyGate"}) do
    local old = PlayerGui:FindFirstChild(name)
    if old then old:Destroy() end
end

--==================================================
-- DRAG HELPER
--==================================================
local function MakeDraggable(frame, dragArea)
    local dragging, dragInput, dragStart, startPos
    dragArea.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    dragArea.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

--==================================================
-- KEY GATE UI (Compact & Draggable)
--==================================================
local keyGui = Instance.new("ScreenGui")
keyGui.Name = "MM2_KeyGate"
keyGui.ResetOnSpawn = false
keyGui.IgnoreGuiInset = true
keyGui.Parent = PlayerGui

local kFrame = Instance.new("Frame")
kFrame.Size = UDim2.fromOffset(260, 160)
kFrame.Position = UDim2.fromScale(0.5, 0.5)
kFrame.AnchorPoint = Vector2.new(0.5, 0.5)
kFrame.BackgroundColor3 = CFG.BG
kFrame.BorderSizePixel = 0
kFrame.Parent = keyGui
local kc = Instance.new("UICorner") kc.CornerRadius = UDim.new(0, 8) kc.Parent = kFrame
local ks = Instance.new("UIStroke") ks.Color = CFG.Accent ks.Thickness = 1.5 ks.Transparency = 0.5 ks.Parent = kFrame
MakeDraggable(kFrame, kFrame)

local kTitle = Instance.new("TextLabel")
kTitle.Size = UDim2.new(1, 0, 0, 35)
kTitle.BackgroundTransparency = 1
kTitle.Text = "MM2 HUB | AUTH"
kTitle.TextColor3 = CFG.Text
kTitle.Font = Enum.Font.GothamBold
kTitle.TextSize = 14
kTitle.Parent = kFrame

local kBox = Instance.new("TextBox")
kBox.Size = UDim2.new(1, -30, 0, 32)
kBox.Position = UDim2.fromOffset(15, 45)
kBox.BackgroundColor3 = CFG.Panel
kBox.Text = ""
kBox.PlaceholderText = "Enter Key..."
kBox.PlaceholderColor3 = CFG.Muted
kBox.TextColor3 = CFG.Text
kBox.Font = Enum.Font.Gotham
kBox.TextSize = 12
kBox.ClearTextOnFocus = false
kBox.BorderSizePixel = 0
kBox.Parent = kFrame
local kb = Instance.new("UICorner") kb.CornerRadius = UDim.new(0, 6) kb.Parent = kBox

local kBtn = Instance.new("TextButton")
kBtn.Size = UDim2.new(1, -30, 0, 32)
kBtn.Position = UDim2.fromOffset(15, 85)
kBtn.BackgroundColor3 = CFG.Accent
kBtn.Text = "UNLOCK"
kBtn.TextColor3 = CFG.Text
kBtn.Font = Enum.Font.GothamBold
kBtn.TextSize = 12
kBtn.BorderSizePixel = 0
kBtn.Parent = kFrame
local kbt = Instance.new("UICorner") kbt.CornerRadius = UDim.new(0, 6) kbt.Parent = kBtn

local kStatus = Instance.new("TextLabel")
kStatus.Size = UDim2.new(1, -30, 0, 16)
kStatus.Position = UDim2.fromOffset(15, 125)
kStatus.BackgroundTransparency = 1
kStatus.Text = ""
kStatus.TextColor3 = CFG.Muted
kStatus.Font = Enum.Font.Gotham
kStatus.TextSize = 10
kStatus.Parent = kFrame

-- Verify Logic
local function VerifyKey()
    local input = string.upper(kBox.Text:gsub("%s", ""))
    if input == KEY_NORMAL then
        isPremiumUnlocked = false
        kStatus.Text = "Normal access granted."; kStatus.TextColor3 = CFG.Good
        task.wait(0.5); keyGui:Destroy(); loadHub()
    elseif input == KEY_PREMIUM then
        isPremiumUnlocked = true
        kStatus.Text = "Premium access granted."; kStatus.TextColor3 = CFG.Good
        task.wait(0.5); keyGui:Destroy(); loadHub()
    else
        kStatus.Text = "Invalid key."; kStatus.TextColor3 = CFG.Accent
        kBox.Text = ""
    end
end
kBtn.MouseButton1Click:Connect(VerifyKey)
kBox.FocusLost:Connect(function(enter) if enter then VerifyKey() end end)

--==================================================
-- MAIN HUB UI (Compact & Draggable)
--==================================================
function loadHub()
    local Gui = Instance.new("ScreenGui")
    Gui.Name = "MM2_Hub"
    Gui.ResetOnSpawn = false
    Gui.IgnoreGuiInset = true
    Gui.Parent = PlayerGui

    -- Main Frame
    local Main = Instance.new("Frame")
    Main.Size = UDim2.fromOffset(320, 250)
    Main.Position = UDim2.fromScale(0.5, 0.5)
    Main.AnchorPoint = Vector2.new(0.5, 0.5)
    Main.BackgroundColor3 = CFG.BG
    Main.BorderSizePixel = 0
    Main.Parent = Gui
    local mc = Instance.new("UICorner") mc.CornerRadius = UDim.new(0, 10) mc.Parent = Main
    local ms = Instance.new("UIStroke") ms.Color = CFG.Accent ms.Thickness = 1.5 ms.Transparency = 0.5 ms.Parent = Main
    MakeDraggable(Main, Main)

    -- Header
    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, 0, 0, 32)
    Header.BackgroundColor3 = CFG.Panel
    Header.BorderSizePixel = 0
    Header.Parent = Main
    local hc = Instance.new("UICorner") hc.CornerRadius = UDim.new(0, 10) hc.Parent = Header
    local hf = Instance.new("Frame") hf.Size = UDim2.new(1, 0, 0, 12) hf.Position = UDim2.new(0, 0, 1, -12) hf.BackgroundColor3 = CFG.Panel hf.BorderSizePixel = 0 hf.Parent = Header

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -60, 1, 0)
    Title.Position = UDim2.fromOffset(10, 0)
    Title.BackgroundTransparency = 1
    Title.Text = isPremiumUnlocked and "MM2 HUB | PREMIUM" or "MM2 HUB | NORMAL"
    Title.TextColor3 = CFG.Text
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 12
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Header

    -- Close / Hide Button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.fromOffset(24, 24)
    closeBtn.Position = UDim2.new(1, -28, 0.5, -12)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Text = "X"
    closeBtn.TextColor3 = CFG.Muted
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 14
    closeBtn.Parent = Header
    closeBtn.MouseButton1Click:Connect(function() Main.Visible = false end)

    -- Tabs
    local TabBar = Instance.new("Frame")
    TabBar.Size = UDim2.new(1, -16, 0, 24)
    TabBar.Position = UDim2.fromOffset(8, 40)
    TabBar.BackgroundTransparency = 1
    TabBar.Parent = Main

    local tNormal = Instance.new("TextButton")
    tNormal.Size = UDim2.new(0.5, -4, 1, 0)
    tNormal.BackgroundColor3 = CFG.Accent
    tNormal.Text = "NORMAL"
    tNormal.TextColor3 = CFG.Text
    tNormal.Font = Enum.Font.GothamBold
    tNormal.TextSize = 11
    tNormal.BorderSizePixel = 0
    tNormal.Parent = TabBar
    local c1 = Instance.new("UICorner") c1.CornerRadius = UDim.new(0, 4) c1.Parent = tNormal

    local tPremium = Instance.new("TextButton")
    tPremium.Size = UDim2.new(0.5, -4, 1, 0)
    tPremium.Position = UDim2.new(0.5, 4, 0, 0)
    tPremium.BackgroundColor3 = CFG.Panel
    tPremium.Text = isPremiumUnlocked and "PREMIUM" or "PREMIUM (LOCKED)"
    tPremium.TextColor3 = isPremiumUnlocked and CFG.Muted or CFG.Accent
    tPremium.Font = Enum.Font.GothamBold
    tPremium.TextSize = 11
    tPremium.BorderSizePixel = 0
    tPremium.Parent = TabBar
    local c2 = Instance.new("UICorner") c2.CornerRadius = UDim.new(0, 4) c2.Parent = tPremium

    -- Pages
    local Pages = Instance.new("Frame")
    Pages.Size = UDim2.new(1, -16, 1, -72)
    Pages.Position = UDim2.fromOffset(8, 72)
    Pages.BackgroundTransparency = 1
    Pages.Parent = Main

    local pNormal = Instance.new("ScrollingFrame")
    pNormal.Size = UDim2.new(1, 0, 1, 0)
    pNormal.BackgroundTransparency = 1
    pNormal.BorderSizePixel = 0
    pNormal.ScrollBarThickness = 2
    pNormal.AutomaticCanvasSize = Enum.AutomaticSize.Y
    pNormal.CanvasSize = UDim2.new()
    pNormal.Parent = Pages
    local l1 = Instance.new("UIListLayout") l1.Padding = UDim.new(0, 6) l1.Parent = pNormal

    local pPremium = Instance.new("ScrollingFrame")
    pPremium.Size = UDim2.new(1, 0, 1, 0)
    pPremium.BackgroundTransparency = 1
    pPremium.BorderSizePixel = 0
    pPremium.ScrollBarThickness = 2
    pPremium.AutomaticCanvasSize = Enum.AutomaticSize.Y
    pPremium.CanvasSize = UDim2.new()
    pPremium.Visible = false
    pPremium.Parent = Pages
    local l2 = Instance.new("UIListLayout") l2.Padding = UDim.new(0, 6) l2.Parent = pPremium

    -- Tab Switching
    tNormal.MouseButton1Click:Connect(function()
        pNormal.Visible = true; pPremium.Visible = false
        tNormal.BackgroundColor3 = CFG.Accent; tPremium.BackgroundColor3 = CFG.Panel
        tNormal.TextColor3 = CFG.Text; tPremium.TextColor3 = isPremiumUnlocked and CFG.Muted or CFG.Accent
    end)
    
    tPremium.MouseButton1Click:Connect(function()
        if not isPremiumUnlocked then
            tPremium.Text = "JOIN DISCORD AND BUY"
            task.wait(1.5)
            tPremium.Text = "PREMIUM (LOCKED)"
            return
        end
        pNormal.Visible = false; pPremium.Visible = true
        tPremium.BackgroundColor3 = CFG.Accent; tNormal.BackgroundColor3 = CFG.Panel
        tPremium.TextColor3 = CFG.Text; tNormal.TextColor3 = CFG.Muted
    end)

    -- UI Components (Compact)
    local function MakeToggle(parent, text, default, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 30)
        btn.BackgroundColor3 = CFG.Panel
        btn.Text = "  " .. text
        btn.TextColor3 = CFG.Text
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 12
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.BorderSizePixel = 0
        btn.AutoButtonColor = false
        btn.Parent = parent
        local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0, 4) c.Parent = btn
        
        local status = Instance.new("TextLabel")
        status.Size = UDim2.fromOffset(40, 20)
        status.Position = UDim2.new(1, -45, 0.5, -10)
        status.BackgroundTransparency = 1
        status.Text = default and "ON" or "OFF"
        status.TextColor3 = default and CFG.Good or CFG.Muted
        status.Font = Enum.Font.GothamBold
        status.TextSize = 11
        status.Parent = btn
        
        local state = default
        btn.MouseButton1Click:Connect(function()
            state = not state
            status.Text = state and "ON" or "OFF"
            status.TextColor3 = state and CFG.Good or CFG.Muted
            btn.BackgroundColor3 = state and Color3.fromRGB(35, 45, 35) or CFG.Panel
            if callback then callback(state) end
        end)
    end

    local function MakeSlider(parent, text, min, max, default, callback)
        local f = Instance.new("Frame")
        f.Size = UDim2.new(1, 0, 0, 36)
        f.BackgroundColor3 = CFG.Panel
        f.BorderSizePixel = 0
        f.Parent = parent
        local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0, 4) c.Parent = f
        
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -16, 0, 16)
        lbl.Position = UDim2.fromOffset(8, 4)
        lbl.BackgroundTransparency = 1
        lbl.Text = text .. ": " .. default
        lbl.TextColor3 = CFG.Text
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 11
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = f
        
        local bar = Instance.new("Frame")
        bar.Size = UDim2.new(1, -16, 0, 5)
        bar.Position = UDim2.fromOffset(8, 24)
        bar.BackgroundColor3 = CFG.BG
        bar.BorderSizePixel = 0
        bar.Parent = f
        local cb = Instance.new("UICorner") cb.CornerRadius = UDim.new(1, 0) cb.Parent = bar
        
        local fill = Instance.new("Frame")
        fill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0)
        fill.BackgroundColor3 = CFG.Accent
        fill.BorderSizePixel = 0
        fill.Parent = bar
        local cf = Instance.new("UICorner") cf.CornerRadius = UDim.new(1, 0) cf.Parent = fill
        
        local dragging = false
        local function Update(x)
            local pct = math.clamp((x - bar.AbsolutePosition.X) / math.max(bar.AbsoluteSize.X, 1), 0, 1)
            fill.Size = UDim2.new(pct, 0, 1, 0)
            local val = math.floor(min + (max-min)*pct + 0.5)
            lbl.Text = text .. ": " .. val
            if callback then callback(val) end
        end
        
        bar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = true; Update(i.Position.X) end end)
        UIS.InputChanged:Connect(function(i) if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then Update(i.Position.X) end end)
        UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
    end

    -- Populate Normal
    MakeToggle(pNormal, "Player ESP", false, function(v) State.ESP = v end)
    MakeSlider(pNormal, "WalkSpeed", 16, 200, 16, function(v) State.WalkSpeed = v end)
    MakeToggle(pNormal, "Fullbright", false, function(v)
        if v then Lighting.Ambient = Color3.fromRGB(255,255,255); Lighting.OutdoorAmbient = Color3.fromRGB(255,255,255)
        else Lighting.Ambient = Color3.fromRGB(70,70,70); Lighting.OutdoorAmbient = Color3.fromRGB(128,128,128) end
    end)
    MakeToggle(pNormal, "Auto Collect Coins", false, function(v) State.CoinFarm = v end)

    -- Populate Premium
    if isPremiumUnlocked then
        MakeToggle(pPremium, "Auto-Win", false, function(v) State.AutoWin = v end)
        MakeToggle(pPremium, "Silent Aim", false, function(v) State.SilentAim = v end)
        MakeToggle(pPremium, "Anti-Throw", false, function(v) State.AntiThrow = v end)
        MakeToggle(pPremium, "Auto-Farm (TP)", false, function(v) State.CoinFarm = v end)
    else
        local lockedLbl = Instance.new("TextLabel")
        lockedLbl.Size = UDim2.new(1, 0, 0, 40)
        lockedLbl.BackgroundColor3 = CFG.Panel
        lockedLbl.Text = "JOIN DISCORD SERVER AND BUY IT"
        lockedLbl.TextColor3 = CFG.Accent
        lockedLbl.Font = Enum.Font.GothamBold
        lockedLbl.TextSize = 11
        lockedLbl.Parent = pPremium
        local lc = Instance.new("UICorner") lc.CornerRadius = UDim.new(0, 4) lc.Parent = lockedLbl
    end

    --==================================================
    -- FLOATING TOGGLE BUTTON
    --==================================================
    local floatBtn = Instance.new("TextButton")
    floatBtn.Size = UDim2.fromOffset(40, 40)
    floatBtn.Position = UDim2.fromOffset(20, 200)
    floatBtn.AnchorPoint = Vector2.new(0, 1)
    floatBtn.BackgroundColor3 = CFG.BG
    floatBtn.Text = "M"
    floatBtn.TextColor3 = CFG.Accent
    floatBtn.Font = Enum.Font.GothamBold
    floatBtn.TextSize = 16
    floatBtn.BorderSizePixel = 0
    floatBtn.Parent = Gui
    local fbc = Instance.new("UICorner") fbc.CornerRadius = UDim.new(1, 0) fbc.Parent = floatBtn
    local fbs = Instance.new("UIStroke") fbs.Color = CFG.Accent fbs.Thickness = 1.5 fbs.Parent = floatBtn
    MakeDraggable(floatBtn, floatBtn)
    
    local dragMoved = false
    floatBtn.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragMoved = false end end)
    UIS.InputChanged:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then if floatBtn.Position ~= UDim2.fromOffset(20, 200) then dragMoved = true end end end)
    
    floatBtn.MouseButton1Click:Connect(function()
        if not dragMoved then Main.Visible = not Main.Visible end
    end)

    --==================================================
    -- GAME LOGIC
    --==================================================
    local function getRole(plr)
        local char = plr.Character
        if not char then return "Innocent" end
        local backpack = plr:FindFirstChild("Backpack")
        local hasKnife = false
        local hasGun = false
        local function check(c) if not c then return end; if c:FindFirstChild("Knife") then hasKnife = true end; if c:FindFirstChild("Gun") then hasGun = true end end
        check(char); check(backpack)
        if hasKnife then return "Murderer" end
        if hasGun then return "Sheriff" end
        return "Innocent"
    end

    local espObjects = {}
    RunService.RenderStepped:Connect(function()
        if State.ESP then
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LP and plr.Character then
                    if not espObjects[plr] then
                        local hl = Instance.new("Highlight")
                        hl.Adornee = plr.Character
                        hl.Parent = Gui
                        espObjects[plr] = hl
                    end
                    local role = getRole(plr)
                    local hl = espObjects[plr]
                    if role == "Murderer" then hl.FillColor = Color3.fromRGB(255, 0, 0)
                    elseif role == "Sheriff" then hl.FillColor = Color3.fromRGB(0, 100, 255)
                    else hl.FillColor = Color3.fromRGB(0, 255, 0) end
                    hl.OutlineColor = Color3.new(1,1,1)
                end
            end
        else
            for plr, hl in pairs(espObjects) do hl:Destroy(); espObjects[plr] = nil end
        end
    end)

    RunService.Heartbeat:Connect(function()
        local char = LP.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = State.WalkSpeed end
            if State.AntiThrow then
                local tool = char:FindFirstChild("Gun")
                if tool and UIS:IsKeyDown(Enum.KeyCode.Q) then hum:UnequipTools() end
            end
        end
    end)

    task.spawn(function()
        while true do
            task.wait(0.5)
            if State.CoinFarm then
                local char = LP.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    for _, obj in ipairs(workspace:GetDescendants()) do
                        if obj.Name:lower():find("coin") and obj:IsA("BasePart") then
                            if (obj.Position - hrp.Position).Magnitude < 50 and firetouchinterest then
                                pcall(function() firetouchinterest(hrp, obj, 0) task.wait() firetouchinterest(hrp, obj, 1) end)
                            end
                        end
                    end
                end
            end
        end
    end)

 if isPremiumUnlocked then
        task.spawn(function()
            while true do
                task.wait(0.2)
                if State.AutoWin then
                    local char = LP.Character
                    if char and getRole(LP) == "Murderer" then
                        local hrp = char:FindFirstChild("HumanoidRootPart")
                        local backpack = LP:FindFirstChild("Backpack")
                        local knife = char:FindFirstChild("Knife") or (backpack and backpack:FindFirstChild("Knife"))
                        if knife then
                            if knife.Parent ~= char then local hum = char:FindFirstChildOfClass("Humanoid"); if hum then hum:EquipTool(knife) end end
                            local target, dist = nil, math.huge
                            for _, plr in ipairs(Players:GetPlayers()) do
                                if plr ~= LP and plr.Character and getRole(plr) ~= "Murderer" then
                                    local pHrp = plr.Character:FindFirstChild("HumanoidRootPart")
                                    if pHrp then
                                        local d = (pHrp.Position - hrp.Position).Magnitude
                                        if d < dist then target, dist = plr, d end
                                    end
                                end
                            end
                            if target then
                                local tHrp = target.Character:FindFirstChild("HumanoidRootPart")
                                if tHrp then
                                    hrp.CFrame = tHrp.CFrame * CFrame.new(0, 0, 2)
                                    if knife:FindFirstChild("Slash") then knife.Slash:FireServer() end
                                end
                            end
                        end
                    end
                end
            end
        end)

        local oldNamecall
        oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            if (method == "FireServer" or method == "InvokeServer") and State.AutoWin then
                if self.Name == "GunFire" or self.Name == "Shoot" then
                    local args = {...}
                    if State.SilentAim then
                        local target = nil
                        for _, plr in ipairs(Players:GetPlayers()) do if plr ~= LP and getRole(plr) == "Murderer" then target = plr break end end
                        if target and target.Character then
                            local tHead = target.Character:FindFirstChild("Head")
                            if tHead then args[1] = tHead.Position end
                        end
                    end
                    return oldNamecall(self, unpack(args))
                end
            end
            return oldNamecall(self, ...)
        end)
    end
end
