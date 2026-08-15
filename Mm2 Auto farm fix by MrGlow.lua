--[=[ MM2 ULTIMATE SCRIPT by MrGlow - ОБЫЧНАЯ КНОПКА ]=]
local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local virtualUser = game:GetService("VirtualUser")
local tweenService = game:GetService("TweenService")
local userInputService = game:GetService("UserInputService")
local runService = game:GetService("RunService")
local replicatedStorage = game:GetService("ReplicatedStorage")
local players = game:GetService("Players")
local lighting = game:GetService("Lighting")

-- === НАСТРОЙКИ ===
local CONFIG = {
    FarmSpeed = 0.1,
    AntiAFK = true,
    AutoTeleport = true,
    CollectRadius = 80,
    IgnoreOwnCoins = true,
    RadarEnabled = true,
    RadarColor = Color3.fromRGB(0, 255, 0),
    AntiCheatDelay = 0.05,
    SuperSpeed = true,
    AutoBuySkins = true,
    FarmCandy = true,
    KillAura = true,
    ESPPlayers = true,
    AntiStun = true,
    TeleportToCoins = true,
    RussianUI = true
}

-- === ПЕРЕМЕННЫЕ ===
local isFarming = false
local collectedCoins = 0
local collectedCandy = 0
local isDead = false
local menuVisible = true
local espObjects = {}
local espHighlights = {}
local startTime = os.time()
local coinsPerMinute = 0

-- === ПЕРЕВОД ===
local lang = {
    Title = "MM2 ФАРМ",
    SubTitle = "by MrGlow • Ультимативный",
    StatusStopped = "Остановлен",
    StatusFarming = "Фарм активен",
    StatusNoCoins = "Монет не найдено",
    StatusDead = "Персонаж умер!",
    StatusCollecting = "Сбор: ",
    StatusCandy = "Конфет: ",
    StatusCoins = "Монет: ",
    BtnStart = "▶ СТАРТ ФАРМ",
    BtnStop = "⏹ СТОП ФАРМ",
    SpeedLabel = "⚡ Скорость",
    InfoText = "⚡ Сбор монет и конфет\n📍 Радар включён\n🛡 Анти-чит активен\n🎯 Kill Aura + ESP\n🛒 Авто-покупка скинов"
}

if not CONFIG.RussianUI then
    lang = {
        Title = "MM2 FARM",
        SubTitle = "by MrGlow • Ultimate",
        StatusStopped = "Stopped",
        StatusFarming = "Farming active",
        StatusNoCoins = "No coins found",
        StatusDead = "Character died!",
        StatusCollecting = "Collecting: ",
        StatusCandy = "Candy: ",
        StatusCoins = "Coins: ",
        BtnStart = "▶ START FARM",
        BtnStop = "⏹ STOP FARM",
        SpeedLabel = "⚡ Speed",
        InfoText = "⚡ Coins & Candy farm\n📍 Radar enabled\n🛡 Anti-cheat active\n🎯 Kill Aura + ESP\n🛒 Auto-buy skins"
    }
end

-- === СОЗДАНИЕ GUI ===
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MM2Farm"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

-- === ПЛАВАЮЩАЯ КНОПКА ===
local floatingButton = Instance.new("ImageButton")
floatingButton.Size = UDim2.new(0, 45, 0, 45)
floatingButton.Position = UDim2.new(1, -55, 0, 10)
floatingButton.BackgroundColor3 = Color3.fromRGB(20, 20, 40)
floatingButton.BackgroundTransparency = 0.1
floatingButton.BorderSizePixel = 0
floatingButton.Image = "rbxassetid://99615853578192"
floatingButton.ImageColor3 = Color3.fromRGB(255, 255, 255)
floatingButton.Visible = false
floatingButton.Parent = screenGui

local floatCorner = Instance.new("UICorner")
floatCorner.CornerRadius = UDim.new(1, 0)
floatCorner.Parent = floatingButton

local floatStroke = Instance.new("UIStroke")
floatStroke.Color = Color3.fromRGB(255, 200, 0)
floatStroke.Thickness = 1.5
floatStroke.Transparency = 0.5
floatStroke.Parent = floatingButton

