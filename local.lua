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
    TelePanel = Instance.new("Frame", ScreenGui)
    TelePanel.Name = "TelePanel"
    TelePanel.Size = UDim2.new(0, 280, 0, 350)
    TelePanel.Position = UDim2.new(1, -300, 0.5, -175)
    TelePanel.BackgroundColor3 = Theme.SecondaryBg
    TelePanel.BackgroundTransparency = Theme.PanelTransparency
    TelePanel.BorderSizePixel = 0
    TelePanel.Active = true
    TelePanel.Visible = false
    TelePanel.ZIndex = 2
    
    local corner = Instance.new("UICorner", TelePanel)
    corner.CornerRadius = UDim.new(0, 12)
    
    Utils.CreateRGBBorder(TelePanel, 3)
    Utils.MakeDraggable(TelePanel)
    
    -- Gradient Background
    Utils.CreateGradientBg(TelePanel, Theme.SecondaryBg, Theme.MainBg)
    
    -- Title
    local title = Instance.new("TextLabel", TelePanel)
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundTransparency = 1
    title.Text = "🚀 PAINEL DE TELEPORTE"
    title.TextColor3 = Theme.Accent
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.ZIndex = 3
    
    -- Close Button
    local closeBtn = Utils.CreateStyledButton(TelePanel, "❌", Theme.Disabled, UDim2.new(1, -35, 0, 5), UDim2.new(0, 30, 0, 30))
    closeBtn.ZIndex = 3
    closeBtn.MouseButton1Click:Connect(function()
        TelePanel.Visible = false
    end)
    
    -- Save Coordinate Button
    local saveBtn = Utils.CreateStyledButton(
        TelePanel, 
        "💾 SALVAR POSIÇÃO", 
        Theme.Enabled, 
        UDim2.new(0, 10, 0, 50), 
        UDim2.new(1, -20, 0, 35),
        6023426925
    )
    saveBtn.ZIndex = 3
    saveBtn.MouseButton1Click:Connect(Teleport.SaveCoordinate)
    
    -- Player Teleport Section
    local playerLabel = Instance.new("TextLabel", TelePanel)
    playerLabel.Size = UDim2.new(1, 0, 0, 25)
    playerLabel.Position = UDim2.new(0, 10, 0, 95)
    playerLabel.BackgroundTransparency = 1
    playerLabel.Text = "👥 TELEPORTE PARA PLAYERS:"
    playerLabel.TextColor3 = Color3.new(1, 1, 1)
    playerLabel.TextScaled = true
    playerLabel.Font = Enum.Font.GothamBold
    playerLabel.TextXAlignment = Enum.TextXAlignment.Left
    playerLabel.ZIndex = 3
    
    local playersList = Instance.new("ScrollingFrame", TelePanel)
    playersList.Size = UDim2.new(1, -20, 0, 80)
    playersList.Position = UDim2.new(0, 10, 0, 125)
    playersList.BackgroundColor3 = Theme.MainBg
    playersList.BackgroundTransparency = 0.3
    playersList.BorderSizePixel = 0
    playersList.ScrollBarThickness = 6
    playersList.CanvasSize = UDim2.new(0, 0, 0, 0)
    playersList.ZIndex = 3
    
    local playersCorner = Instance.new("UICorner", playersList)
    playersCorner.CornerRadius = UDim.new(0, 8)
    
    -- Coordinates List Label
    local coordLabel = Instance.new("TextLabel", TelePanel)
    coordLabel.Size = UDim2.new(1, 0, 0, 25)
    coordLabel.Position = UDim2.new(0, 10, 0, 215)
    coordLabel.BackgroundTransparency = 1
    coordLabel.Text = "📍 COORDENADAS SALVAS:"
    coordLabel.TextColor3 = Color3.new(1, 1, 1)
    coordLabel.TextScaled = true
    coordLabel.Font = Enum.Font.GothamBold
    coordLabel.TextXAlignment = Enum.TextXAlignment.Left
    coordLabel.ZIndex = 3
    
    -- Coordinates List
    local coordsList = Instance.new("ScrollingFrame", TelePanel)
    coordsList.Name = "CoordsList"
    coordsList.Size = UDim2.new(1, -20, 0, 100)
    coordsList.Position = UDim2.new(0, 10, 0, 245)
    coordsList.BackgroundColor3 = Theme.MainBg
    coordsList.BackgroundTransparency = 0.3
    coordsList.BorderSizePixel = 0
    coordsList.ScrollBarThickness = 6
    coordsList.CanvasSize = UDim2.new(0, 0, 0, 0)
    coordsList.ZIndex = 3
    
    local coordsCorner = Instance.new("UICorner", coordsList)
    coordsCorner.CornerRadius = UDim.new(0, 8)
    
    -- Update players list
    local function updatePlayersList()
        playersList:ClearAllChildren()
        local players = Services.Players:GetPlayers()
        playersList.CanvasSize = UDim2.new(0, 0, 0, #players * 35)
        
        for i, player in ipairs(players) do
            if player ~= Player then
                local playerBtn = Utils.CreateStyledButton(
                    playersList,
                    "🏃 " .. player.Name,
                    Theme.Info,
                    UDim2.new(0, 5, 0, (i-1) * 35),
                    UDim2.new(1, -10, 0, 30)
                )
                playerBtn.ZIndex = 4
                playerBtn.MouseButton1Click:Connect(function()
                    Teleport.TeleportToPlayer(player)
                end)
            end
        end
    end
    
    -- Update players list every 3 seconds
    task.spawn(function()
        while TelePanel.Parent do
            if TelePanel.Visible then
                updatePlayersList()
            end
            task.wait(3)
        end
    end)
    
    Teleport.RefreshCoordsList()
end

-- ════════════════════════════════════════════════════════════════
-- PAINEL DE CONFIGURAÇÕES
-- ════════════════════════════════════════════════════════════════

local function CreateSettingsPanel()
    SettingsPanel = Instance.new("Frame", ScreenGui)
    SettingsPanel.Name = "SettingsPanel"
    SettingsPanel.Size = UDim2.new(0, 300, 0, 400)
    SettingsPanel.Position = UDim2.new(0.5, -150, 0.5, -200)
    SettingsPanel.BackgroundColor3 = Theme.SecondaryBg
    SettingsPanel.BackgroundTransparency = Theme.PanelTransparency
    SettingsPanel.BorderSizePixel = 0
    SettingsPanel.Active = true
    SettingsPanel.Visible = false
    SettingsPanel.ZIndex = 5
    
    local corner = Instance.new("UICorner", SettingsPanel)
    corner.CornerRadius = UDim.new(0, 15)
    
    Utils.CreateRGBBorder(SettingsPanel, 3)
    Utils.MakeDraggable(SettingsPanel)
    Utils.CreateGradientBg(SettingsPanel, Theme.SecondaryBg, Theme.MainBg)
    
    -- Title
    local title = Instance.new("TextLabel", SettingsPanel)
    title.Size = UDim2.new(1, 0, 0, 50)
    title.BackgroundTransparency = 1
    title.Text = "⚙️ CONFIGURAÇÕES"
    title.TextColor3 = Theme.Accent
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.ZIndex = 6
    
    -- Close Button
    local closeBtn = Utils.CreateStyledButton(SettingsPanel, "❌", Theme.Disabled, UDim2.new(1, -40, 0, 5), UDim2.new(0, 35, 0, 35))
    closeBtn.ZIndex = 6
    closeBtn.MouseButton1Click:Connect(function()
        SettingsPanel.Visible = false
    end)
    
    -- Settings Content
    local scrollFrame = Instance.new("ScrollingFrame", SettingsPanel)
    scrollFrame.Size = UDim2.new(1, -20, 1, -70)
    scrollFrame.Position = UDim2.new(0, 10, 0, 60)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 8
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 600)
    scrollFrame.ZIndex = 6
    
    local yPos = 10
    
    -- Speed Settings
    local speedLabel = Instance.new("TextLabel", scrollFrame)
    speedLabel.Size = UDim2.new(1, -20, 0, 30)
    speedLabel.Position = UDim2.new(0, 10, 0, yPos)
    speedLabel.BackgroundTransparency = 1
    speedLabel.Text = "🏃 Velocidade Superman: " .. Config.SupermanSpeed
    speedLabel.TextColor3 = Color3.new(1, 1, 1)
    speedLabel.TextScaled = true
    speedLabel.Font = Enum.Font.Gotham
    speedLabel.TextXAlignment = Enum.TextXAlignment.Left
    speedLabel.ZIndex = 7
    
    yPos = yPos + 40
    
    local speedSlider = Instance.new("Frame", scrollFrame)
    speedSlider.Size = UDim2.new(1, -40, 0, 20)
    speedSlider.Position = UDim2.new(0, 20, 0, yPos)
    speedSlider.BackgroundColor3 = Theme.Button
    speedSlider.BorderSizePixel = 0
    speedSlider.ZIndex = 7
    
    local sliderCorner = Instance.new("UICorner", speedSlider)
    sliderCorner.CornerRadius = UDim.new(0, 10)
    
    -- Add more settings here...
    yPos = yPos + 60
    
    -- Notification Toggle
    local notifBtn = Utils.CreateStyledButton(
        scrollFrame,
        Config.ShowNotifications and "🔔 Notificações: ON" or "🔕 Notificações: OFF",
        Config.ShowNotifications and Theme.Enabled or Theme.Disabled,
        UDim2.new(0, 10, 0, yPos),
        UDim2.new(1, -20, 0, 35)
    )
    notifBtn.ZIndex = 7
    notifBtn.MouseButton1Click:Connect(function()
        Config.ShowNotifications = not Config.ShowNotifications
        notifBtn.Text = Config.ShowNotifications and "🔔 Notificações: ON" or "🔕 Notificações: OFF"
        notifBtn.BackgroundColor3 = Config.ShowNotifications and Theme.Enabled or Theme.Disabled
    end)
    
    yPos = yPos + 50
    
    -- Auto Rejoin Toggle
    local rejoinBtn = Utils.CreateStyledButton(
        scrollFrame,
        Config.AutoRejoin and "🔄 Auto Rejoin: ON" or "🔄 Auto Rejoin: OFF",
        Config.AutoRejoin and Theme.Enabled or Theme.Disabled,
        UDim2.new(0, 10, 0, yPos),
        UDim2.new(1, -20, 0, 35)
    )
    rejoinBtn.ZIndex = 7
    rejoinBtn.MouseButton1Click:Connect(function()
        Config.AutoRejoin = not Config.AutoRejoin
        rejoinBtn.Text = Config.AutoRejoin and "🔄 Auto Rejoin: ON" or "🔄 Auto Rejoin: OFF"
        rejoinBtn.BackgroundColor3 = Config.AutoRejoin and Theme.Enabled or Theme.Disabled
    end)
