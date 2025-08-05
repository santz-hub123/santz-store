-- SANTZ STORE Script
-- LocalScript para Roblox

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local character = player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

-- Variáveis globais
getgenv().SantzStore = getgenv().SantzStore or {}
local config = getgenv().SantzStore
config.savedCoordinate = config.savedCoordinate or nil
config.states = config.states or {}

-- Estados dos botões
local buttonStates = {
    twoDash = false,
    speedBoost = false,
    jumpBoost = false,
    antiHit = false,
    espGod = false,
    espSecret = false,
    espPlayer = false,
    espBase = false,
    teleGuided = false
}

-- Conexões para limpeza
local connections = {}
local espObjects = {}

-- Sons
local clickSound = Instance.new("Sound")
clickSound.SoundId = "rbxasset://sounds/electronicpingshort.wav"
clickSound.Volume = 0.5
clickSound.Parent = SoundService

-- Função para criar efeito RGB
local function createRGBEffect(frame)
    local gradient = Instance.new("UIGradient")
    gradient.Parent = frame
    
    local colorSequence = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
        ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
        ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
        ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
        ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
    })
    
    gradient.Color = colorSequence
    
    local tween = TweenService:Create(gradient, TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1), {
        Rotation = 360
    })
    tween:Play()
    
    return gradient
end

-- Função para criar som de clique
local function playClickSound()
    clickSound:Play()
end

-- Função para criar botão com efeitos
local function createButton(parent, text, position, size, callback)
    local button = Instance.new("TextButton")
    button.Name = text
    button.Parent = parent
    button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    button.BorderSizePixel = 2
    button.BorderColor3 = Color3.fromRGB(100, 100, 100)
    button.Position = position
    button.Size = size
    button.Font = Enum.Font.GothamBold
    button.Text = text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextScaled = true
    button.TextStrokeTransparency = 0.5
    button.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = button
    
    -- Efeito hover
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 50, 50)}):Play()
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(30, 30, 30)}):Play()
    end)
    
    -- Efeito de clique
    button.MouseButton1Click:Connect(function()
        playClickSound()
        TweenService:Create(button, TweenInfo.new(0.1), {Size = size - UDim2.new(0, 5, 0, 5)}):Play()
        task.wait(0.1)
        TweenService:Create(button, TweenInfo.new(0.1), {Size = size}):Play()
        callback()
    end)
    
    return button
end

-- Função para atualizar cor do botão baseado no estado
local function updateButtonColor(button, state)
    local color = state and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    TweenService:Create(button, TweenInfo.new(0.3), {BackgroundColor3 = color}):Play()
end

-- Funções de funcionalidade
local function toggle2Dash()
    buttonStates.twoDash = not buttonStates.twoDash
    
    if buttonStates.twoDash then
        connections.twoDash = UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            if input.KeyCode == Enum.KeyCode.Z then
                local lookDirection = rootPart.CFrame.LookVector
                rootPart.Velocity = lookDirection * 100 + Vector3.new(0, 20, 0)
            end
        end)
    else
        if connections.twoDash then
            connections.twoDash:Disconnect()
            connections.twoDash = nil
        end
    end
end

local function toggleSpeedBoost()
    buttonStates.speedBoost = not buttonStates.speedBoost
    
    if buttonStates.speedBoost then
        humanoid.WalkSpeed = 50
        humanoid.JumpPower = 100
    else
        humanoid.WalkSpeed = 16
        humanoid.JumpPower = 50
    end
end

local function toggleJumpBoost()
    buttonStates.jumpBoost = not buttonStates.jumpBoost
    
    if buttonStates.jumpBoost then
        humanoid.JumpPower = 100
    else
        humanoid.JumpPower = 50
    end
end

local function saveCoordinate()
    config.savedCoordinate = rootPart.Position
    print("Coordenada salva:", config.savedCoordinate)
end