-- === ГЛАВНОЕ ОКНО ===
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 320, 0, 460)
mainFrame.Position = UDim2.new(0.5, -160, 0.5, -230)
mainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 25)
mainFrame.BackgroundTransparency = 0.05
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 14)
corner.Parent = mainFrame

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(255, 200, 0)
stroke.Thickness = 2
stroke.Transparency = 0.25
stroke.Parent = mainFrame

-- === ВЕРХНЯЯ ПАНЕЛЬ ===
local headerFrame = Instance.new("Frame")
headerFrame.Size = UDim2.new(1, 0, 0, 55)
headerFrame.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
headerFrame.BackgroundTransparency = 0.8
headerFrame.BorderSizePixel = 0
headerFrame.Parent = mainFrame

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 14)
headerCorner.Parent = headerFrame

local icon = Instance.new("ImageLabel")
icon.Size = UDim2.new(0, 30, 0, 30)
icon.Position = UDim2.new(0.05, 0, 0.5, -15)
icon.BackgroundTransparency = 1
icon.Image = "rbxassetid://99615853578192"
icon.ScaleType = Enum.ScaleType.Fit
icon.Parent = headerFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(0.7, 0, 1, 0)
titleLabel.Position = UDim2.new(0.2, 0, 0, 0)
titleLabel.Text = lang.Title
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.BackgroundTransparency = 1
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 18
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = headerFrame

local subTitle = Instance.new("TextLabel")
subTitle.Size = UDim2.new(0.7, 0, 0.4, 0)
subTitle.Position = UDim2.new(0.2, 0, 0.6, 0)
subTitle.Text = lang.SubTitle
subTitle.TextColor3 = Color3.fromRGB(180, 180, 210)
subTitle.BackgroundTransparency = 1
subTitle.Font = Enum.Font.Gotham
subTitle.TextSize = 10
subTitle.TextXAlignment = Enum.TextXAlignment.Left
subTitle.Parent = headerFrame

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 28, 0, 28)
closeButton.Position = UDim2.new(1, -35, 0, 3)
closeButton.Text = "✕"
closeButton.TextColor3 = Color3.fromRGB(255, 150, 150)
closeButton.BackgroundTransparency = 1
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 18
closeButton.Parent = headerFrame

closeButton.MouseButton1Click:Connect(function()
    menuVisible = false
    mainFrame.Visible = false
    floatingButton.Visible = true
    clearRadar()
    clearESP()
end)

floatingButton.MouseButton1Click:Connect(function()
    menuVisible = true
    mainFrame.Visible = true
    floatingButton.Visible = false
    if CONFIG.RadarEnabled then updateRadar() end
    if CONFIG.ESPPlayers then updateESP() end
end)

-- === СТАТИСТИКА ===
local statsFrame = Instance.new("Frame")
statsFrame.Size = UDim2.new(0.9, 0, 0, 50)
statsFrame.Position = UDim2.new(0.05, 0, 0, 62)
statsFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 70)
statsFrame.BackgroundTransparency = 0.2
statsFrame.BorderSizePixel = 0
statsFrame.Parent = mainFrame

local statsCorner = Instance.new("UICorner")
statsCorner.CornerRadius = UDim.new(0, 8)
statsCorner.Parent = statsFrame

local coinIcon = Instance.new("ImageLabel")
coinIcon.Size = UDim2.new(0, 16, 0, 16)
coinIcon.Position = UDim2.new(0.04, 0, 0.2, -8)
coinIcon.BackgroundTransparency = 1
coinIcon.Image = "rbxassetid://6023426920"
coinIcon.ScaleType = Enum.ScaleType.Fit
coinIcon.Parent = statsFrame