end

-- ════════════════════════════════════════════════════════════════
-- PAINEL DE ESTATÍSTICAS
-- ════════════════════════════════════════════════════════════════

local function CreateStatsPanel()
    StatsPanel = Instance.new("Frame", ScreenGui)
    StatsPanel.Name = "StatsPanel"
    StatsPanel.Size = UDim2.new(0, 250, 0, 300)
    StatsPanel.Position = UDim2.new(0, 20, 0.5, -150)
    StatsPanel.BackgroundColor3 = Theme.SecondaryBg
    StatsPanel.BackgroundTransparency = Theme.PanelTransparency
    StatsPanel.BorderSizePixel = 0
    StatsPanel.Active = true
    StatsPanel.Visible = false
    StatsPanel.ZIndex = 3
    
    local corner = Instance.new("UICorner", StatsPanel)
    corner.CornerRadius = UDim.new(0, 12)
    
    Utils.CreateRGBBorder(StatsPanel, 3)
    Utils.MakeDraggable(StatsPanel)
    Utils.CreateGradientBg(StatsPanel, Theme.SecondaryBg, Theme.MainBg)
    
    -- Title
    local title = Instance.new("TextLabel", StatsPanel)
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundTransparency = 1
    title.Text = "📊 ESTATÍSTICAS"
    title.TextColor3 = Theme.Accent
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.ZIndex = 4
    
    -- Close Button
    local closeBtn = Utils.CreateStyledButton(StatsPanel, "❌", Theme.Disabled, UDim2.new(1, -35, 0, 5), UDim2.new(0, 30, 0, 30))
    closeBtn.ZIndex = 4
    closeBtn.MouseButton1Click:Connect(function()
        StatsPanel.Visible = false
    end)
    
    -- Stats Content
    local statsFrame = Instance.new("Frame", StatsPanel)
    statsFrame.Size = UDim2.new(1, -20, 1, -60)
    statsFrame.Position = UDim2.new(0, 10, 0, 50)
    statsFrame.BackgroundTransparency = 1
    statsFrame.ZIndex = 4
    
    -- FPS Counter
    local fpsLabel = Instance.new("TextLabel", statsFrame)
    fpsLabel.Size = UDim2.new(1, 0, 0, 30)
    fpsLabel.Position = UDim2.new(0, 0, 0, 10)
    fpsLabel.BackgroundTransparency = 1
    fpsLabel.Text = "🖥️ FPS: 60"
    fpsLabel.TextColor3 = Color3.new(1, 1, 1)
    fpsLabel.TextScaled = true
    fpsLabel.Font = Enum.Font.Gotham
    fpsLabel.TextXAlignment = Enum.TextXAlignment.Left
    fpsLabel.ZIndex = 5
    
    -- Ping Counter
    local pingLabel = Instance.new("TextLabel", statsFrame)
    pingLabel.Size = UDim2.new(1, 0, 0, 30)
    pingLabel.Position = UDim2.new(0, 0, 0, 50)
    pingLabel.BackgroundTransparency = 1
    pingLabel.Text = "🌐 Ping: 0ms"
    pingLabel.TextColor3 = Color3.new(1, 1, 1)
    pingLabel.TextScaled = true
    pingLabel.Font = Enum.Font.Gotham
    pingLabel.TextXAlignment = Enum.TextXAlignment.Left
    pingLabel.ZIndex = 5
    
    -- Player Count
    local playersLabel = Instance.new("TextLabel", statsFrame)
    playersLabel.Size = UDim2.new(1, 0, 0, 30)
    playersLabel.Position = UDim2.new(0, 0, 0, 90)
    playersLabel.BackgroundTransparency = 1
    playersLabel.Text = "👥 Players: " .. #Services.Players:GetPlayers()
    playersLabel.TextColor3 = Color3.new(1, 1, 1)
    playersLabel.TextScaled = true
    playersLabel.Font = Enum.Font.Gotham
    playersLabel.TextXAlignment = Enum.TextXAlignment.Left
    playersLabel.ZIndex = 5
    
    -- Position Info
    local posLabel = Instance.new("TextLabel", statsFrame)
    posLabel.Size = UDim2.new(1, 0, 0, 30)
    posLabel.Position = UDim2.new(0, 0, 0, 130)
    posLabel.BackgroundTransparency = 1
    posLabel.Text = "📍 Posição: (0, 0, 0)"
    posLabel.TextColor3 = Color3.new(1, 1, 1)
    posLabel.TextScaled = true
    posLabel.Font = Enum.Font.Gotham
    posLabel.TextXAlignment = Enum.TextXAlignment.Left
    posLabel.ZIndex = 5
    
    -- Update stats
    task.spawn(function()
        local frameCount = 0
        local lastTime = tick()
        
        while StatsPanel.Parent do
            if tick() - lastTime >= 1 then
                local fps = frameCount
                frameCount = 0
                lastTime = tick()
                
                if StatsPanel.Visible then
                    fpsLabel.Text = "🖥️ FPS: " .. fps
                    pingLabel.Text = "🌐 Ping: " .. math.floor(Player:GetNetworkPing() * 1000) .. "ms"
                    playersLabel.Text = "👥 Players: " .. #Services.Players:GetPlayers()
                    
                    if RootPart then
                        local pos = RootPart.Position
                        posLabel.Text = string.format("📍 Posição: (%.1f, %.1f, %.1f)", pos.X, pos.Y, pos.Z)
                    end
                end
            end
            
            frameCount = frameCount + 1
            Services.RunService.Heartbeat:Wait()
        end
    end)