local function toggleTeleGuided()
    if not config.savedCoordinate then
        print("Nenhuma coordenada salva!")
        return
    end
    
    buttonStates.teleGuided = not buttonStates.teleGuided
    
    if buttonStates.teleGuided then
        local bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        bodyVelocity.Parent = rootPart
        
        connections.teleGuided = RunService.Heartbeat:Connect(function()
            if not config.savedCoordinate then return end
            
            local currentPos = rootPart.Position
            local targetPos = config.savedCoordinate
            local direction = (targetPos - currentPos).Unit
            local distance = (targetPos - currentPos).Magnitude
            
            if distance > 5 then
                bodyVelocity.Velocity = direction * 25
            else
                bodyVelocity:Destroy()
                buttonStates.teleGuided = false
                if connections.teleGuided then
                    connections.teleGuided:Disconnect()
                    connections.teleGuided = nil
                end
            end
        end)
    else
        if connections.teleGuided then
            connections.teleGuided:Disconnect()
            connections.teleGuided = nil
        end
        local bodyVel = rootPart:FindFirstChild("BodyVelocity")
        if bodyVel then bodyVel:Destroy() end
    end
end

local function toggleAntiHit()
    buttonStates.antiHit = not buttonStates.antiHit
    
    if buttonStates.antiHit then
        for _, part in pairs(character:GetChildren()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
        
        connections.antiHit = character.ChildAdded:Connect(function(child)
            if child:IsA("BasePart") then
                child.CanCollide = false
            end
        end)
    else
        for _, part in pairs(character:GetChildren()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.CanCollide = true
            end
        end
        
        if connections.antiHit then
            connections.antiHit:Disconnect()
            connections.antiHit = nil
        end
    end
end

-- Funções ESP
local function createESP(obj, color, text)
    local billboardGui = Instance.new("BillboardGui")
    billboardGui.Size = UDim2.new(0, 100, 0, 50)
    billboardGui.Adornee = obj
    billboardGui.AlwaysOnTop = true
    billboardGui.Parent = obj
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundColor3 = color
    frame.BackgroundTransparency = 0.7
    frame.Parent = billboardGui
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = text
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.TextStrokeTransparency = 0
    textLabel.Font = Enum.Font.GothamBold
    textLabel.TextScaled = true
    textLabel.Parent = frame
    
    return billboardGui
end

local function toggleESPGod()
    buttonStates.espGod = not buttonStates.espGod
    
    if buttonStates.espGod then
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:FindFirstChild("God") or obj.Name:lower():find("god") then
                local esp = createESP(obj, Color3.fromRGB(255, 215, 0), "GOD")
                table.insert(espObjects, esp)
            end
        end
    else
        for _, esp in pairs(espObjects) do
            if esp then esp:Destroy() end
        end
        espObjects = {}
    end
end

local function toggleESPSecret()
    buttonStates.espSecret = not buttonStates.espSecret
    
    if buttonStates.espSecret then
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj.Name:lower():find("secret") or obj.Name:lower():find("hidden") then
                local esp = createESP(obj, Color3.fromRGB(128, 0, 128), "SECRET")
                table.insert(espObjects, esp)
            end
        end
    else
        for _, esp in pairs(espObjects) do
            if esp then esp:Destroy() end
        end
        espObjects = {}
    end
end

local function toggleESPPlayer()
    buttonStates.espPlayer = not buttonStates.espPlayer
    
    if buttonStates.espPlayer then
        for _, otherPlayer in pairs(Players:GetPlayers()) do
            if otherPlayer ~= player and otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local esp = createESP(otherPlayer.Character.HumanoidRootPart, Color3.fromRGB(0, 255, 0), otherPlayer.Name)
                table.insert(espObjects, esp)
            end
        end
    else
        for _, esp in pairs(espObjects) do
            if esp then esp:Destroy() end
        end
        espObjects = {}
    end
end

local function toggleESPBase()
    buttonStates.espBase = not buttonStates.espBase
    
    if buttonStates.espBase then
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj.Name:lower():find("base") or obj.Name:lower():find("structure") then
                local esp = createESP(obj, Color3.fromRGB(0, 0, 255), "BASE")
                table.insert(espObjects, esp)
            end
        end
    else
        for _, esp in pairs(espObjects) do
            if esp then esp:Destroy() end
        end
        espObjects = {}
    end
end

-- Criação da interface principal
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SantzStore"
screenGui.Parent = playerGui
screenGui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Parent = screenGui
mainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
mainFrame.BackgroundTransparency = 0.3
mainFrame.BorderSizePixel = 3
mainFrame.Position = UDim2.new(0.1, 0, 0.1, 0)
mainFrame.Size = UDim2.new(0, 400, 0, 500)

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 15)
corner.Parent = mainFrame

-- Efeito RGB na borda
createRGBEffect(mainFrame)

-- Título
local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "Title"
titleLabel.Parent = mainFrame
titleLabel.BackgroundTransparency = 1
titleLabel.Position = UDim2.new(0, 0, 0, 0)
titleLabel.Size = UDim2.new(1, 0, 0, 50)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Text = "SANTZ STORE"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextScaled = true
titleLabel.TextStrokeTransparency = 0.5
titleLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)