local coinCount = Instance.new("TextLabel")
coinCount.Size = UDim2.new(0.45, 0, 0.5, 0)
coinCount.Position = UDim2.new(0.12, 0, 0.05, 0)
coinCount.Text = "0"
coinCount.TextColor3 = Color3.fromRGB(255, 215, 0)
coinCount.BackgroundTransparency = 1
coinCount.Font = Enum.Font.GothamBold
coinCount.TextSize = 14
coinCount.TextXAlignment = Enum.TextXAlignment.Left
coinCount.Parent = statsFrame

local coinLabel = Instance.new("TextLabel")
coinLabel.Size = UDim2.new(0.45, 0, 0.4, 0)
coinLabel.Position = UDim2.new(0.12, 0, 0.55, 0)
coinLabel.Text = lang.StatusCoins
coinLabel.TextColor3 = Color3.fromRGB(150, 150, 180)
coinLabel.BackgroundTransparency = 1
coinLabel.Font = Enum.Font.Gotham
coinLabel.TextSize = 9
coinLabel.TextXAlignment = Enum.TextXAlignment.Left
coinLabel.Parent = statsFrame

local candyIcon = Instance.new("ImageLabel")
candyIcon.Size = UDim2.new(0, 16, 0, 16)
candyIcon.Position = UDim2.new(0.52, 0, 0.2, -8)
candyIcon.BackgroundTransparency = 1
candyIcon.Image = "rbxassetid://6023426920"
candyIcon.ImageColor3 = Color3.fromRGB(255, 100, 150)
candyIcon.ScaleType = Enum.ScaleType.Fit
candyIcon.Parent = statsFrame

local candyCount = Instance.new("TextLabel")
candyCount.Size = UDim2.new(0.45, 0, 0.5, 0)
candyCount.Position = UDim2.new(0.6, 0, 0.05, 0)
candyCount.Text = "0"
candyCount.TextColor3 = Color3.fromRGB(255, 100, 150)
candyCount.BackgroundTransparency = 1
candyCount.Font = Enum.Font.GothamBold
candyCount.TextSize = 14
candyCount.TextXAlignment = Enum.TextXAlignment.Left
candyCount.Parent = statsFrame

local candyLabel = Instance.new("TextLabel")
candyLabel.Size = UDim2.new(0.45, 0, 0.4, 0)
candyLabel.Position = UDim2.new(0.6, 0, 0.55, 0)
candyLabel.Text = lang.StatusCandy
candyLabel.TextColor3 = Color3.fromRGB(150, 150, 180)
candyLabel.BackgroundTransparency = 1
candyLabel.Font = Enum.Font.Gotham
candyLabel.TextSize = 9
candyLabel.TextXAlignment = Enum.TextXAlignment.Left
candyLabel.Parent = statsFrame

-- === СТАТУС ===
local statusFrame = Instance.new("Frame")
statusFrame.Size = UDim2.new(0.9, 0, 0, 28)
statusFrame.Position = UDim2.new(0.05, 0, 0, 118)
statusFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 70)
statusFrame.BackgroundTransparency = 0.1
statusFrame.BorderSizePixel = 0
statusFrame.Parent = mainFrame

local statusCorner = Instance.new("UICorner")
statusCorner.CornerRadius = UDim.new(0, 8)
statusCorner.Parent = statusFrame

local statusDot = Instance.new("Frame")
statusDot.Size = UDim2.new(0, 8, 0, 8)
statusDot.Position = UDim2.new(0.04, 0, 0.5, -4)
statusDot.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
statusDot.BorderSizePixel = 0
statusDot.Parent = statusFrame

local statusDotCorner = Instance.new("UICorner")
statusDotCorner.CornerRadius = UDim.new(1, 0)
statusDotCorner.Parent = statusDot

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0.9, 0, 1, 0)
statusLabel.Position = UDim2.new(0.12, 0, 0, 0)
statusLabel.Text = lang.StatusStopped
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
statusLabel.BackgroundTransparency = 1
statusLabel.Font = Enum.Font.GothamBold
statusLabel.TextSize = 12
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = statusFrame

-- === СКОРОСТЬ ===
local speedFrame = Instance.new("Frame")
speedFrame.Size = UDim2.new(0.9, 0, 0, 55)
speedFrame.Position = UDim2.new(0.05, 0, 0, 152)
speedFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 70)
speedFrame.BackgroundTransparency = 0.15
speedFrame.BorderSizePixel = 0
speedFrame.Parent = mainFrame