end

-- ════════════════════════════════════════════════════════════════
-- PAINEL SOBRE/CRÉDITOS MELHORADO
-- ════════════════════════════════════════════════════════════════

local function CreateAboutPanel()
    AboutPanel = Instance.new("Frame", ScreenGui)
    AboutPanel.Name = "AboutPanel"
    AboutPanel.Size = UDim2.new(0, 280, 0, 200)
    AboutPanel.Position = UDim2.new(0.5, -140, 0, 50)
    AboutPanel.BackgroundColor3 = Theme.SecondaryBg
    AboutPanel.BackgroundTransparency = Theme.PanelTransparency
    AboutPanel.BorderSizePixel = 0
    AboutPanel.Active = true
    AboutPanel.Visible = false
    AboutPanel.ZIndex = 4
    
    local corner = Instance.new("UICorner", AboutPanel)
    corner.CornerRadius = UDim.new(0, 12)
    
    Utils.CreateRGBBorder(AboutPanel, 3)
    Utils.MakeDraggable(AboutPanel)
    Utils.CreateGradientBg(AboutPanel, Theme.SecondaryBg, Theme.MainBg)
    
    -- Title
    local title = Instance.new("TextLabel", AboutPanel)
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundTransparency = 1
    title.Text = "ℹ️ SOBRE & CRÉDITOS"
    title.TextColor3 = Theme.Accent
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.ZIndex = 5
    
    -- Close Button
    local closeBtn = Utils.CreateStyledButton(AboutPanel, "❌", Theme.Disabled, UDim2.new(1, -35, 0, 5), UDim2.new(0, 30, 0, 30))
    closeBtn.ZIndex = 5
    closeBtn.MouseButton1Click:Connect(function()
        AboutPanel.Visible = false
    end)
    
    -- Description
    local desc = Instance.new("TextLabel", AboutPanel)
    desc.Size = UDim2.new(1, -20, 1, -60)
    desc.Position = UDim2.new(0, 10, 0, 50)
    desc.BackgroundTransparency = 1
    desc.Text = [[🚀 SANTZ STORE V2.0
    
🔧 Script criado por: SANTZ
📧 Discord: @santz  
🌐 GitHub: santz-hub123

✨ Melhorado por Claude AI
⚡ Versão Premium com:
• ESP Avançado
• Sistema de Teleporte
• Configurações Personalizáveis
• Interface Moderna
• Performance Otimizada

💎 Compartilhe e Melhore!]]
    desc.TextColor3 = Color3.new(1, 1, 1)
    desc.TextScaled = true
    desc.Font = Enum.Font.Gotham
    desc.ZIndex = 5
