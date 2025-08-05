-- SANTZ HUB - Painel Teleporte Integrável
-- github.com/santz-hub123

local Services = {
    Players = game:GetService("Players"),
    TweenService = game:GetService("TweenService"),
    UserInputService = game:GetService("UserInputService"),
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    SoundService = game:GetService("SoundService"),
    RunService = game:GetService("RunService"),
    Workspace = game:GetService("Workspace"),
}

local Player = Services.Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- Posição TP persistente entre respawns
local TPData = Services.ReplicatedStorage:FindFirstChild("SantzHub_TPCoord")
if not TPData then
    TPData = Instance.new("Vector3Value", Services.ReplicatedStorage)
    TPData.Name = "SantzHub_TPCoord"
    TPData.Value = Vector3.new(0,0,0)
end

local antiHitActive = false

-- Sons
local function playSound(id, vol)
    local sound = Instance.new("Sound", Services.SoundService)
    sound.SoundId = "rbxassetid://"..tostring(id)
    sound.Volume = vol or 0.4
    sound:Play()
    sound.Ended:Connect(function() sound:Destroy() end)
end

-- Feedback visual no botão
local function feedback(btn, color, msg)
    local old = btn.BackgroundColor3
    local oldText = btn.Text
    btn.BackgroundColor3 = color
    playSound(131961136,0.35)
    btn.Text = msg
    task.wait(0.45)
    btn.BackgroundColor3 = old
    btn.Text = oldText
end

-- Contorno RGB animado
local function RGBStroke(frame, thick)
    local stroke = Instance.new("UIStroke", frame)
    stroke.Thickness = thick or 3
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Transparency = 0.1
    task.spawn(function()
        local hue = 0
        while frame.Parent do
            hue = (hue + 0.01)%1
            stroke.Color = Color3.fromHSV(hue,1,1)
            task.wait(0.02)
        end
    end)
    return stroke
end

-- Movível (mouse/touch)
local function MakeDraggable(frame)
    local dragging, dragStart, startPos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    frame.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- ANTI-HIT
local function setAntiHit(enable)
    antiHitActive = enable
    local char = Player.Character
    if not char then return end
    for _,part in ipairs(char:GetChildren()) do
        if part:IsA("BasePart") then
            part.CanCollide = not enable
            part.Transparency = enable and 0.7 or 0
        end
    end
    local hum = char:FindFirstChildWhichIsA("Humanoid")
    if hum then hum:SetStateEnabled(Enum.HumanoidStateType.Physics, not enable) end
end

-- TELEGUIADO (voo animado + desvio)
local function teleGuiadoTP()
    local char = Player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if root and TPData.Value.Magnitude > 0 then
        local dest = TPData.Value
        local flySpeed = 55
        local maxTime = 18
        local t = 0
        local landed = false
        -- Função para checar chão seguro
        local function safeY(pos)
            local ray = Ray.new(pos + Vector3.new(0,5,0), Vector3.new(0,-14,0))
            local part, point = workspace:FindPartOnRay(ray, char)
            return part and (point.Y+3) or (pos.Y+3)
        end
        -- Voo suave + desvio
        while (root.Position - dest).Magnitude > 10 and t < maxTime and char and char.Parent do
            local dir = (dest - root.Position).Unit
            local nextPos = root.Position + dir * flySpeed * Services.RunService.Heartbeat:Wait()
            -- Detecta obstáculo
            local ray = Ray.new(root.Position, dir*8)
            local hit = workspace:FindPartOnRay(ray, char)
            if hit then
                nextPos = root.Position + Vector3.new(math.random(-10,10), 10, math.random(-10,10))
            end
            root.CFrame = root.CFrame:Lerp(CFrame.new(nextPos), 0.22)
            t = t + Services.RunService.Heartbeat:Wait()
        end
        -- Descida suave até chão seguro
        local groundY = safeY(dest)
        for i=1,25 do
            local p = root.Position
            root.CFrame = root.CFrame:Lerp(CFrame.new(Vector3.new(dest.X, groundY, dest.Z)), 0.12)
            Services.RunService.Heartbeat:Wait()
        end
        playSound(6023426925,0.3)
    end
end

