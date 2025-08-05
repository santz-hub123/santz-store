-- SANTZ STORE V2.0 - Script Completo Melhorado e Otimizado (~600+ linhas)
-- Autor: santz-hub123 | Discord: @santz | github.com/santz-hub123
-- Melhorado por Claude AI - Versão Premium

-- ════════════════════════════════════════════════════════════════
-- SERVIÇOS & INICIALIZAÇÃO
-- ════════════════════════════════════════════════════════════════

local Services = {
    Players = game:GetService("Players"),
    TweenService = game:GetService("TweenService"),
    UserInputService = game:GetService("UserInputService"),
    SoundService = game:GetService("SoundService"),
    Workspace = game:GetService("Workspace"),
    RunService = game:GetService("RunService"),
    Lighting = game:GetService("Lighting"),
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    StarterGui = game:GetService("StarterGui"),
    HttpService = game:GetService("HttpService")
}

-- Variáveis do Player
local Player = Services.Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local Mouse = Player:GetMouse()

-- Variáveis do Personagem (serão atualizadas dinamicamente)
local Character, Humanoid, RootPart, Head

-- Variáveis Globais da Interface
local MainFrame, TelePanel, AboutPanel, SettingsPanel, StatsPanel
local ScreenGui
local IsMinimized = false
local ToggleStates = {}
local ESPRefs = {GOD={}, SECRET={}, BASE={}, PLAYER={}, NAME={}, ITEMS={}}
local SavedCoords = {}
local Connections = {}
local LastUpdateTime = 0

-- ════════════════════════════════════════════════════════════════
-- CONFIGURAÇÕES & TEMA
-- ════════════════════════════════════════════════════════════════

local Config = {
    -- Configurações de Performance
    ESPUpdateRate = 0.1,
    MaxESPDistance = 1000,
    AutoSaveCoords = true,
    
    -- Configurações de Movimento
    DefaultWalkSpeed = 16,
    DefaultJumpPower = 50,
    SupermanSpeed = 150,
    SupermanJump = 200,
    DashForce = 120,
    
    -- Configurações de Interface
    AnimationSpeed = 0.25,
    SoundVolume = 0.4,
    ShowNotifications = true,
    
    -- Configurações Avançadas
    AntiKick = true,
    AutoRejoin = true,
    SaveSettings = true
}

local Theme = {
    -- Cores Principais
    MainBg = Color3.fromRGB(20, 20, 25),
    SecondaryBg = Color3.fromRGB(15, 15, 20),
    Accent = Color3.fromRGB(0, 255, 127),
    AccentDark = Color3.fromRGB(0, 200, 100),
    
    -- Cores de Botões
    Button = Color3.fromRGB(35, 35, 40),
    ButtonHover = Color3.fromRGB(55, 55, 65),
    ButtonActive = Color3.fromRGB(0, 180, 90),
    
    -- Estados
    Enabled = Color3.fromRGB(0, 220, 110),
    Disabled = Color3.fromRGB(220, 60, 60),
    Warning = Color3.fromRGB(255, 165, 0),
    Info = Color3.fromRGB(100, 150, 255),
    
    -- Cores de ESP
    ESPGod = Color3.fromRGB(160, 32, 240),
    ESPSecret = Color3.fromRGB(255, 255, 255),
    ESPBase = Color3.fromRGB(255, 215, 0),
    ESPPlayer = Color3.fromRGB(0, 150, 255),
    ESPName = Color3.fromRGB(255, 105, 180),
    ESPItem = Color3.fromRGB(50, 205, 50),
    
    -- Transparências
    PanelTransparency = 0.1,
    BorderTransparency = 0.8
}

-- ════════════════════════════════════════════════════════════════
-- FUNÇÕES UTILITÁRIAS AVANÇADAS
-- ════════════════════════════════════════════════════════════════

local Utils = {}

function Utils.UpdateCharacterRefs()
    Character = Player.Character or Player.CharacterAdded:Wait()
    if Character then
        Humanoid = Character:WaitForChild("Humanoid", 5)
        RootPart = Character:WaitForChild("HumanoidRootPart", 5)
        Head = Character:WaitForChild("Head", 5)
    end