end

-- ════════════════════════════════════════════════════════════════
-- INTERFACE PRINCIPAL MELHORADA
-- ════════════════════════════════════════════════════════════════

local function CreateMainGUI()
    -- Destroy existing GUI
    if PlayerGui:FindFirstChild("SantzStoreV2") then
        PlayerGui.SantzStoreV2:Destroy()
    end
    
    ScreenGui = Instance.new("ScreenGui", PlayerGui)
    ScreenGui.Name = "SantzStoreV2"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Main Frame
    MainFrame = Instance.new("Frame", ScreenGui)
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 280, 0, 500)
    MainFrame.Position = UDim2.new(1, -300, 0.5, -250)
    MainFrame.BackgroundColor3 = Theme.MainBg
    MainFrame.BackgroundTransparency = Theme.PanelTransparency
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.ZIndex = 1
    
    local mainCorner = Instance.new("UICorner", MainFrame)
    mainCorner.CornerRadius = UDim.new(0, 15)
    
    Utils.CreateRGBBorder(MainFrame, 4)
    Utils.MakeDraggable(MainFrame)
    Utils.CreateGradientBg(MainFrame, Theme.MainBg, Theme.SecondaryBg)
    
    -- Header Frame
    local headerFrame = Instance.new("Frame", MainFrame)
    headerFrame.Size = UDim2.new(1, 0, 0, 60)
    headerFrame.BackgroundColor3 = Theme.Accent
    headerFrame.BackgroundTransparency = 0.1
    headerFrame.BorderSizePixel = 0
    headerFrame.ZIndex = 2
    
    local headerCorner = Instance.new("UICorner", headerFrame)
    headerCorner.CornerRadius = UDim.new(0, 15)
    
    Utils.CreateGradientBg(headerFrame, Theme.Accent, Theme.AccentDark)
    
    -- Title
    local title = Instance.new("TextLabel", headerFrame)
    title.Size = UDim2.new(1, -120, 1, 0)
    title.Position = UDim2.new(0, 10, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "🚀 SANTZ STORE V2.0"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = 3
    
    -- Control Buttons
    local aboutBtn = Utils.CreateStyledButton(headerFrame, "ℹ️", Theme.Info, UDim2.new(1, -110, 0, 10), UDim2.new(0, 30, 0, 30))
    aboutBtn.ZIndex = 3
    
    local settingsBtn = Utils.CreateStyledButton(headerFrame, "⚙️", Theme.Warning, UDim2.new(1, -75, 0, 10), UDim2.new(0, 30, 0, 30))
    settingsBtn.ZIndex = 3
    
    local minimizeBtn = Utils.CreateStyledButton(headerFrame, "➖", Theme.Info, UDim2.new(1, -40, 0, 10), UDim2.new(0, 30, 0, 30))
    minimizeBtn.ZIndex = 3
    
    -- Button Container
    local buttonContainer = Instance.new("ScrollingFrame", MainFrame)
    buttonContainer.Name = "ButtonContainer"
    buttonContainer.Size = UDim2.new(1, -20, 1, -80)
    buttonContainer.Position = UDim2.new(0, 10, 0, 70)
    buttonContainer.BackgroundTransparency = 1
    buttonContainer.BorderSizePixel = 0
    buttonContainer.ScrollBarThickness = 8
    buttonContainer.CanvasSize = UDim2.new(0, 0, 0, 800)
    buttonContainer.ZIndex = 2
    
    -- Enhanced Button List
    local buttons = {
        {name="ESP GOD", color=Theme.ESPGod, func=ESP.ToggleGodESP, icon=6031090935, desc="Detecta players com poderes divinos"},
        {name="ESP SECRET", color=Theme.ESPSecret, func=ESP.ToggleSecretESP, icon=6031075934, desc="Revela áreas secretas ocultas"},
        {name="ESP BASE", color=Theme.ESPBase, func=ESP.ToggleBaseESP, icon=6031094678, desc="Mostra bases e portas importantes"},
        {name="ESP PLAYER", color=Theme.ESPPlayer, func=ESP.TogglePlayerESP, icon=6034996691, desc="Destaca todos os players"},
        {name="ESP NAME", color=Theme.ESPName, func=ESP.ToggleNameESP, icon=6026568198, desc="Exibe nomes dos players"},
        {name="ESP ITEM", color=Theme.ESPItem, func=ESP.ToggleItemESP, icon=6023426925, desc="Localiza itens importantes"},
        {name="🚀 TELEPORTE", color=Theme.Accent, func=function() 
            if not TelePanel then Teleport.CreateTelePanel() end
            TelePanel.Visible = not TelePanel.Visible
        end, icon=6034996691, desc="Painel avançado de teleporte"},
        {name="⚡ DASH", color=Theme.Disabled, func=Movement.ActivateDash, icon=6031090935, desc="Dash rápido para frente"},
        {name="🦸 SUPERMAN", color=Theme.Warning, func=Movement.ToggleSuperman, icon=6034981416, desc="Modo Superman ativado"},
        {name="🛡️ ANTI-HIT", color=Theme.Info, func=Movement.ToggleAntiHit, icon=6031075934, desc="Proteção contra ataques"},
        {name="👻 NOCLIP", color=Theme.ESPSecret, func=Movement.ToggleNoclip, icon=6026568198, desc="Atravessa paredes"},
        {name="📊 STATS", color=Theme.AccentDark, func=function()
            if not StatsPanel then CreateStatsPanel() end
            StatsPanel.Visible = not StatsPanel.Visible
        end, icon=6034996691, desc="Estatísticas do jogo"}
    }
    
    for i, buttonData in ipairs(buttons) do
        local btnFrame = Instance.new("Frame", buttonContainer)
        btnFrame.Size = UDim2.new(1, 0, 0, 50)
        btnFrame.Position = UDim2.new(0, 0, 0, (i-1) * 55)
        btnFrame.BackgroundTransparency = 1
        btnFrame.ZIndex = 3
        
        local btn = Utils.CreateStyledButton(
            btnFrame, 
            buttonData.name, 
            buttonData.color, 
            UDim2.new(0, 0, 0, 0), 
            UDim2.new(1, 0, 0, 45), 
            buttonData.icon
        )
        btn.ZIndex = 4
        
        -- Status indicator
        local statusIndicator = Instance.new("Frame", btn)
        statusIndicator.Size = UDim2.new(0, 8, 0, 8)
        statusIndicator.Position = UDim2.new(1, -15, 0, 5)
        statusIndicator.BackgroundColor3 = Theme.Disabled
        statusIndicator.BorderSizePixel = 0
        statusIndicator.ZIndex = 5
        
        local indicatorCorner = Instance.new("UICorner", statusIndicator)
        indicatorCorner.CornerRadius = UDim.new(1, 0)
        
        btn.MouseButton1Click:Connect(function()
            buttonData.func()
            
            -- Update button state
            local cleanName = buttonData.name:gsub("🚀 ", ""):gsub("⚡ ", ""):gsub("🦸 ", ""):gsub("🛡️ ", ""):gsub("👻 ", ""):gsub("📊 ", "")
            local isActive = ToggleStates[cleanName] or ToggleStates["ESP_" .. cleanName] or false
            
            if isActive then
                btn.BackgroundColor3 = Theme.Enabled
                statusIndicator.BackgroundColor3 = Theme.Enabled
                Utils.TweenProperty(statusIndicator, {BackgroundColor3 = Theme.Enabled}, 0.3)
            else
                btn.BackgroundColor3 = buttonData.color
                statusIndicator.BackgroundColor3 = Theme.Disabled
                Utils.TweenProperty(statusIndicator, {BackgroundColor3 = Theme.Disabled}, 0.3)
            end
        end)
    end
    
    -- Control Button Events
    aboutBtn.MouseButton1Click:Connect(function()
        if not AboutPanel then CreateAboutPanel() end
        AboutPanel.Visible = not AboutPanel.Visible
    end)
    
    settingsBtn.MouseButton1Click:Connect(function()
        if not SettingsPanel then CreateSettingsPanel() end
        SettingsPanel.Visible = not SettingsPanel.Visible
    end)
    
    minimizeBtn.MouseButton1Click:Connect(function()
        IsMinimized = not IsMinimized
        local targetSize = IsMinimized and UDim2.new(0, 280, 0, 60) or UDim2.new(0, 280, 0, 500)
        
        Utils.TweenProperty(MainFrame, {Size = targetSize}, 0.5)
        buttonContainer.Visible = not IsMinimized
        minimizeBtn.Text = IsMinimized and "➕" or "➖"
        
        -- Hide other panels when minimized
        if IsMinimized then
            if TelePanel then TelePanel.Visible = false end
            if StatsPanel then StatsPanel.Visible = false end
            if SettingsPanel then SettingsPanel.Visible = false end
        end
    end)
    
    -- Animate GUI entrance
    MainFrame.Position = UDim2.new(1, 0, 0.5, -250)
    Utils.TweenProperty(MainFrame, {Position = UDim2.new(1, -300, 0.5, -250)}, 1, Enum.EasingStyle.Back)
    
    Utils.ShowNotification("SANTZ STORE V2.0", "Interface carregada com sucesso! ✨", 3)
end

-- ════════════════════════════════════════════════════════════════
-- SISTEMA DE SEGURANÇA & ANTI-KICK
-- ════════════════════════════════════════════════════════════════

local Security = {}

function Security.InitAntiKick()
    if not Config.AntiKick then return end
    
    -- Anti-Kick Protection
    local mt = getrawmetatable(game)
    local oldNamecall = mt.__namecall
    
    setreadonly(mt, false)
    mt.__namecall = newcclosure(function(self, ...)
        local args = {...}
        local method = getnamecallmethod()
        
        if method == "Kick" then
            Utils.ShowNotification("SEGURANÇA", "Tentativa de kick bloqueada! 🛡️", 3)
            return
        end
        
        return oldNamecall(self, ...)
    end)
    setreadonly(mt, true)
    
    Utils.ShowNotification("SEGURANÇA", "Proteção anti-kick ativada! 🛡️", 2)
end

function Security.InitAutoRejoin()
    if not Config.AutoRejoin then return end
    
    Services.Players.PlayerRemoving:Connect(function(player)
        if player == Player then
            task.wait(1)
            game:GetService("TeleportService"):Teleport(game.PlaceId, Player)
        end
    end)
end

-- ════════════════════════════════════════════════════════════════
-- SISTEMA DE KEYBINDS
-- ════════════════════════════════════════════════════════════════

local Keybinds = {
    ToggleGUI = Enum.KeyCode.Insert,
    Dash = Enum.KeyCode.G,
    Superman = Enum.KeyCode.F,
    Noclip = Enum.KeyCode.N,
    TelePanel = Enum.KeyCode.T
}

local function InitKeybinds()
    Services.UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == Keybinds.ToggleGUI then
            if MainFrame then
                MainFrame.Visible = not MainFrame.Visible
            end
        elseif input.KeyCode == Keybinds.Dash then
            Movement.ActivateDash()
        elseif input.KeyCode == Keybinds.Superman then
            Movement.ToggleSuperman()
        elseif input.KeyCode == Keybinds.Noclip then
            Movement.ToggleNoclip()
        elseif input.KeyCode == Keybinds.TelePanel then
            if TelePanel then
                TelePanel.Visible = not TelePanel.Visible
            elseif MainFrame then
                if not TelePanel then Teleport.CreateTelePanel() end
                TelePanel.Visible = true
            end
        end
    end)
