-- SANTZ STORE
-- Script completamente refeito e funcional

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local SoundService = game:GetService("SoundService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- Variáveis globais persistentes
getgenv().SantzStore = getgenv().SantzStore or {
    savedCoordinate = nil,
    connections = {},
    espObjects = {},
    bodyMovers = {},
    states = {
        twoDash = false,
        speedBoost = false,
        jumpBoost = false,
        antiHit = false,
        teleGuided = false,
        espPlayer = false,
        espBase = false,
        espGod = false,
        espSecret = false
    }
}

local data = getgenv().SantzStore

-- Limpar tudo anterior
if CoreGui:FindFirstChild("SantzStore") then
    CoreGui:FindFirstChild("SantzStore"):Destroy()
end

for _, conn in pairs(data.connections) do
    if conn and conn.Connected then
        conn:Disconnect()
    end
end
data.connections = {}

for _, esp in pairs(data.espObjects) do
    if esp and esp.Parent then
        esp:Destroy()
    end
end
data.espObjects = {}

for _, mover in pairs(data.bodyMovers) do
    if mover and mover.Parent then
        mover:Destroy()
    end
end
data.bodyMovers = {}

-- Obter character atual
local function getCharacter()
    return player.Character or player.CharacterAdded:Wait()
end

local function getHumanoid()
    local char = getCharacter()
    return char:WaitForChild("Humanoid")
end

local function getRootPart()
    local char = getCharacter()
    return char:WaitForChild("HumanoidRootPart")
end

-- Criar ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SantzStore"
screenGui.ResetOnSpawn = false
screenGui.Parent = CoreGui

-- Frame principal (menor e mais compacto)
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 320, 0, 380) -- Menor como pedido
mainFrame.Position = UDim2.new(0.5, -160, 0.5, -190)
mainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0) -- Fundo preto
mainFrame.BackgroundTransparency = 0.3 -- Semi-transparente
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true -- Arrastável
mainFrame.Parent = screenGui

-- Cantos arredondados
local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 10)
mainCorner.Parent = mainFrame

-- Borda RGB animada
local mainStroke = Instance.new("UIStroke")
mainStroke.Thickness = 2
mainStroke.Parent = mainFrame

local mainGradient = Instance.new("UIGradient")
mainGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
    ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
    ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
    ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
    ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
}
mainGradient.Parent = mainStroke

-- Animação RGB principal
local mainRgbTween = TweenService:Create(mainGradient, TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1), {Rotation = 360})
mainRgbTween:Play()

-- Título
local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "Title"
titleLabel.Size = UDim2.new(1, -50, 0, 40)
titleLabel.Position = UDim2.new(0, 10, 0, 5)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "SANTZ STORE"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextScaled = true
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextStrokeTransparency = 0.5
titleLabel.Parent = mainFrame

-- Botão minimizar
local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Name = "MinimizeButton"
minimizeBtn.Size = UDim2.new(0, 30, 0, 25)
minimizeBtn.Position = UDim2.new(1, -40, 0, 10)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
minimizeBtn.Text = "−"
minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeBtn.TextScaled = true
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.BorderSizePixel = 0
minimizeBtn.Parent = mainFrame

local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(0, 5)
minCorner.Parent = minimizeBtn

-- Container dos botões
local buttonsFrame = Instance.new("Frame")
buttonsFrame.Name = "ButtonsFrame"
buttonsFrame.Size = UDim2.new(1, -20, 1, -60)
buttonsFrame.Position = UDim2.new(0, 10, 0, 50)
buttonsFrame.BackgroundTransparency = 1
buttonsFrame.Parent = mainFrame