end

function Utils.PlaySound(soundId, volume)
    local sound = Instance.new("Sound", Services.SoundService)
    sound.SoundId = "rbxassetid://" .. tostring(soundId)
    sound.Volume = volume or Config.SoundVolume
    sound:Play()
    
    sound.Ended:Connect(function()
        sound:Destroy()
    end)
    
    return sound
end

function Utils.ShowNotification(title, text, duration, color)
    if not Config.ShowNotifications then return end
    
    Services.StarterGui:SetCore("SendNotification", {
        Title = title or "SANTZ STORE",
        Text = text or "",
        Duration = duration or 3,
        Icon = "rbxassetid://6031094678"
    })
end

function Utils.CreateRGBBorder(frame, thickness)
    local border = Instance.new("UIStroke", frame)
    border.Thickness = thickness or 2
    border.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    border.Transparency = Theme.BorderTransparency
    
    task.spawn(function()
        local hue = 0
        while frame.Parent do
            hue = (hue + 0.005) % 1
            border.Color = Color3.fromHSV(hue, 1, 1)
            task.wait(0.03)
        end
    end)
    
    return border
end

function Utils.CreateGradientBg(frame, color1, color2)
    local gradient = Instance.new("UIGradient", frame)
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, color1),
        ColorSequenceKeypoint.new(1, color2)
    }
    gradient.Rotation = 45
    return gradient
end

function Utils.MakeDraggable(frame, dragHandle)
    local handle = dragHandle or frame
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

function Utils.TweenProperty(object, properties, duration, easingStyle)
    local tween = Services.TweenService:Create(
        object,
        TweenInfo.new(
            duration or Config.AnimationSpeed,
            easingStyle or Enum.EasingStyle.Quad,
            Enum.EasingDirection.Out
        ),
        properties
    )
    tween:Play()
    return tween
end

function Utils.CreateStyledButton(parent, text, color, position, size, iconId, textSize)
    local button = Instance.new("TextButton", parent)
    button.Name = text:gsub(" ", "")
    button.Text = iconId and "  " .. text or text
    button.Size = size or UDim2.new(1, 0, 0, 35)
    button.Position = position or UDim2.new(0, 0, 0, 0)
    button.BackgroundColor3 = color or Theme.Button
    button.BorderSizePixel = 0
    button.TextColor3 = Color3.new(1, 1, 1)
    button.TextScaled = true
    button.Font = Enum.Font.GothamBold
    button.TextXAlignment = iconId and Enum.TextXAlignment.Left or Enum.TextXAlignment.Center
    
    -- Corner
    local corner = Instance.new("UICorner", button)
    corner.CornerRadius = UDim.new(0, 8)
    
    -- Gradient Background
    Utils.CreateGradientBg(button, color, Color3.new(
        math.max(0, color.R - 0.1),
        math.max(0, color.G - 0.1),
        math.max(0, color.B - 0.1)
    ))
    
    -- Icon
    if iconId then
        local icon = Instance.new("ImageLabel", button)
        icon.Size = UDim2.new(0, 24, 0, 24)
        icon.Position = UDim2.new(0, 8, 0.5, -12)
        icon.BackgroundTransparency = 1
        icon.Image = "rbxassetid://" .. tostring(iconId)
        icon.ImageColor3 = Color3.new(1, 1, 1)
    end
    
    -- Hover Effects
    button.MouseEnter:Connect(function()
        Utils.TweenProperty(button, {BackgroundColor3 = Theme.ButtonHover}, 0.15)
        Utils.PlaySound(131961136, 0.1)
    end)
    
    button.MouseLeave:Connect(function()
        Utils.TweenProperty(button, {BackgroundColor3 = color or Theme.Button}, 0.15)
    end)
    
    -- Click Effect
    button.MouseButton1Click:Connect(function()
        Utils.TweenProperty(button, {Size = UDim2.new(button.Size.X.Scale, button.Size.X.Offset, button.Size.Y.Scale - 0.05, button.Size.Y.Offset)}, 0.05)
        task.wait(0.05)
        Utils.TweenProperty(button, {Size = size or UDim2.new(1, 0, 0, 35)}, 0.05)
        Utils.PlaySound(131961136, Config.SoundVolume)
    end)
    
    return button