end

-- ════════════════════════════════════════════════════════════════
-- SISTEMA DE ATUALIZAÇÕES AUTOMÁTICAS
-- ════════════════════════════════════════════════════════════════

local function UpdateESPSystems()
    task.spawn(function()
        while true do
            local currentTime = tick()
            if currentTime - LastUpdateTime >= Config.ESPUpdateRate then
                LastUpdateTime = currentTime
                
                -- Update ESP for new players
                if ToggleStates["ESP_GOD"] then ESP.ToggleGodESP(); ESP.ToggleGodESP() end
                if ToggleStates["ESP_PLAYER"] then ESP.TogglePlayerESP(); ESP.TogglePlayerESP() end
                if ToggleStates["ESP_NAME"] then ESP.ToggleNameESP(); ESP.ToggleNameESP() end
                
                -- Update ESP for new objects (less frequent)
                if math.random(1, 10) == 1 then
                    if ToggleStates["ESP_SECRET"] then ESP.ToggleSecretESP(); ESP.ToggleSecretESP() end
                    if ToggleStates["ESP_BASE"] then ESP.ToggleBaseESP(); ESP.ToggleBaseESP() end
                    if ToggleStates["ESP_ITEM"] then ESP.ToggleItemESP(); ESP.ToggleItemESP() end
                end
            end
            task.wait(Config.ESPUpdateRate)
        end
    end)