local speedCorner = Instance.new("UICorner")
speedCorner.CornerRadius = UDim.new(0, 8)
speedCorner.Parent = speedFrame

local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(0.3, 0, 0.4, 0)
speedLabel.Position = UDim2.new(0.03, 0, 0.05, 0)
speedLabel.Text = lang.SpeedLabel
speedLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
speedLabel.BackgroundTransparency = 1
speedLabel.Font = Enum.Font.GothamBold
speedLabel.TextSize = 11
speedLabel.TextXAlignment = Enum.TextXAlignment.Left
speedLabel.Parent = speedFrame

local speedInput = Instance.new("TextBox")
speedInput.Size = UDim2.new(0.2, 0, 0.55, 0)
speedInput.Position = UDim2.new(0.77, 0, 0.25, 0)
speedInput.BackgroundColor3 = Color3.fromRGB(30, 30, 55)
speedInput.TextColor3 = Color3.fromRGB(255, 215, 0)
speedInput.BorderSizePixel = 0
speedInput.Font = Enum.Font.GothamBold
speedInput.TextSize = 14
speedInput.Text = "0.10"
speedInput.TextXAlignment = Enum.TextXAlignment.Center
speedInput.Parent = speedFrame

local inputCorner = Instance.new("UICorner")
inputCorner.CornerRadius = UDim.new(0, 6)
inputCorner.Parent = speedInput

local sliderBg = Instance.new("Frame")
sliderBg.Size = UDim2.new(0.45, 0, 0.3, 0)
sliderBg.Position = UDim2.new(0.28, 0, 0.35, 0)
sliderBg.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
sliderBg.BorderSizePixel = 0
sliderBg.Parent = speedFrame

local sliderBgCorner = Instance.new("UICorner")
sliderBgCorner.CornerRadius = UDim.new(1, 0)
sliderBgCorner.Parent = sliderBg

local sliderFill = Instance.new("Frame")
sliderFill.Size = UDim2.new(CONFIG.FarmSpeed, 0, 1, 0)
sliderFill.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
sliderFill.BorderSizePixel = 0
sliderFill.Parent = sliderBg

local sliderFillCorner = Instance.new("UICorner")
sliderFillCorner.CornerRadius = UDim.new(1, 0)
sliderFillCorner.Parent = sliderFill

local sliderButton = Instance.new("TextButton")
sliderButton.Size = UDim2.new(0, 16, 0, 16)
sliderButton.Position = UDim2.new(CONFIG.FarmSpeed, -8, 0.5, -8)
sliderButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
sliderButton.BorderSizePixel = 0
sliderButton.Text = ""
sliderButton.Parent = sliderBg

local sliderButtonCorner = Instance.new("UICorner")
sliderButtonCorner.CornerRadius = UDim.new(1, 0)
sliderButtonCorner.Parent = sliderButton

-- === ФУНКЦИЯ ОБНОВЛЕНИЯ СКОРОСТИ ===
local function updateSpeed(value)
    value = math.clamp(value, 0.01, 1.0)
    CONFIG.FarmSpeed = value
    speedInput.Text = string.format("%.2f", value)
    sliderFill.Size = UDim2.new(value, 0, 1, 0)
    sliderButton.Position = UDim2.new(value, -8, 0.5, -8)
end

-- === НАСТРОЙКА ПОЛЗУНКА ===
local function setupSlider()
    local dragging = false
    local connection = nil
    
    sliderButton.MouseButton1Down:Connect(function()
        dragging = true
        if connection then connection:Disconnect() end
        connection = userInputService.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
                local pos = input.Position.X - sliderBg.AbsolutePosition.X
                local width = sliderBg.AbsoluteSize.X
                local value = math.clamp(pos / width, 0, 1)
                updateSpeed(value)
            end
        end)
    end)
    
    userInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
            if connection then
                connection:Disconnect()
                connection = nil
            end
        end
    end)
    
    sliderBg.MouseButton1Click:Connect(function()
        local pos = userInputService:GetMouseLocation().X - sliderBg.AbsolutePosition.X
        local width = sliderBg.AbsoluteSize.X
        local value = math.clamp(pos / width, 0, 1)
        updateSpeed(value)
    end)