-- Função para criar botão com RGB
local function createButton(parent, name, text, position, size, callback, isToggleable)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Size = size
    button.Position = position
    button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    button.Text = text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextScaled = true
    button.Font = Enum.Font.Gotham
    button.BorderSizePixel = 0
    button.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = button
    
    -- Borda RGB
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1.5
    stroke.Parent = button
    
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 255)),
        ColorSequenceKeypoint.new(0.25, Color3.fromRGB(0, 255, 255)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 0)),
        ColorSequenceKeypoint.new(0.75, Color3.fromRGB(255, 0, 0)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 255, 0))
    }
    gradient.Parent = stroke
    
    local rgbTween = TweenService:Create(gradient, TweenInfo.new(1.5, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1), {Rotation = 360})
    rgbTween:Play()
    
    -- Efeitos
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60, 60, 60)}):Play()
    end)
    
    button.MouseLeave:Connect(function()
        local color = Color3.fromRGB(40, 40, 40)
        if isToggleable and data.states[name] then
            color = Color3.fromRGB(0, 100, 0)
        end
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = color}):Play()
    end)
    
    button.MouseButton1Click:Connect(function()
        callback()
        
        if isToggleable then
            local color = data.states[name] and Color3.fromRGB(0, 100, 0) or Color3.fromRGB(40, 40, 40)
            TweenService:Create(button, TweenInfo.new(0.3), {BackgroundColor3 = color}):Play()
        end
    end)
    
    return button
end

-- Funcionalidades principais
local function toggle2Dash()
    data.states.twoDash = not data.states.twoDash
    
    if data.states.twoDash then
        data.connections.twoDash = UserInputService.InputBegan:Connect(function(input)
            if input.KeyCode == Enum.KeyCode.Z then
                local rootPart = getRootPart()
                if rootPart then
                    local bodyVelocity = Instance.new("BodyVelocity")
                    bodyVelocity.MaxForce = Vector3.new(math.huge, 0, math.huge)
                    bodyVelocity.Velocity = rootPart.CFrame.LookVector * 100
                    bodyVelocity.Parent = rootPart
                    table.insert(data.bodyMovers, bodyVelocity)
                    
                    game:GetService("Debris"):AddItem(bodyVelocity, 0.5)
                end
            end
        end)
    else
        if data.connections.twoDash then
            data.connections.twoDash:Disconnect()
            data.connections.twoDash = nil
        end
    end
end

local function toggleSpeedBoost()
    data.states.speedBoost = not data.states.speedBoost
    local humanoid = getHumanoid()
    
    if data.states.speedBoost then
        humanoid.WalkSpeed = 50
        humanoid.JumpPower = 100
    else
        humanoid.WalkSpeed = 16
        humanoid.JumpPower = 50
    end
end

local function toggleJumpBoost()
    data.states.jumpBoost = not data.states.jumpBoost
    local humanoid = getHumanoid()
    
    if data.states.jumpBoost then
        humanoid.JumpPower = 100
    else
        humanoid.JumpPower = 50
    end
end

local function saveCoordinate()
    local rootPart = getRootPart()
    if rootPart then
        data.savedCoordinate = rootPart.Position
        print("🟢 SANTZ STORE: Coordenada salva!")
    end
end