-- Painel
local panelObj = nil
local function createPanel()
    if panelObj and panelObj.Parent then
        panelObj.Parent:Destroy()
    end
    local gui = Instance.new("ScreenGui", PlayerGui)
    gui.Name = "SantzHubTeleportPanel"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local panel = Instance.new("Frame", gui)
    panelObj = panel
    panel.Name = "MainPanel"
    panel.Size = UDim2.new(0, 260, 0, 185)
    panel.Position = UDim2.new(0.5, -130, 0.5, -90)
    panel.BackgroundColor3 = Color3.fromRGB(12,12,12)
    panel.BorderSizePixel = 0
    panel.Active = true
    local corner = Instance.new("UICorner", panel)
    corner.CornerRadius = UDim.new(0,14)
    RGBStroke(panel, 4)
    MakeDraggable(panel)

    -- Título
    local title = Instance.new("TextLabel", panel)
    title.Size = UDim2.new(1,0,0,32)
    title.Position = UDim2.new(0,0,0,0)
    title.BackgroundTransparency = 1
    title.Text = "🌈 SANTZ HUB"
    title.TextColor3 = Color3.fromRGB(255,255,255)
    title.Font = Enum.Font.GothamBold
    title.TextScaled = true

    -- Minimizar/Reabrir
    local minimized = false
    local minBtn = Instance.new("ImageButton", panel)
    minBtn.Name = "MinimizeBtn"
    minBtn.Size = UDim2.new(0,26,0,26)
    minBtn.Position = UDim2.new(1,-32,0,2)
    minBtn.BackgroundTransparency = 1
    minBtn.Image = "rbxassetid://6031094678"
    minBtn.ImageColor3 = Color3.fromRGB(0,255,127)
    minBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        playSound(131961136,0.22)
        if minimized then
            for _,v in pairs(panel:GetChildren()) do
                if v:IsA("TextButton") then v.Visible = false end
            end
            panel.Size = UDim2.new(0, 110, 0, 38)
            minBtn.Image = "rbxassetid://6026568198"
        else
            for _,v in pairs(panel:GetChildren()) do
                if v:IsA("TextButton") then v.Visible = true end
            end
            panel.Size = UDim2.new(0, 260, 0, 185)
            minBtn.Image = "rbxassetid://6031094678"
        end
    end)

    -- Botão SALVAR TP
    local saveBtn = Instance.new("TextButton", panel)
    saveBtn.Name = "SALVAR TP"
    saveBtn.Text = "SALVAR TP"
    saveBtn.Size = UDim2.new(1,-40,0,40)
    saveBtn.Position = UDim2.new(0,20,0,40)
    saveBtn.BackgroundColor3 = Color3.fromRGB(20,20,30)
    saveBtn.TextColor3 = Color3.fromRGB(0,255,127)
    saveBtn.Font = Enum.Font.GothamBold
    saveBtn.TextScaled = true
    local saveCorner = Instance.new("UICorner", saveBtn)
    saveCorner.CornerRadius = UDim.new(0,10)
    saveBtn.MouseButton1Click:Connect(function()
        local char = Player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root then
            TPData.Value = root.Position
            feedback(saveBtn, Color3.fromRGB(0,220,110), "SALVO!")
        else
            feedback(saveBtn, Color3.fromRGB(220,60,60), "ERRO!")
        end
    end)

    -- Botão ATIVAR TELEGUIADO
    local activeBtn = Instance.new("TextButton", panel)
    activeBtn.Name = "ATIVAR TELEGUIADO"
    activeBtn.Text = "ATIVAR TELEGUIADO"
    activeBtn.Size = UDim2.new(1,-40,0,40)
    activeBtn.Position = UDim2.new(0,20,0,86)
    activeBtn.BackgroundColor3 = Color3.fromRGB(20,20,30)
    activeBtn.TextColor3 = Color3.fromRGB(100,150,255)
    activeBtn.Font = Enum.Font.GothamBold
    activeBtn.TextScaled = true
    local actCorner = Instance.new("UICorner", activeBtn)
    actCorner.CornerRadius = UDim.new(0,10)
    activeBtn.MouseButton1Click:Connect(function()
        feedback(activeBtn, Color3.fromRGB(0,220,110), "VOANDO...")
        teleGuiadoTP()
        feedback(activeBtn, Color3.fromRGB(100,150,255), "CONCLUÍDO")
    end)

    -- Botão ANTI-HIT
    local antihitBtn = Instance.new("TextButton", panel)
    antihitBtn.Name = "ANTI-HIT"
    antihitBtn.Text = "ANTI-HIT"
    antihitBtn.Size = UDim2.new(1,-40,0,40)
    antihitBtn.Position = UDim2.new(0,20,0,132)
    antihitBtn.BackgroundColor3 = Color3.fromRGB(20,20,30)
    antihitBtn.TextColor3 = Color3.fromRGB(220,60,60)
    antihitBtn.Font = Enum.Font.GothamBold
    antihitBtn.TextScaled = true
    local ahCorner = Instance.new("UICorner", antihitBtn)
    ahCorner.CornerRadius = UDim.new(0,10)
    antihitBtn.MouseButton1Click:Connect(function()
        antiHitActive = not antiHitActive
        setAntiHit(antiHitActive)
        local color = antiHitActive and Color3.fromRGB(0,220,110) or Color3.fromRGB(220,60,60)
        local msg = antiHitActive and "ATIVO" or "DESLIGADO"
        feedback(antihitBtn, color, msg)
    end)
end

-- AUTO-RESTORE ANTI-HIT EM RESPAWN
Services.Players.LocalPlayer.CharacterAdded:Connect(function()
    if antiHitActive then
        task.wait(1)
        setAntiHit(true)
    end
end)

-- API para integração ao hub principal
local SantzHubTeleportPanel = {
    init = createPanel,
    saveTP = function()
        local char = Player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root then TPData.Value = root.Position end
    end,
    activateTeleGuiado = teleGuiadoTP,
    toggleAntiHit = function()
        antiHitActive = not antiHitActive
        setAntiHit(antiHitActive)
    end,
    isAntiHitActive = function() return antiHitActive end
}

return SantzHubTeleportPanel