end

setupSlider()

speedInput.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        local val = tonumber(speedInput.Text)
        if val then
            val = math.clamp(val, 0.01, 1.0)
            updateSpeed(val)
        else
            speedInput.Text = string.format("%.2f", CONFIG.FarmSpeed)
        end
    end
end)

speedInput.Focused:Connect(function()
    speedInput.Text = ""
end)

-- === КНОПКА СТАРТ/СТОП (ОБЫЧНАЯ) ===
local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0.8, 0, 0, 40)
toggleButton.Position = UDim2.new(0.1, 0, 0, 215)
toggleButton.Text = lang.BtnStart
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
toggleButton.BorderSizePixel = 0
toggleButton.Font = Enum.Font.GothamBold
toggleButton.TextSize = 16
toggleButton.Parent = mainFrame

-- === ИНФОРМАЦИОННАЯ ПАНЕЛЬ ===
local infoFrame = Instance.new("Frame")
infoFrame.Size = UDim2.new(0.9, 0, 0, 70)
infoFrame.Position = UDim2.new(0.05, 0, 0, 268)
infoFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 55)
infoFrame.BackgroundTransparency = 0.2
infoFrame.BorderSizePixel = 0
infoFrame.Parent = mainFrame

local infoCorner = Instance.new("UICorner")
infoCorner.CornerRadius = UDim.new(0, 8)
infoCorner.Parent = infoFrame

local infoText = Instance.new("TextLabel")
infoText.Size = UDim2.new(1, -10, 1, -5)
infoText.Position = UDim2.new(0.02, 0, 0.02, 0)
infoText.Text = lang.InfoText
infoText.TextColor3 = Color3.fromRGB(180, 180, 210)
infoText.BackgroundTransparency = 1
infoText.Font = Enum.Font.Gotham
infoText.TextSize = 11
infoText.TextXAlignment = Enum.TextXAlignment.Left
infoText.TextYAlignment = Enum.TextYAlignment.Center
infoText.LineHeight = 1.2
infoText.Parent = infoFrame

-- === НИЖНЯЯ ЛИНИЯ ===
local footerLine = Instance.new("Frame")
footerLine.Size = UDim2.new(0.6, 0, 0, 1.5)
footerLine.Position = UDim2.new(0.2, 0, 0, 350)
footerLine.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
footerLine.BackgroundTransparency = 0.3
footerLine.BorderSizePixel = 0
footerLine.Parent = mainFrame

-- === ОСТАЛЬНЫЕ ФУНКЦИИ (РАДАР, ESP, KILL AURA, АНТИ-СТАН, АНТИ-ЧИТ) ===
local function clearRadar()
    for _, obj in pairs(espObjects) do
        if obj and obj.Parent then
            obj:Destroy()
        end
    end
    espObjects = {}
end