end

-- ════════════════════════════════════════════════════════════════
-- EVENTOS DO PLAYER
-- ════════════════════════════════════════════════════════════════

local function ConnectPlayerEvents()
    -- Character Respawn Handler
    Player.CharacterAdded:Connect(function()
        Utils.UpdateCharacterRefs()
        
        -- Restore states after respawn
        task.wait(2)
        if ToggleStates["Superman"] then
            Movement.ToggleSuperman()
            Movement.ToggleSuperman()
        end
        if ToggleStates["NOCLIP"] then
            Movement.ToggleNoclip()
            Movement.ToggleNoclip()
        end
        
        Utils.ShowNotification("RESPAWN", "Estados restaurados após respawn! ✨", 2)
    end)
    
    -- Player Joining/Leaving
    Services.Players.PlayerAdded:Connect(function(player)
        Utils.ShowNotification("PLAYER", player.Name .. " entrou no jogo! 👋", 2)
    end)
    
    Services.Players.PlayerRemoving:Connect(function(player)
        Utils.ShowNotification("PLAYER", player.Name .. " saiu do jogo! 👋", 2)
    end)
end

-- ════════════════════════════════════════════════════════════════
-- SISTEMA DE COMANDOS VIA CHAT
-- ════════════════════════════════════════════════════════════════