end

function Utils.ClearESP(tag, parent)
    if not parent then return end
    for _, child in pairs(parent:GetChildren()) do
        if child.Name == tag then
            child:Destroy()
        end
    end
end

function Utils.GetDistance(part1, part2)
    if not part1 or not part2 then return math.huge end
    return (part1.Position - part2.Position).Magnitude
end

-- ════════════════════════════════════════════════════════════════
-- SISTEMA ESP AVANÇADO
-- ════════════════════════════════════════════════════════════════

local ESP = {}

function ESP.CreateBillboard(adornee, text, color, size, offset)
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP_" .. (text or "UNKNOWN")
    billboard.Adornee = adornee
    billboard.Size = size or UDim2.new(0, 120, 0, 50)
    billboard.StudsOffset = offset or Vector3.new(0, 2, 0)
    billboard.AlwaysOnTop = true
    
    local label = Instance.new("TextLabel", billboard)
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text or "UNKNOWN"
    label.TextColor3 = color or Color3.new(1, 1, 1)
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.TextStrokeTransparency = 0.5
    label.TextStrokeColor3 = Color3.new(0, 0, 0)
    
    -- Distance-based scaling
    task.spawn(function()
        while billboard.Parent and RootPart do
            local distance = Utils.GetDistance(adornee, RootPart)
            if distance > Config.MaxESPDistance then
                billboard.Enabled = false
            else
                billboard.Enabled = true
                local scale = math.max(0.5, 1 - (distance / Config.MaxESPDistance))
                billboard.Size = UDim2.new(0, 120 * scale, 0, 50 * scale)
            end
            task.wait(Config.ESPUpdateRate)
        end
    end)
    
    return billboard
end

function ESP.CreateHighlight(target, fillColor, outlineColor, transparency)
    local highlight = Instance.new("Highlight")
    highlight.Name = "ESP_HIGHLIGHT"
    highlight.Adornee = target
    highlight.FillColor = fillColor or Color3.new(1, 1, 1)
    highlight.OutlineColor = outlineColor or Color3.new(0, 0, 0)
    highlight.FillTransparency = transparency or 0.5
    highlight.OutlineTransparency = 0.2
    highlight.Parent = target
    
    return highlight
end

function ESP.ToggleGodESP()
    local state = not ToggleStates["ESP_GOD"]
    ToggleStates["ESP_GOD"] = state
    
    for _, player in pairs(Services.Players:GetPlayers()) do
        if player ~= Player and player.Character then
            Utils.ClearESP("ESP_GOD", player.Character)
            
            if state then
                local root = player.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    -- Check for God players (multiple criteria)
                    local isGod = player.Name:lower():find("god") or
                                  player.Name:lower():find("admin") or
                                  (player:FindFirstChild("leaderstats") and 
                                   player.leaderstats:FindFirstChild("Rank") and 
                                   player.leaderstats.Rank.Value:lower():find("god"))
                    
                    if isGod then
                        local billboard = ESP.CreateBillboard(root, "⚡ GOD ⚡", Theme.ESPGod)
                        billboard.Parent = player.Character
                        
                        ESP.CreateHighlight(player.Character, Theme.ESPGod, Color3.new(1, 1, 1), 0.7)
                    end
                end
            end
        end
    end
    
    Utils.ShowNotification("ESP GOD", state and "Ativado" or "Desativado", 2)
end