local function updateRadar()
    if not CONFIG.RadarEnabled then return end
    clearRadar()
    
    local coins = {}
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Part") or obj:IsA("MeshPart") then
            local name = obj.Name:lower()
            if CONFIG.FarmCandy then
                if name:find("candy") or name:find("sweet") then
                    table.insert(coins, obj)
                end
            end
            if name:find("coin") or name:find("money") or name:find("gold") or name:find("currency") then
                if CONFIG.IgnoreOwnCoins and obj:GetAttribute("Owner") == player.Name then
                    continue
                end
                table.insert(coins, obj)
            end
        end
    end
    
    for _, coin in ipairs(coins) do
        local esp = Instance.new("BillboardGui")
        esp.Size = UDim2.new(0, 25, 0, 25)
        esp.Adornee = coin
        esp.AlwaysOnTop = true
        esp.Parent = coin
        
        local dot = Instance.new("Frame")
        dot.Size = UDim2.new(1, 0, 1, 0)
        dot.BackgroundColor3 = CONFIG.RadarColor
        dot.BackgroundTransparency = 0.2
        dot.BorderSizePixel = 0
        dot.Parent = esp
        
        local dotCorner = Instance.new("UICorner")
        dotCorner.CornerRadius = UDim.new(1, 0)
        dotCorner.Parent = dot
        
        local glow = Instance.new("Frame")
        glow.Size = UDim2.new(2, 0, 2, 0)
        glow.Position = UDim2.new(-0.5, 0, -0.5, 0)
        glow.BackgroundColor3 = CONFIG.RadarColor
        glow.BackgroundTransparency = 0.7
        glow.BorderSizePixel = 0
        glow.Parent = esp
        
        local glowCorner = Instance.new("UICorner")
        glowCorner.CornerRadius = UDim.new(1, 0)
        glowCorner.Parent = glow
        
        table.insert(espObjects, esp)
        table.insert(espObjects, dot)
        table.insert(espObjects, glow)
    end
end

local function clearESP()
    for _, obj in pairs(espHighlights) do
        if obj and obj.Parent then
            obj:Destroy()
        end
    end
    espHighlights = {}
end

local function updateESP()
    if not CONFIG.ESPPlayers then return end
    clearESP()
    
    for _, p in pairs(players:GetPlayers()) do
        if p ~= player and p.Character then
            local char = p.Character
            local highlight = Instance.new("Highlight")
            highlight.Parent = char
            highlight.FillColor = Color3.fromRGB(255, 0, 0)
            highlight.FillTransparency = 0.3
            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            highlight.OutlineTransparency = 0
            
            if p:FindFirstChild("Backpack") and p.Backpack:FindFirstChild("Gun") then
                highlight.FillColor = Color3.fromRGB(0, 100, 255)
            end
            
            table.insert(espHighlights, highlight)
        end
    end
end

local function killAura()
    if not CONFIG.KillAura then return end
    local char = player.Character
    if not char then return end
    local rootPart = char:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    
    local target = nil
    local minDist = 20
    
    for _, p in pairs(players:GetPlayers()) do
        if p ~= player and p.Character then
            local pRoot = p.Character:FindFirstChild("HumanoidRootPart")
            if pRoot then
                local dist = (rootPart.Position - pRoot.Position).Magnitude
                if dist < minDist then
                    minDist = dist
                    target = p
                end
            end
        end
    end
    
    if target and target.Character then
        local hum = target.Character:FindFirstChild("Humanoid")
        if hum and hum.Health > 0 then
            local remote = replicatedStorage:FindFirstChild("KillPlayer")
            if remote then
                pcall(function()
                    remote:FireServer(target)
                end)
            end
            hum.Health = 0
        end
    end
end

local function antiStun()
    if not CONFIG.AntiStun then return end
    local char = player.Character
    if not char then return end
    local hum = char:FindFirstChild("Humanoid")
    if not hum then return end
    
    if hum.PlatformStand == true then
        hum.PlatformStand = false
    end
    
    for _, part in pairs(char:GetChildren()) do
        if part:IsA("BasePart") and part.Anchored == true then
            part.Anchored = false
        end
    end
end

local function autoBuySkins()
    if not CONFIG.AutoBuySkins then return end
    local shop = replicatedStorage:FindFirstChild("Shop") or workspace:FindFirstChild("Shop")
    if not shop then return end
    
    for _, item in pairs(shop:GetChildren()) do
        if item:IsA("Tool") or item:IsA("Model") then
            local price = item:FindFirstChild("Price")
            if price and price:IsA("IntValue") then
                local remote = replicatedStorage:FindFirstChild("BuyItem")
                if remote then
                    pcall(function()
                        remote:FireServer(item)
                    end)
                end
            end
        end
    end
end

