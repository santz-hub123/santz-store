-- SANTZ STORE V2.0 - Script Otimizado
-- Autor: santz-hub123 | github.com/santz-hub123

-- [SERVIÇOS & INICIALIZAÇÃO] --
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

local Player = Services.Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local Mouse = Player:GetMouse()
local Character, Humanoid, RootPart, Head

local MainFrame, TelePanel, AboutPanel, SettingsPanel, StatsPanel
local ScreenGui
local IsMinimized = false
local ToggleStates = {}
local ESPRefs = {GOD={}, SECRET={}, PLAYER={}, NAME={}, ITEMS={}}
local SavedCoords = {}
local Connections = {}
local LastUpdateTime = 0

-- [CONFIGURAÇÕES & TEMA] --
local Config = {
    ESPUpdateRate = 0.1,
    MaxESPDistance = 1000,
    AutoSaveCoords = true,
    DefaultWalkSpeed = 16,
    DefaultJumpPower = 50,
    SupermanSpeed = 150,
    SupermanJump = 200,
    DashForce = 120,
    AnimationSpeed = 0.25,
    SoundVolume = 0.4,
    ShowNotifications = true,
    AntiKick = true,
    AutoRejoin = true,
    SaveSettings = true
}
local Theme = {
    MainBg = Color3.fromRGB(20, 20, 25),
    SecondaryBg = Color3.fromRGB(15, 15, 20),
    Accent = Color3.fromRGB(0, 255, 127),
    AccentDark = Color3.fromRGB(0, 200, 100),
    Button = Color3.fromRGB(35, 35, 40),
    ButtonHover = Color3.fromRGB(55, 55, 65),
    ButtonActive = Color3.fromRGB(0, 180, 90),
    Enabled = Color3.fromRGB(0, 220, 110),
    Disabled = Color3.fromRGB(220, 60, 60),
    Warning = Color3.fromRGB(255, 165, 0),
    Info = Color3.fromRGB(100, 150, 255),
    ESPGod = Color3.fromRGB(160, 32, 240),
    ESPSecret = Color3.fromRGB(255, 255, 255),
    ESPPlayer = Color3.fromRGB(0, 150, 255),
    ESPName = Color3.fromRGB(255, 105, 180),
    ESPItem = Color3.fromRGB(50, 205, 50),
    PanelTransparency = 0.1,
    BorderTransparency = 0.8
}