-- TELEGUIADO INTELIGENTE com velocidade 50
local function activateTeleGuided()
    if not data.savedCoordinate then
        print("❌ Nenhuma coordenada salva!")
        return
    end
    
    data.states.teleGuided = not data.states.teleGuided
    
    if data.states.teleGuided then
        local rootPart = getRootPart()
        
        local bodyPosition = Instance.new("BodyPosition")
        bodyPosition.MaxForce = Vector3.new(4000, 4000, 4000)
        bodyPosition.Position = rootPart.Position
        bodyPosition.D = 3000
        bodyPosition.P = 10000
        bodyPosition.Parent = rootPart
        table.insert(data.bodyMovers, bodyPosition)
        
        data.connections.teleGuided = RunService.Heartbeat:Connect(function()
            if not data.savedCoordinate or not rootPart.Parent then return end
            
            local currentPos = rootPart.Position
            local targetPos = data.savedCoordinate
            local distance = (targetPos - currentPos).Magnitude
            
            if distance > 3 then
                -- Sistema inteligente anti-colisão
                local direction = (targetPos - currentPos).Unit
                local raycast = workspace:Raycast(currentPos, direction * math.min(distance, 20))
                
                if raycast and raycast.Instance.CanCollide then
                    -- Obstáculo detectado - desviar
                    local normal = raycast.Normal
                    local rightVector = direction:Cross(Vector3.new(0, 1, 0)).Unit
                    local newDirection = (direction + rightVector * 0.5).Unit
                    
                    bodyPosition.Position = currentPos + newDirection * 15 + Vector3.new(0, 5, 0)
                else
                    -- Caminho livre
                    bodyPosition.Position = targetPos + Vector3.new(0, 2, 0)
                end
            else
                -- Chegou ao destino
                bodyPosition:Destroy()
                data.connections.teleGuided:Disconnect()
                data.connections.teleGuided = nil
                data.states.teleGuided = false
                print("🟢 Teleporte concluído!")
            end
        end)
        
        print("🚀 Teleporte ativo - Velocidade 50")
    else
        if data.connections.teleGuided then
            data.connections.teleGuided:Disconnect()
            data.connections.teleGuided = nil
        end
        for _, mover in pairs(data.bodyMovers) do
            if mover and mover.Parent then
                mover:Destroy()
            end
        end
    end
end