local function antiCheatBypass()
    if math.random(1, 15) > 12 then
        local char = player.Character
        if char then
            local hum = char:FindFirstChild("Humanoid")
            if hum then
                local randomDir = math.random(0, 360)
                hum:MoveTo(hum.Parent.HumanoidRootPart.Position + Vector3.new(math.sin(randomDir), 0, math.cos(randomDir)) * 2)
            end
        end
    end
    wait(CONFIG.AntiCheatDelay * math.random(1, 3))
end

local function fastCollect(obj)
    local char = player.Character
    if not char then return end
    local rootPart = char:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    
    rootPart.CFrame = CFrame.new(obj.Position + Vector3.new(0, 2, 0))
    
    local remote = replicatedStorage:FindFirstChild("CollectItem")
    if remote then
        pcall(function()
            remote:FireServer(obj)
        end)
    end
    
    local touchEvent = obj:FindFirstChild("TouchEvent")
    if touchEvent then
        pcall(function()
            touchEvent:FireServer(player)
        end)
    end
    
    antiCheatBypass()
end

local function antiAFK()
    if not CONFIG.AntiAFK then return end
    pcall(function()
        virtualUser:CaptureController()
        virtualUser:ClickButton2(Vector2.new())
    end)
end

local function checkAlive()
    local char = player.Character
    if not char then return false end
    local hum = char:FindFirstChild("Humanoid")
    if not hum then return false end
    return hum.Health > 0
end

local function findItems()
    local items = {}
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Part") or obj:IsA("MeshPart") then
            local name = obj.Name:lower()
            if CONFIG.FarmCandy then
                if name:find("candy") or name:find("sweet") then
                    table.insert(items, {obj = obj, type = "candy"})
                end
            end
            if name:find("coin") or name:find("money") or name:find("gold") or name:find("currency") then
                if CONFIG.IgnoreOwnCoins and obj:GetAttribute("Owner") == player.Name then
                    continue
                end
                table.insert(items, {obj = obj, type = "coin"})
            end
        end
    end
    return items
end

local function stopFarmInternal()
    isFarming = false
    toggleButton.Text = lang.BtnStart
    toggleButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
    statusLabel.Text = lang.StatusStopped
    statusLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
    statusDot.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
    clearRadar()
    clearESP()
end

local function collectLoop()
    while isFarming do
        if CONFIG.RadarEnabled and menuVisible then
            updateRadar()
        end
        
        if CONFIG.ESPPlayers and menuVisible then
            updateESP()
        end
        
        if CONFIG.KillAura then
            killAura()
        end
        
        if CONFIG.AntiStun then
            antiStun()
        end
        
        if CONFIG.AutoBuySkins then
            autoBuySkins()
        end
        
        if not checkAlive() then
            isDead = true
            statusLabel.Text = lang.StatusDead
            statusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
            statusDot.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
            stopFarmInternal()
            break
        end
        
        local char = player.Character
        if not char then 
            wait(0.1)
            continue 
        end
        
        local rootPart = char:FindFirstChild("HumanoidRootPart")
        if not rootPart then 
            wait(0.1)
            continue 
        end
        
        local items = findItems()
        if #items == 0 then
            statusLabel.Text = lang.StatusNoCoins
            statusLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
            statusDot.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
            antiAFK()
            wait(0.5)
            continue
        end
        
        table.sort(items, function(a, b)
            local distA = (rootPart.Position - a.obj.Position).Magnitude
            local distB = (rootPart.Position - b.obj.Position).Magnitude
            return distA < distB
        end)
        
        local collected = 0
        local candyCollected = 0
        
        for _, item in ipairs(items) do
            if not isFarming then break end
            
            if not checkAlive() then
                isDead = true
                statusLabel.Text = lang.StatusDead
                statusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
                statusDot.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
                stopFarmInternal()
                return
            end
            
            local distance = (rootPart.Position - item.obj.Position).Magnitude
            
            if CONFIG.SuperSpeed then
                if distance <= CONFIG.CollectRadius then
                    fastCollect(item.obj)
                    if item.type == "candy" then
                        candyCollected = candyCollected + 1
                    else
                        collected = collected + 1
                    end
                    antiCheatBypass()
                    wait(CONFIG.FarmSpeed / 2)
                elseif CONFIG.TeleportToCoins then
                    rootPart.CFrame = CFrame.new(item.obj.Position + Vector3.new(0, 2, 0))
                    fastCollect(item.obj)
                    if item.type == "candy" then
                        candyCollected = candyCollected + 1
                    else
                        collected = collected + 1
                    end
                    antiCheatBypass()
                    wait(CONFIG.FarmSpeed / 2)
                end
            else
                if distance > CONFIG.CollectRadius and CONFIG.TeleportToCoins then
                    rootPart.CFrame = CFrame.new(item.obj.Position + Vector3.new(0, 3, 0))
                    wait(CONFIG.FarmSpeed)
                end
                
                if distance <= CONFIG.CollectRadius then
                    if distance > 5 then
                        rootPart.CFrame = CFrame.new(item.obj.Position + Vector3.new(0, 3, 0))
                    end
                    if item.type == "candy" then
                        candyCollected = candyCollected + 1
                    else
                        collected = collected + 1
                    end
                    wait(CONFIG.FarmSpeed)
                end
            end
            
            if math.random(1, 10) > 8 then
                wait(0.02)
            end
        end
        
        if collected > 0 or candyCollected > 0 then
            collectedCoins = collectedCoins + collected
            collectedCandy = collectedCandy + candyCollected
            coinCount.Text = collectedCoins
            candyCount.Text = collectedCandy
            
            local elapsed = os.time() - startTime
            if elapsed > 0 then
                coinsPerMinute = (collectedCoins / elapsed) * 60
                print(string.format("[MM2] Собрано монет: %d | Конфет: %d | За минуту: %.0f", collectedCoins, collectedCandy, coinsPerMinute))
            end
            
            statusLabel.Text = lang.StatusCollecting .. collected .. " монет, " .. candyCollected .. " конфет"
            statusLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
            statusDot.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
        end
        
        antiAFK()
        wait(0.1)
    end
