-- SANTZ STORE Script
-- Baseado no design original com modificações personalizadas

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local PathfindingService = game:GetService("PathfindingService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

-- Dados persistentes
getgenv().SantzStore = getgenv().SantzStore or {}
local data = getgenv().SantzStore
data.savedCoordinate = data.savedCoordinate or nil
data.connections = data.connections or {}
data.espObjects = data.espObjects or {}
data.states = data.states or {
    twoDash = false,
    speedBoost = false,
    jumpBoost = false,
    antiHit = false,
    teleGuided = false,
    espGod = false,
    espSecret = false,
    espPlayer = false,
    espBase = false
}

-- Limpar GUI anterior
if CoreGui:FindFirstChild("SantzStore") then
    CoreGui:FindFirstChild("SantzStore"):Destroy()
end

-- Limpar conexões antigas
for _, conn in pairs(data.connections) do
    if conn and conn.Connected then
        conn:Disconnect()
    end
end
data.connections = {}

-- Limpar ESP anterior
for _, esp in pairs(data.espObjects) do
    if esp and esp.Parent then
        esp:Destroy()
    end
end
data.espObjects = {}

-- Criar ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SantzStore"
screenGui.Parent = CoreGui

-- Frame Principal
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 420, 0, 580)
mainFrame.Position = UDim2.new(0.5, -210, 0.5, -290)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

-- Cantos arredondados para o frame principal
local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = mainFrame

-- Borda RGB animada para o frame principal
local mainStroke = Instance.new("UIStroke")
mainStroke.Thickness = 3
mainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
mainStroke.Parent = mainFrame

local mainGradient = Instance.new("UIGradient")
mainGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
    ColorSequenceKeypoint.new(0.16, Color3.fromRGB(255, 165, 0)),
    ColorSequenceKeypoint.new(0.33, Color3.fromRGB(255, 255, 0)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 0)),
    ColorSequenceKeypoint.new(0.66, Color3.fromRGB(0, 255, 255)),
    ColorSequenceKeypoint.new(0.83, Color3.fromRGB(0, 0, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 255))
}
mainGradient.Parent = mainStroke

-- Animação RGB
local rgbTween = TweenService:Create(mainGradient, TweenInfo.new(3, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1), {Rotation = 360})
rgbTween:Play()

-- Título
local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "Title"
titleLabel.Size = UDim2.new(1, -80, 0, 60)
titleLabel.Position = UDim2.new(0, 0, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "SANTZ STORE"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextScaled = true
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextStrokeTransparency = 0.5
titleLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
titleLabel.Parent = mainFrame

-- Botão Minimizar
local minimizeButton = Instance.new("TextButton")
minimizeButton.Name = "MinimizeButton"
minimizeButton.Size = UDim2.new(0, 40, 0, 30)
minimizeButton.Position = UDim2.new(1, -50, 0, 15)
minimizeButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
minimizeButton.Text = "—"
minimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeButton.TextScaled = true
minimizeButton.Font = Enum.Font.GothamBold
minimizeButton.BorderSizePixel = 0
minimizeButton.Parent = mainFrame

local minimizeCorner = Instance.new("UICorner")
minimizeCorner.CornerRadius = UDim.new(0, 6)
minimizeCorner.Parent = minimizeButton

-- Container para os botões (será escondido quando minimizado)
local buttonsContainer = Instance.new("Frame")
buttonsContainer.Name = "ButtonsContainer"
buttonsContainer.Size = UDim2.new(1, -20, 1, -80)
buttonsContainer.Position = UDim2.new(0, 10, 0, 70)
buttonsContainer.BackgroundTransparency = 1
buttonsContainer.Parent = mainFrame

-- Função para criar botões com RGB
local function createButton(name, text, position, size, callback, toggleable)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Size = size
    button.Position = position
    button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    button.Text = text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextScaled = true
    button.Font = Enum.Font.Gotham
    button.BorderSizePixel = 0
    button.Parent = buttonsContainer
    
    -- Cantos arredondados
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = button
    
    -- Borda RGB para botões
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 2
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = button
    
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
        ColorSequenceKeypoint.new(0.16, Color3.fromRGB(255, 165, 0)),
        ColorSequenceKeypoint.new(0.33, Color3.fromRGB(255, 255, 0)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 0)),
        ColorSequenceKeypoint.new(0.66, Color3.fromRGB(0, 255, 255)),
        ColorSequenceKeypoint.new(0.83, Color3.fromRGB(0, 0, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 255))
    }
    gradient.Parent = stroke
    
    -- Animação RGB do botão
    local buttonRgbTween = TweenService:Create(gradient, TweenInfo.new(3, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1), {Rotation = 360})
    buttonRgbTween:Play()
    
    -- Efeitos hover
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 50, 50)}):Play()
    end)
    
    button.MouseLeave:Connect(function()
        local color = Color3.fromRGB(30, 30, 30)
        if toggleable and data.states[name] then
            color = Color3.fromRGB(0, 120, 0)
        end
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = color}):Play()
    end)
    
    -- Clique
    button.MouseButton1Click:Connect(function()
        -- Efeito de clique
        TweenService:Create(button, TweenInfo.new(0.1), {Size = size * 0.95}):Play()
        task.wait(0.1)
        TweenService:Create(button, TweenInfo.new(0.1), {Size = size}):Play()
        
        callback()
        
        -- Atualizar cor se for toggleable
        if toggleable then
            local color = data.states[name] and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(30, 30, 30)
            TweenService:Create(button, TweenInfo.new(0.3), {BackgroundColor3 = color}):Play()
        end
    end)
    
    return button