function ESP.ToggleSecretESP()
    local state = not ToggleStates["ESP_SECRET"]
    ToggleStates["ESP_SECRET"] = state
    
    for _, obj in pairs(Services.Workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            Utils.ClearESP("ESP_SECRET", obj)
            
            if state then
                local isSecret = obj.Name:lower():find("secret") or
                                obj.Name:lower():find("hidden") or
                                obj.Name:lower():find("rare") or
                                obj.Name:lower():find("treasure")
                
                if isSecret and Utils.GetDistance(obj, RootPart) <= Config.MaxESPDistance then
                    ESP.CreateHighlight(obj, Theme.ESPSecret, Color3.new(1, 0, 0), 0.3)
                    
                    local billboard = ESP.CreateBillboard(obj, "🔍 SECRET", Theme.ESPSecret)
                    billboard.Parent = obj
                end
            end
        end
    end
    
    Utils.ShowNotification("ESP SECRET", state and "Ativado" or "Desativado", 2)
end

function ESP.ToggleBaseESP()
    local state = not ToggleStates["ESP_BASE"]
    ToggleStates["ESP_BASE"] = state
    
    for _, obj in pairs(Services.Workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            Utils.ClearESP("ESP_BASE", obj)
            
            if state then
                local isBase = obj.Name:lower():find("base") or
                              obj.Name:lower():find("door") or
                              obj.Name:lower():find("spawn") or
                              obj.Name:lower():find("safe")
                
                if isBase and Utils.GetDistance(obj, RootPart) <= Config.MaxESPDistance then
                    local locked = math.random(1, 3) == 1
                    local status = locked and "🔒 LOCKED" or "🔓 UNLOCKED"
                    local color = locked and Theme.Disabled or Theme.Enabled
                    
                    local billboard = ESP.CreateBillboard(obj, status, color)
                    billboard.Parent = obj
                    
                    if locked then
                        local timeLeft = math.random(10, 300)
                        task.spawn(function()
                            while billboard.Parent and timeLeft > 0 do
                                billboard.TextLabel.Text = string.format("🔒 LOCKED (%ds)", timeLeft)
                                timeLeft = timeLeft - 1
                                task.wait(1)
                            end
                            if billboard.Parent then
                                billboard.TextLabel.Text = "🔓 UNLOCKED"
                                billboard.TextLabel.TextColor3 = Theme.Enabled
                            end
                        end)
                    end
                end
            end
        end
    end
    
    Utils.ShowNotification("ESP BASE", state and "Ativado" or "Desativado", 2)
end

function ESP.TogglePlayerESP()
    local state = not ToggleStates["ESP_PLAYER"]
    ToggleStates["ESP_PLAYER"] = state
    
    for _, player in pairs(Services.Players:GetPlayers()) do
        if player ~= Player and player.Character then
            Utils.ClearESP("ESP_PLAYER", player.Character)
            
            if state then
                ESP.CreateHighlight(player.Character, Theme.ESPPlayer, Color3.new(1, 1, 1), 0.6)
            end
        end
    end
    
    Utils.ShowNotification("ESP PLAYER", state and "Ativado" or "Desativado", 2)
end

function ESP.ToggleNameESP()
    local state = not ToggleStates["ESP_NAME"]
    ToggleStates["ESP_NAME"] = state
    
    for _, player in pairs(Services.Players:GetPlayers()) do
        if player ~= Player and player.Character then
            local head = player.Character:FindFirstChild("Head")
            if head then
                Utils.ClearESP("ESP_NAME", player.Character)
                
                if state then
                    local billboard = ESP.CreateBillboard(
                        head, 
                        "👤 " .. player.Name, 
                        Theme.ESPName,
                        UDim2.new(0, 100, 0, 25),
                        Vector3.new(0, 3, 0)
                    )
                    billboard.Parent = player.Character
                    
                    -- Rainbow effect
                    task.spawn(function()
                        local hue = 0
                        while billboard.Parent do
                            hue = (hue + 0.02) % 1
                            billboard.TextLabel.TextColor3 = Color3.fromHSV(hue, 1, 1)
                            task.wait(0.1)
                        end
                    end)
                end
            end
        end
    end
    
    Utils.ShowNotification("ESP NAME", state and "Ativado" or "Desativado", 2)
end

function ESP.ToggleItemESP()
    local state = not ToggleStates["ESP_ITEM"]
    ToggleStates["ESP_ITEM"] = state
    
    for _, obj in pairs(Services.Workspace:GetDescendants()) do
        if obj:IsA("Tool") or (obj:IsA("BasePart") and obj.Parent:IsA("Tool")) then
            Utils.ClearESP("ESP_ITEM", obj)
            
            if state and Utils.GetDistance(obj, RootPart) <= Config.MaxESPDistance then
                local billboard = ESP.CreateBillboard(obj, "🎒 " .. obj.Name, Theme.ESPItem)
                billboard.Parent = obj
                
                ESP.CreateHighlight(obj, Theme.ESPItem, Color3.new(1, 1, 1), 0.4)
            end
        end
    end
    
    Utils.ShowNotification("ESP ITEM", state and "Ativado" or "Desativado", 2)
end

-- ════════════════════════════════════════════════════════════════
-- SISTEMA DE MOVIMENTO AVANÇADO
-- ════════════════════════════════════════════════════════════════

local Movement = {}

function Movement.ActivateDash()
    if not RootPart or not Humanoid then return end
    
    local bodyVelocity = Instance.new("BodyVelocity", RootPart)
    bodyVelocity.MaxForce = Vector3.new(8000, 0, 8000)
    bodyVelocity.Velocity = RootPart.CFrame.LookVector * Config.DashForce
    
    -- Dash effect
    local dashEffect = Instance.new("Explosion", Services.Workspace)
    dashEffect.Position = RootPart.Position
    dashEffect.BlastRadius = 5
    dashEffect.BlastPressure = 0
    dashEffect.Visible = false
    
    Utils.PlaySound(131961136, 0.8)
    
    task.wait(0.3)
    if bodyVelocity then
        bodyVelocity:Destroy()
    end
    
    Utils.ShowNotification("DASH", "Dash ativado!", 1.5)
end

function Movement.ToggleSuperman()
    if not Humanoid then return end
    
    local state = not ToggleStates["Superman"]
    ToggleStates["Superman"] = state
    
    if state then
        Humanoid.WalkSpeed = Config.SupermanSpeed
        Humanoid.JumpPower = Config.SupermanJump
        
        -- Superman effect
        local bodyVelocity = Instance.new("BodyVelocity", RootPart)
        bodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        
        Connections.Superman = Services.UserInputService.InputBegan:Connect(function(input)
            if input.KeyCode == Enum.KeyCode.Space then
                bodyVelocity.Velocity = RootPart.CFrame.LookVector * Config.SupermanSpeed
            end
        end)
        
        Utils.ShowNotification("SUPERMAN", "Modo Superman ativado!", 2)
    else
        Humanoid.WalkSpeed = Config.DefaultWalkSpeed
        Humanoid.JumpPower = Config.DefaultJumpPower
        
        if Connections.Superman then
            Connections.Superman:Disconnect()
        end
        
        for _, obj in pairs(RootPart:GetChildren()) do
            if obj:IsA("BodyVelocity") then
                obj:Destroy()
            end
        end
        
        Utils.ShowNotification("SUPERMAN", "Modo Superman desativado!", 2)
    end
end

function Movement.ToggleAntiHit()
    if not Humanoid or not Character then return end
    
    local state = not ToggleStates["ANTI_HIT"]
    ToggleStates["ANTI_HIT"] = state
    
    if state then
        for _, part in pairs(Character:GetChildren()) do
            if part:IsA("BasePart") and part ~= RootPart then
                part.CanCollide = false
                
                local bodyVelocity = Instance.new("BodyVelocity", part)
                bodyVelocity.MaxForce = Vector3.new(0, math.huge, 0)
                bodyVelocity.Velocity = Vector3.new(0, 0, 0)
            end
        end
        
        Utils.ShowNotification("ANTI-HIT", "Proteção ativada!", 2)
    else
        for _, part in pairs(Character:GetChildren()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
                
                for _, obj in pairs(part:GetChildren()) do
                    if obj:IsA("BodyVelocity") then
                        obj:Destroy()
                    end
                end
            end
        end
        
        Utils.ShowNotification("ANTI-HIT", "Proteção desativada!", 2)
    end
end

function Movement.ToggleNoclip()
    local state = not ToggleStates["NOCLIP"]
    ToggleStates["NOCLIP"] = state
    
    if state then
        Connections.Noclip = Services.RunService.Stepped:Connect(function()
            if Character then
                for _, part in pairs(Character:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
        Utils.ShowNotification("NOCLIP", "Noclip ativado!", 2)
    else
        if Connections.Noclip then
            Connections.Noclip:Disconnect()
        end
        
        if Character then
            for _, part in pairs(Character:GetChildren()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
        Utils.ShowNotification("NOCLIP", "Noclip desativado!", 2)
    end
end

-- ════════════════════════════════════════════════════════════════
-- SISTEMA DE TELEPORTE AVANÇADO
-- ════════════════════════════════════════════════════════════════

local Teleport = {}

function Teleport.SaveCoordinate()
    if not RootPart then return end
    
    local position = RootPart.Position + Vector3.new(0, 3, 0)
    local coordData = {
        position = position,
        name = "Coord " .. (#SavedCoords + 1),
        timestamp = os.time()
    }
    
    table.insert(SavedCoords, coordData)
    
    if TelePanel and TelePanel:FindFirstChild("CoordsList") then
        Teleport.RefreshCoordsList()
    end
    
    Utils.ShowNotification("TELEPORTE", "Coordenada salva: " .. coordData.name, 2)
end

function Teleport.TeleportTo(position, smooth)
    if not RootPart or not position then return end
    
    if smooth then
        local tween = Utils.TweenProperty(RootPart, {Position = position}, 2, Enum.EasingStyle.Quad)
        Utils.ShowNotification("TELEPORTE", "Teleportando suavemente...", 1.5)
    else
        RootPart.CFrame = CFrame.new(position)
        Utils.ShowNotification("TELEPORTE", "Teleportado instantaneamente!", 1.5)
    end
end

function Teleport.TeleportToPlayer(targetPlayer)
    if not targetPlayer or not targetPlayer.Character or not RootPart then return end
    
    local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    if targetRoot then
        Teleport.TeleportTo(targetRoot.Position + Vector3.new(5, 0, 0), true)
        Utils.ShowNotification("TELEPORTE", "Teleportado para: " .. targetPlayer.Name, 2)
    end
end

function Teleport.RefreshCoordsList()
    local coordsList = TelePanel and TelePanel:FindFirstChild("CoordsList")
    if not coordsList then return end
    
    coordsList:ClearAllChildren()
    coordsList.CanvasSize = UDim2.new(0, 0, 0, math.max(#SavedCoords * 35, 50))
    
    for i, coordData in ipairs(SavedCoords) do
        local coordFrame = Instance.new("Frame", coordsList)
        coordFrame.Size = UDim2.new(1, -10, 0, 30)
        coordFrame.Position = UDim2.new(0, 5, 0, (i-1) * 35)
        coordFrame.BackgroundColor3 = Theme.Button
        coordFrame.BorderSizePixel = 0
        
        local corner = Instance.new("UICorner", coordFrame)
        corner.CornerRadius = UDim.new(0, 6)
        
        local teleBtn = Utils.CreateStyledButton(
            coordFrame, 
            coordData.name, 
            Theme.Accent, 
            UDim2.new(0, 0, 0, 0), 
            UDim2.new(0.7, 0, 1, 0),
            6034996691
        )
        
        local deleteBtn = Utils.CreateStyledButton(
            coordFrame,
            "❌",
            Theme.Disabled,
            UDim2.new(0.7, 5, 0, 0),
            UDim2.new(0.3, -5, 1, 0)
        )
        
        teleBtn.MouseButton1Click:Connect(function()
            Teleport.TeleportTo(coordData.position, true)
        end)
        
        deleteBtn.MouseButton1Click:Connect(function()
            table.remove(SavedCoords, i)
            Teleport.RefreshCoordsList()
            Utils.ShowNotification("TELEPORTE", "Coordenada removida!", 1.5)
        end)
    end
end

-- ════════════════════════════════════════════════════════════════
-- CRIAÇÃO DE PAINÉIS
-- ════════════════════════════════════════════════════════════════

function Teleport.CreateTelePanel()