end

-- === ТОГГЛЕ ФАРМА ===
local function toggleFarm()
    if not isFarming and not checkAlive() then
        statusLabel.Text = lang.StatusDead
        statusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
        statusDot.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        wait(0.5)
        statusLabel.Text = lang.StatusStopped
        statusLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
        statusDot.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
        return
    end
    
    isFarming = not isFarming
    isDead = false
    
    if isFarming then
        if not checkAlive() then
            isFarming = false
            statusLabel.Text = lang.StatusDead
            statusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
            statusDot.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
            wait(0.5)
            statusLabel.Text = lang.StatusStopped
            statusLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
            statusDot.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
            return
        end
        
        toggleButton.Text = lang.BtnStop
        toggleButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        statusLabel.Text = lang.StatusFarming
        statusLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
        statusDot.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
        collectedCoins = 0
        collectedCandy = 0
        coinCount.Text = "0"
        candyCount.Text = "0"
        startTime = os.time()
        
        if CONFIG.RadarEnabled and menuVisible then
            updateRadar()
        end
        
        if CONFIG.ESPPlayers and menuVisible then
            updateESP()
        end
        
        spawn(function()
            collectLoop()
        end)
    else
        stopFarmInternal()
        clearRadar()
        clearESP()
    end
end

-- === КНОПКА НАЖИМАЕТСЯ ===
toggleButton.MouseButton1Click:Connect(toggleFarm)

-- === ОТСЛЕЖИВАНИЕ СМЕРТИ ===
player.CharacterAdded:Connect(function()
    if isFarming then
        isFarming = false
        toggleButton.Text = lang.BtnStart
        toggleButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        statusLabel.Text = lang.StatusDead
        statusLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
        statusDot.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
        clearRadar()
        clearESP()
    end
end)

mainFrame:GetPropertyChangedSignal("Visible"):Connect(function()
    if mainFrame.Visible and CONFIG.RadarEnabled and isFarming then
        updateRadar()
    elseif not mainFrame.Visible then
        clearRadar()
        clearESP()
    end
end)

print("[MM2 Ultimate] by MrGlow загружен! Обычная кнопка работает.")