end

-- Funções de funcionalidade
local function toggle2Dash()
    data.states.twoDash = not data.states.twoDash
    
    if data.states.twoDash then
        data.connections.twoDash = UserInputService.InputBegan:Connect(function(input)
            if input.KeyCode == Enum.KeyCode.Z and rootPart then
                local bodyVelocity = Instance.new("BodyVelocity")
                bodyVelocity.MaxForce = Vector3.new(math.huge, 0, math.huge)
                bodyVelocity.Velocity = rootPart.CFrame.LookVector * 100
                bodyVelocity.Parent = rootPart
                
                game:GetService("Debris"):AddItem(bodyVelocity, 0.4)
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
    
    if data.states.speedBoost then
        humanoid.WalkSpeed = 50
        if humanoid:FindFirstChild("JumpHeight") then
            humanoid.JumpHeight = 50
        else
            humanoid.JumpPower = 100
        end
    else
        humanoid.WalkSpeed = 16
        if humanoid:FindFirstChild("JumpHeight") then
            humanoid.JumpHeight = 7.2
        else
            humanoid.JumpPower = 50
        end
    end
end

local function toggleJumpBoost()
    data.states.jumpBoost = not data.states.jumpBoost
    
    if data.states.jumpBoost then
        if humanoid:FindFirstChild("JumpHeight") then
            humanoid.JumpHeight = 50
        else
            humanoid.JumpPower = 100
        end
    else
        if humanoid:FindFirstChild("JumpHeight") then
            humanoid.JumpHeight = 7.2
        else
            humanoid.JumpPower = 50
        end
    end
end

local function saveCoordinate()
    if rootPart then
        data.savedCoordinate = rootPart.Position
        print("🟢 Coordenada salva:", data.savedCoordinate)
    end
end

-- Sistema de teleporte inteligente com pathfinding
local function toggleTeleGuided()
    if not data.savedCoordinate then
        print("❌ Nenhuma coordenada salva!")
        return
    end
    
    data.states.teleGuided = not data.states.teleGuided
    
    if data.states.teleGuided then
        local bodyPosition = Instance.new("BodyPosition")
        bodyPosition.MaxForce = Vector3.new(4000, 4000, 4000)
        bodyPosition.Position = rootPart.Position
        bodyPosition.D = 2000
        bodyPosition.P = 10000
        bodyPosition.Parent = rootPart
        
        data.connections.teleGuided = RunService.Heartbeat:Connect(function()
            if not data.savedCoordinate or not rootPart then return end
            
            local currentPos = rootPart.Position
            local targetPos = data.savedCoordinate
            local distance = (targetPos - currentPos).Magnitude
            
            if distance > 5 then
                -- Verificar se há obstáculos no caminho
                local raycast = workspace:Raycast(currentPos, (targetPos - currentPos).Unit * math.min(distance, 50))
                
                if raycast and raycast.Instance then
                    -- Há obstáculo, tentar contornar
                    local hitNormal = raycast.Normal
                    local sideVector = Vector3.new(-hitNormal.Z, 0, hitNormal.X).Unit * 10
                    local alternativeTarget = currentPos + (targetPos - currentPos).Unit * 20 + sideVector
                    
                    bodyPosition.Position = alternativeTarget
                else
                    -- Caminho livre, ir direto
                    bodyPosition.Position = targetPos
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
        
        print("🚀 Teleporte iniciado...")
    else
        if data.connections.teleGuided then
            data.connections.teleGuided:Disconnect()
            data.connections.teleGuided = nil
        end
        local bodyPos = rootPart:FindFirstChild("BodyPosition")
        if bodyPos then bodyPos:Destroy() end
        print("🛑 Teleporte cancelado")
    end
end

local function toggleAntiHit()
    data.states.antiHit = not data.states.antiHit
    
    if data.states.antiHit then
        for _, part in pairs(character:GetChildren()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.CanCollide = false
            end
        end
        
        data.connections.antiHit = character.ChildAdded:Connect(function(child)
            if child:IsA("BasePart") and child.Name ~= "HumanoidRootPart" then
                child.CanCollide = false
            end
        end)
    else
        for _, part in pairs(character:GetChildren()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.CanCollide = true
            end
        end
        
        if data.connections.antiHit then
            data.connections.antiHit:Disconnect()
            data.connections.antiHit = nil
        end
    end
end

-- Funções ESP
local function createESP(obj, color, text)
    if not obj or not obj.Parent then return end
    
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 100, 0, 50)
    billboard.Adornee = obj
    billboard.AlwaysOnTop = true
    billboard.Parent = obj
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundColor3 = color
    frame.BackgroundTransparency = 0.3
    frame.BorderSizePixel = 0
    frame.Parent = billboard
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.TextStrokeTransparency = 0
    label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    label.Parent = frame
    
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

local function toggleESPGod()
    data.states.espGod = not data.states.espGod
    
    if data.states.espGod then
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj.Name:lower():find("god") or (obj:FindFirstChild("Humanoid") and obj:FindFirstChild("God")) then
                if obj:FindFirstChild("HumanoidRootPart") then
                    createESP(obj.HumanoidRootPart, Color3.fromRGB(255, 215, 0), "GOD")
                end
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
                createESP(obj, Color3.fromRGB(128, 0, 128), "SECRET")
            end
        end
    else
        clearESP()
    end
end

local function toggleESPPlayer()
    data.states.espPlayer = not data.states.espPlayer
    
    if data.states.espPlayer then
        for _, otherPlayer in pairs(Players:GetPlayers()) do
            if otherPlayer ~= player and otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
                createESP(otherPlayer.Character.HumanoidRootPart, Color3.fromRGB(0, 255, 0), otherPlayer.Name)
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
            if obj.Name:lower():find("base") or obj.Name:lower():find("building") or obj.Name:lower():find("structure") then
                createESP(obj, Color3.fromRGB(0, 0, 255), "BASE")
            end
        end
    else
        clearESP()
    end
end

-- Criar todos os botões
createButton("twoDash", "2 DASH", UDim2.new(0, 0, 0, 0), UDim2.new(0, 190, 0, 45), toggle2Dash, true)
createButton("speedBoost", "SPEED BOOST", UDim2.new(0, 210, 0, 0), UDim2.new(0, 190, 0, 45), toggleSpeedBoost, true)
createButton("jumpBoost", "JUMP BOOST", UDim2.new(0, 0, 0, 60), UDim2.new(0, 190, 0, 45), toggleJumpBoost, true)
createButton("saveCoord", "SALVAR CORDENADA", UDim2.new(0, 210, 0, 60), UDim2.new(0, 190, 0, 45), saveCoordinate, false)
createButton("teleGuided", "ATIVAR TELEGUIADO", UDim2.new(0, 0, 0, 120), UDim2.new(0, 190, 0, 45), toggleTeleGuided, true)
createButton("antiHit", "ANTI-HIT", UDim2.new(0, 210, 0, 120), UDim2.new(0, 190, 0, 45), toggleAntiHit, true)
createButton("espGod", "ESP GOD", UDim2.new(0, 0, 0, 180), UDim2.new(0, 120, 0, 40), toggleESPGod, true)
createButton("espSecret", "ESP SECRET", UDim2.new(0, 140, 0, 180), UDim2.new(0, 120, 0, 40), toggleESPSecret, true)
createButton("espPlayer", "ESP PLAYER", UDim2.new(0, 280, 0, 180), UDim2.new(0, 120, 0, 40), toggleESPPlayer, true)
createButton("espBase", "ESP BASE", UDim2.new(0, 0, 0, 240), UDim2.new(0, 120, 0, 40), toggleESPBase, true)

-- Funcionalidade do botão minimizar
local isMinimized = false
minimizeButton.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    
    if isMinimized then
        -- Minimizar - mostrar apenas o título
        TweenService:Create(mainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {
            Size = UDim2.new(0, 420, 0, 60)
        }):Play()
        TweenService:Create(buttonsContainer, TweenInfo.new(0.3), {
            BackgroundTransparency = 1
        }):Play()
        buttonsContainer.Visible = false
        minimizeButton.Text = "+"
    else
        -- Maximizar - mostrar tudo
        buttonsContainer.Visible = true
        TweenService:Create(mainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {
            Size = UDim2.new(0, 420, 0, 580)
        }):Play()
        TweenService:Create(buttonsContainer, TweenInfo.new(0.3), {
            BackgroundTransparency = 0
        }):Play()
        minimizeButton.Text = "—"
    end
end)

-- Tornar o painel arrastável
local dragging = false
local dragStart = nil
local startPos = nil

titleLabel.InputBegan:Connect(function(input)
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
mainFrame.Position = UDim2.new(0.5, -210, -1, 0)
TweenService:Create(mainFrame, TweenInfo.new(1, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Position = UDim2.new(0.5, -210, 0.5, -290)
}):Play()

-- Reconectar quando respawnar
player.CharacterAdded:Connect(function(newCharacter)
    task.wait(2)
    character = newCharacter
    humanoid = character:WaitForChild("Humanoid")
    rootPart = character:WaitForChild("HumanoidRootPart")
    
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

print("🟢 SANTZ STORE carregado com sucesso!")
print("📍 Arraste pelo título para mover o painel")
print("⚡ Pressione Z para usar 2 DASH quando ativo")
print("💾 Coordenadas salvas persistem após respawn")