-- [UTILITÁRIOS] --
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
    sound.Ended:Connect(function() sound:Destroy() end)
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
        TweenInfo.new(duration or Config.AnimationSpeed, easingStyle or Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
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
    local corner = Instance.new("UICorner", button)
    corner.CornerRadius = UDim.new(0, 8)
    Utils.CreateGradientBg(button, color, Color3.new(math.max(0, color.R - 0.1), math.max(0, color.G - 0.1), math.max(0, color.B - 0.1)))
    if iconId then
        local icon = Instance.new("ImageLabel", button)
        icon.Size = UDim2.new(0, 24, 0, 24)
        icon.Position = UDim2.new(0, 8, 0.5, -12)
        icon.BackgroundTransparency = 1
        icon.Image = "rbxassetid://" .. tostring(iconId)
        icon.ImageColor3 = Color3.new(1, 1, 1)
    end
    button.MouseEnter:Connect(function()
        Utils.TweenProperty(button, {BackgroundColor3 = Theme.ButtonHover}, 0.15)
        Utils.PlaySound(131961136, 0.1)
    end)
    button.MouseLeave:Connect(function()
        Utils.TweenProperty(button, {BackgroundColor3 = color or Theme.Button}, 0.15)
    end)
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
        if child.Name == tag then child:Destroy() end
    end
end
function Utils.GetDistance(part1, part2)
    if not part1 or not part2 then return math.huge end
    return (part1.Position - part2.Position).Magnitude
end

-- [SISTEMA ESP] --
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
    task.spawn(function()
        while billboard.Parent and RootPart do
            local distance = Utils.GetDistance(adornee, RootPart)
            billboard.Enabled = distance <= Config.MaxESPDistance
            local scale = math.max(0.5, 1 - (distance / Config.MaxESPDistance))
            billboard.Size = UDim2.new(0, 120 * scale, 0, 50 * scale)
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
                    local isGod = player.Name:lower():find("god") or player.Name:lower():find("admin")
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
                local isSecret = obj.Name:lower():find("secret") or obj.Name:lower():find("hidden") or obj.Name:lower():find("rare") or obj.Name:lower():find("treasure")
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
                    -- RGB effect
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

-- [SISTEMA DE MOVIMENTO, TELEPORTE, PAINÉIS, SEGURANÇA, KEYBINDS, ETC.]
-- [MANTIDO igual ao original, exceto remoção de ESP BASE das listas, painéis e botões]

-- [INTERFACE PRINCIPAL]
local function CreateMainGUI()
    if PlayerGui:FindFirstChild("SantzStoreV2") then
        PlayerGui.SantzStoreV2:Destroy()
    end
    ScreenGui = Instance.new("ScreenGui", PlayerGui)
    ScreenGui.Name = "SantzStoreV2"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    MainFrame = Instance.new("Frame", ScreenGui)
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 280, 0, 440) -- PAINEL MENOR
    MainFrame.Position = UDim2.new(1, -300, 0.5, -220)
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
    -- ... (restante igual, exceto lista de botões sem ESP BASE)
    local buttonContainer = Instance.new("ScrollingFrame", MainFrame)
    buttonContainer.Name = "ButtonContainer"
    buttonContainer.Size = UDim2.new(1, -20, 1, -80)
    buttonContainer.Position = UDim2.new(0, 10, 0, 70)
    buttonContainer.BackgroundTransparency = 1
    buttonContainer.BorderSizePixel = 0
    buttonContainer.ScrollBarThickness = 8
    buttonContainer.CanvasSize = UDim2.new(0, 0, 0, 800)
    buttonContainer.ZIndex = 2
    local buttons = {
        {name="ESP GOD", color=Theme.ESPGod, func=ESP.ToggleGodESP, icon=6031090935, desc="Detecta players com poderes divinos"},
        {name="ESP SECRET", color=Theme.ESPSecret, func=ESP.ToggleSecretESP, icon=6031075934, desc="Revela áreas secretas ocultas"},
        -- Removido ESP BASE
        {name="ESP PLAYER", color=Theme.ESPPlayer, func=ESP.TogglePlayerESP, icon=6034996691, desc="Destaca todos os players"},
        {name="ESP NAME", color=Theme.ESPName, func=ESP.ToggleNameESP, icon=6026568198, desc="Exibe nomes dos players"},
        {name="ESP ITEM", color=Theme.ESPItem, func=ESP.ToggleItemESP, icon=6023426925, desc="Localiza itens importantes"},
        -- Demais botões...
    }
    -- ... (restante igual, controle de painéis TelePanel, StatsPanel, AboutPanel, SettingsPanel)
    -- Ao fechar MainFrame, não fecha TelePanel, StatsPanel, etc.

    -- Animate GUI entrance
    MainFrame.Position = UDim2.new(1, 0, 0.5, -220)
    Utils.TweenProperty(MainFrame, {Position = UDim2.new(1, -300, 0.5, -220)}, 1, Enum.EasingStyle.Back)
    Utils.ShowNotification("SANTZ STORE V2.0", "Interface carregada com sucesso! ✨", 3)
end

-- [INICIALIZAÇÃO PRINCIPAL]
local function Initialize()
    Utils.UpdateCharacterRefs()
    for _, state in pairs({"ESP_GOD", "ESP_SECRET", "ESP_PLAYER", "ESP_NAME", "ESP_ITEM", "Superman", "ANTI_HIT", "NOCLIP"}) do
        ToggleStates[state] = false
    end
    CreateMainGUI()
    -- Demais sistemas igual ao original
end

local success, error = pcall(Initialize)
if not success then
    warn("❌ SANTZ STORE V2.0 - Erro durante inicialização: " .. tostring(error))
    Utils.ShowNotification("ERRO", "Falha na inicialização: " .. tostring(error), 5)
end
game:BindToClose(function()
    -- Cleanup code
end)

-- FIM