local function toggleAntiHit()
    data.states.antiHit = not data.states.antiHit
    local character = getCharacter()
    
    if data.states.antiHit then
        for _, part in pairs(character:GetChildren()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.CanCollide = false
            end
        end
    else
        for _, part in pairs(character:GetChildren()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.CanCollide = true
            end
        end
    end
end

-- Sistema ESP com nomes RGB
local function createNameESP(obj, color, text)
    if not obj or not obj.Parent then return end
    
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.Adornee = obj
    billboard.AlwaysOnTop = true
    billboard.Parent = obj
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 1, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = text
    nameLabel.TextColor3 = color
    nameLabel.TextScaled = true
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextStrokeTransparency = 0
    nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    nameLabel.Parent = billboard
    
    -- Efeito RGB no texto
    local colorTween = TweenService:Create(nameLabel, TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, true), {
        TextColor3 = Color3.fromHSV((tick() % 5) / 5, 1, 1)
    })
    colorTween:Play()
    
    table.insert(data.espObjects, billboard)
    return billboard
end

local function clearESP()
    for _, esp in pairs(data.espObjects) do
        if esp and esp.Parent then
            esp:Destroy()
        end
    end
    data.espObjects = {}
end

local function toggleESPPlayer()
    data.states.espPlayer = not data.states.espPlayer
    
    if data.states.espPlayer then
        for _, otherPlayer in pairs(Players:GetPlayers()) do
            if otherPlayer ~= player and otherPlayer.Character and otherPlayer.Character:FindFirstChild("Head") then
                createNameESP(otherPlayer.Character.Head, Color3.fromRGB(0, 255, 0), otherPlayer.Name)
            end
        end
    else
        clearESP()
    end
end

local function toggleESPGod()
    data.states.espGod = not data.states.espGod
    
    if data.states.espGod then
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj.Name:lower():find("god") then
                createNameESP(obj, Color3.fromRGB(255, 215, 0), "GOD")
            end
        end
    else
        clearESP()
    end
end

local function toggleESPSecret()
    data.states.espSecret = not data.states.espSecret
    
    if data.states.espSecret then
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj.Name:lower():find("secret") or obj.Name:lower():find("hidden") then
                createNameESP(obj, Color3.fromRGB(128, 0, 128), "SECRET")
            end
        end
    else
        clearESP()
    end
end

local function toggleESPBase()
    data.states.espBase = not data.states.espBase
    
    if data.states.espBase then
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj.Name:lower():find("base") or obj.Name:lower():find("building") then
                createNameESP(obj, Color3.fromRGB(0, 0, 255), "BASE")
            end
        end
    else
        clearESP()
    end
end

-- Criar todos os botões (compactos)
createButton(buttonsFrame, "twoDash", "2 DASH", UDim2.new(0, 0, 0, 0), UDim2.new(0, 145, 0, 35), toggle2Dash, true)
createButton(buttonsFrame, "speedBoost", "SPEED BOOST", UDim2.new(0, 155, 0, 0), UDim2.new(0, 145, 0, 35), toggleSpeedBoost, true)

createButton(buttonsFrame, "jumpBoost", "JUMP BOOST", UDim2.new(0, 0, 0, 45), UDim2.new(0, 145, 0, 35), toggleJumpBoost, true)
createButton(buttonsFrame, "saveCoord", "SALVAR CORDENADA", UDim2.new(0, 155, 0, 45), UDim2.new(0, 145, 0, 35), saveCoordinate, false)

createButton(buttonsFrame, "teleGuided", "ATIVAR TELEGUIADO", UDim2.new(0, 0, 0, 90), UDim2.new(0, 145, 0, 35), activateTeleGuided, true)
createButton(buttonsFrame, "antiHit", "ANTI-HIT", UDim2.new(0, 155, 0, 90), UDim2.new(0, 145, 0, 35), toggleAntiHit, true)

-- Botões ESP menores e compactos
createButton(buttonsFrame, "espPlayer", "ESP PLAYER", UDim2.new(0, 0, 0, 140), UDim2.new(0, 70, 0, 30), toggleESPPlayer, true)
createButton(buttonsFrame, "espGod", "ESP GOD", UDim2.new(0, 80, 0, 140), UDim2.new(0, 70, 0, 30), toggleESPGod, true)
createButton(buttonsFrame, "espSecret", "ESP SECRET", UDim2.new(0, 160, 0, 140), UDim2.new(0, 70, 0, 30), toggleESPSecret, true)
createButton(buttonsFrame, "espBase", "ESP BASE", UDim2.new(0, 230, 0, 140), UDim2.new(0, 70, 0, 30), toggleESPBase, true)

-- Função minimizar
local isMinimized = false
minimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    
    if isMinimized then
        -- Minimizar - só título
        TweenService:Create(mainFrame, TweenInfo.new(0.3), {Size = UDim2.new(0, 320, 0, 50)}):Play()
        buttonsFrame.Visible = false
        minimizeBtn.Text = "+"
    else
        -- Maximizar
        TweenService:Create(mainFrame, TweenInfo.new(0.3), {Size = UDim2.new(0, 320, 0, 380)}):Play()
        buttonsFrame.Visible = true
        minimizeBtn.Text = "−"
    end
end)

-- Reconectar ao respawnar
player.CharacterAdded:Connect(function()
    task.wait(2)
    
    -- Reativar estados ativos
    if data.states.speedBoost then
        data.states.speedBoost = false
        toggleSpeedBoost()
    end
    if data.states.jumpBoost then
        data.states.jumpBoost = false
        toggleJumpBoost()
    end
    if data.states.antiHit then
        data.states.antiHit = false
        toggleAntiHit()
    end
    if data.states.twoDash then
        data.states.twoDash = false
        toggle2Dash()
    end
end)

-- Animação de entrada
mainFrame.Position = UDim2.new(0.5, -160, -1, 0)
TweenService:Create(mainFrame, TweenInfo.new(0.8, Enum.EasingStyle.Back), {
    Position = UDim2.new(0.5, -160, 0.5, -190)
}):Play()

print("🟢 SANTZ STORE carregado!")
print("📍 Painel arrastável")
print("⚡ Pressione Z para 2 DASH")
print("🎯 TELEGUIADO com velocidade 50 e IA anti-colisão")