-- Botão de minimizar
local minimizeButton = createButton(mainFrame, "─", UDim2.new(1, -35, 0, 5), UDim2.new(0, 30, 0, 20), function()
    local isMinimized = mainFrame.Size.Y.Offset <= 60
    
    if isMinimized then
        TweenService:Create(mainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {
            Size = UDim2.new(0, 400, 0, 500)
        }):Play()
        minimizeButton.Text = "─"
    else
        TweenService:Create(mainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {
            Size = UDim2.new(0, 400, 0, 60)
        }):Play()
        minimizeButton.Text = "□"
    end
end)

-- Botões principais
local buttonData = {
    {text = "2 DASH", pos = UDim2.new(0.05, 0, 0.15, 0), callback = function() toggle2Dash() end},
    {text = "SPEED BOOST", pos = UDim2.new(0.52, 0, 0.15, 0), callback = function() toggleSpeedBoost() end},
    {text = "JUMP BOOST", pos = UDim2.new(0.05, 0, 0.25, 0), callback = function() toggleJumpBoost() end},
    {text = "SALVAR CORDENADA", pos = UDim2.new(0.52, 0, 0.25, 0), callback = saveCoordinate},
    {text = "ATIVAR TELEGUIADO", pos = UDim2.new(0.05, 0, 0.35, 0), callback = function() toggleTeleGuided() end},
    {text = "ANTI-HIT", pos = UDim2.new(0.52, 0, 0.35, 0), callback = function() toggleAntiHit() end},
    {text = "ESP GOD", pos = UDim2.new(0.05, 0, 0.50, 0), callback = function() toggleESPGod() end},
    {text = "ESP SECRET", pos = UDim2.new(0.52, 0, 0.50, 0), callback = function() toggleESPSecret() end},
    {text = "ESP PLAYER", pos = UDim2.new(0.05, 0, 0.60, 0), callback = function() toggleESPPlayer() end},
    {text = "ESP BASE", pos = UDim2.new(0.52, 0, 0.60, 0), callback = function() toggleESPBase() end}
}

local buttons = {}
for _, data in pairs(buttonData) do
    local button = createButton(mainFrame, data.text, data.pos, UDim2.new(0, 180, 0, 35), function()
        data.callback()
        -- Atualizar cor do botão baseado no estado (se aplicável)
        local stateName = data.text:lower():gsub(" ", ""):gsub("-", "")
        if buttonStates[stateName] ~= nil then
            updateButtonColor(button, buttonStates[stateName])
        end
    end)
    buttons[data.text] = button
end

-- Tornar o painel arrastável
local dragging = false
local dragStart = nil
local startPos = nil

mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- Animação de entrada
mainFrame.Position = UDim2.new(-0.5, 0, 0.1, 0)
TweenService:Create(mainFrame, TweenInfo.new(1, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
    Position = UDim2.new(0.1, 0, 0.1, 0)
}):Play()

-- Reconexão quando o personagem respawna
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoid = character:WaitForChild("Humanoid")
    rootPart = character:WaitForChild("HumanoidRootPart")
    
    -- Reativar funcionalidades que estavam ativas
    for state, active in pairs(buttonStates) do
        if active then
            buttonStates[state] = false -- Reset state
            -- Reativar baseado no tipo
            if state == "twoDash" then toggle2Dash()
            elseif state == "speedBoost" then toggleSpeedBoost()
            elseif state == "jumpBoost" then toggleJumpBoost()
            elseif state == "antiHit" then toggleAntiHit()
            end
        end
    end
end)

print("SANTZ STORE carregado com sucesso!")