local function InitChatCommands()
    Player.Chatted:Connect(function(message)
        local msg = message:lower()
        
        if msg:sub(1, 7) == "/santz " then
            local command = msg:sub(8)
            
            if command == "dash" then
                Movement.ActivateDash()
            elseif command == "superman" then
                Movement.ToggleSuperman()
            elseif command == "noclip" then
                Movement.ToggleNoclip()
            elseif command == "esp" then
                ESP.TogglePlayerESP()
            elseif command == "tele" then
                if not TelePanel then Teleport.CreateTelePanel() end
                TelePanel.Visible = true
            elseif command == "save" then
                Teleport.SaveCoordinate()
            elseif command == "help" then
                Utils.ShowNotification("COMANDOS", [[
Comandos disponíveis:
/santz dash - Ativar dash
/santz superman - Toggle superman
/santz noclip - Toggle noclip
/santz esp - Toggle ESP players
/santz tele - Abrir painel teleporte
/santz save - Salvar coordenada
                ]], 5)
            end
        end
    end)
end

-- ════════════════════════════════════════════════════════════════
-- INICIALIZAÇÃO PRINCIPAL
-- ════════════════════════════════════════════════════════════════

local function Initialize()
    -- Initialize character references
    Utils.UpdateCharacterRefs()
    
    -- Initialize toggle states
    for _, state in pairs({
        "ESP_GOD", "ESP_SECRET", "ESP_BASE", "ESP_PLAYER", "ESP_NAME", "ESP_ITEM",
        "Superman", "ANTI_HIT", "NOCLIP"
    }) do
        ToggleStates[state] = false
    end
    
    -- Create main interface
    CreateMainGUI()
    
    -- Initialize systems
    Security.InitAntiKick()
    Security.InitAutoRejoin()
    InitKeybinds()
    InitChatCommands()
    ConnectPlayerEvents()
    UpdateESPSystems()
    
    -- Play startup sound
    Utils.PlaySound(131961136, 0.8)
    
    -- Welcome message
    task.wait(1)
    Utils.ShowNotification("SANTZ STORE V2.0", [[
🚀 Bem-vindo ao SANTZ STORE V2.0!

⌨️ KEYBINDS:
• INSERT - Toggle GUI
• G - Dash
• F - Superman
• N - Noclip
• T - Painel Teleporte

💬 COMANDOS:
• /santz help - Ver comandos

✨ Script totalmente otimizado!
    ]], 8)
    
    print("🚀 SANTZ STORE V2.0 - Carregado com sucesso!")
    print("📧 Discord: @santz | 🌐 GitHub: santz-hub123")
    print("✨ Melhorado por Claude AI - Versão Premium")
end

-- ════════════════════════════════════════════════════════════════
-- TRATAMENTO DE ERROS & CLEANUP
-- ════════════════════════════════════════════════════════════════

local function Cleanup()
    -- Disconnect all connections
    for _, connection in pairs(Connections) do
        if connection then
            connection:Disconnect()
        end
    end
    
    -- Clear all ESP
    for _, espType in pairs(ESPRefs) do
        for _, esp in pairs(espType) do
            if esp then esp:Destroy() end
        end
    end
    
    -- Destroy GUI
    if ScreenGui then
        ScreenGui:Destroy()
    end
    
    print("🧹 SANTZ STORE V2.0 - Cleanup realizado!")
end

-- Error handling wrapper
local success, error = pcall(Initialize)
if not success then
    warn("❌ SANTZ STORE V2.0 - Erro durante inicialização: " .. tostring(error))
    Utils.ShowNotification("ERRO", "Falha na inicialização: " .. tostring(error), 5)
end

-- Cleanup on game shutdown
game:BindToClose(Cleanup)

-- ════════════════════════════════════════════════════════════════
-- FINAL DO SCRIPT - SANTZ STORE V2.0
-- ════════════════════════════════════════════════════════════════
