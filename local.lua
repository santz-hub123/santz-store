-- SANTZ STORE V2.0 - MOBILE OPTIMIZED MAIN PANEL
-- github.com/santz-hub123

local Services = {
    Players = game:GetService("Players"),
    TweenService = game:GetService("TweenService"),
    UserInputService = game:GetService("UserInputService"),
    SoundService = game:GetService("SoundService"),
    Workspace = game:GetService("Workspace"),
    StarterGui = game:GetService("StarterGui"),
}

local Player = Services.Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local Theme = {
    MainBg = Color3.fromRGB(30,30,36),
    Accent = Color3.fromRGB(0, 255, 127),
    Button = Color3.fromRGB(50,50,60),
    ButtonHover = Color3.fromRGB(70,70,80),
    Enabled = Color3.fromRGB(0, 220, 110),
    Disabled = Color3.fromRGB(220, 60, 60),
    Info = Color3.fromRGB(100, 150, 255),
    ESPGod = Color3.fromRGB(160, 32, 240),
    ESPSecret = Color3.fromRGB(255,255,255),
    ESPPlayer = Color3.fromRGB(0,150,255),
    ESPName = Color3.fromRGB(255, 105, 180),
    ESPItem = Color3.fromRGB(50, 205, 50),
    PanelTransparency = 0.09,
}

local ToggleStates = {
    ESP_GOD = false,
    ESP_SECRET = false,
    ESP_PLAYER = false,
    ESP_NAME = false,
    ESP_ITEM = false,
    SUPERMAN = false,
    NOCLIP = false,
}

local function playSound(soundId, volume)
    local sound = Instance.new("Sound", Services.SoundService)
    sound.SoundId = "rbxassetid://" .. tostring(soundId)
    sound.Volume = volume or 0.4
    sound:Play()
    sound.Ended:Connect(function() sound:Destroy() end)
end

local function ShowNotification(title, text, duration)
    Services.StarterGui:SetCore("SendNotification", {
        Title = title or "SANTZ STORE",
        Text = text or "",
        Duration = duration or 3,
        Icon = "rbxassetid://6031094678"
    })
end

-- Draggable function for mobile and desktop
local function MakeDraggable(frame)
    local dragging = false
    local dragStart, startPos

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
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

    frame.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

local function CreateStyledButton(parent, text, color, pos, size, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Text = text
    btn.BackgroundColor3 = color or Theme.Button
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamBold
    btn.TextScaled = true
    btn.Size = size or UDim2.new(1, -20, 0, 45)
    btn.Position = pos or UDim2.new(0,10,0,0)
    btn.AutoButtonColor = false
    local corner = Instance.new("UICorner", btn) corner.CornerRadius = UDim.new(0,10)
    btn.MouseEnter:Connect(function() btn.BackgroundColor3 = Theme.ButtonHover end)
    btn.MouseLeave:Connect(function() btn.BackgroundColor3 = color or Theme.Button end)
    btn.TouchTap:Connect(function()
        playSound(131961136, 0.19)
        if callback then callback(btn) end
    end)
    btn.MouseButton1Click:Connect(function()
        playSound(131961136, 0.19)
        if callback then callback(btn) end
    end)
    return btn
end

local function CreateMainPanel()
    if PlayerGui:FindFirstChild("SantzMobileMain") then
        PlayerGui.SantzMobileMain:Destroy()
    end

    local ScreenGui = Instance.new("ScreenGui", PlayerGui)
    ScreenGui.Name = "SantzMobileMain"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local MainFrame = Instance.new("Frame", ScreenGui)
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 260, 0, 400)
    MainFrame.Position = UDim2.new(0.5, -130, 0.5, -200)
    MainFrame.BackgroundColor3 = Theme.MainBg
    MainFrame.BackgroundTransparency = Theme.PanelTransparency
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true

    local corner = Instance.new("UICorner", MainFrame)
    corner.CornerRadius = UDim.new(0, 16)
    MakeDraggable(MainFrame)

    local Title = Instance.new("TextLabel", MainFrame)
    Title.Size = UDim2.new(1,0,0,48)
    Title.Position = UDim2.new(0,0,0,0)
    Title.BackgroundTransparency = 1
    Title.Text = "🚀 SANTZ STORE MOBILE"
    Title.TextColor3 = Theme.Accent
    Title.TextScaled = true
    Title.Font = Enum.Font.GothamBold

    local CloseBtn = CreateStyledButton(MainFrame, "✖ FECHAR", Theme.Disabled, UDim2.new(0,10,0,340), UDim2.new(1,-20,0,45), function()
        MainFrame.Visible = false
    end)

    -- Button List
    local btnY = 60
    local btns = {
        {txt="ESP GOD", color=Theme.ESPGod, desc="Detecta players com poderes divinos", func=function()
            ToggleStates.ESP_GOD = not ToggleStates.ESP_GOD
            ShowNotification("ESP GOD", ToggleStates.ESP_GOD and "Ativado" or "Desativado",2)
        end},
        {txt="ESP SECRET", color=Theme.ESPSecret, desc="Revela áreas secretas ocultas", func=function()
            ToggleStates.ESP_SECRET = not ToggleStates.ESP_SECRET
            ShowNotification("ESP SECRET", ToggleStates.ESP_SECRET and "Ativado" or "Desativado",2)
        end},
        {txt="ESP PLAYER", color=Theme.ESPPlayer, desc="Destaca todos os players", func=function()
            ToggleStates.ESP_PLAYER = not ToggleStates.ESP_PLAYER
            ShowNotification("ESP PLAYER", ToggleStates.ESP_PLAYER and "Ativado" or "Desativado",2)
        end},
        {txt="ESP NAME (RGB)", color=Theme.ESPName, desc="Exibe nomes dos players (arco-íris)", func=function()
            ToggleStates.ESP_NAME = not ToggleStates.ESP_NAME
            ShowNotification("ESP NAME", ToggleStates.ESP_NAME and "Ativado" or "Desativado",2)
        end},
        {txt="ESP ITEM", color=Theme.ESPItem, desc="Localiza itens importantes", func=function()
            ToggleStates.ESP_ITEM = not ToggleStates.ESP_ITEM
            ShowNotification("ESP ITEM", ToggleStates.ESP_ITEM and "Ativado" or "Desativado",2)
        end},
        {txt="SUPERMAN", color=Theme.Enabled, desc="Modo Superman ativado", func=function()
            ToggleStates.SUPERMAN = not ToggleStates.SUPERMAN
            ShowNotification("SUPERMAN", ToggleStates.SUPERMAN and "Ativado" or "Desativado",2)
        end},
        {txt="NOCLIP", color=Theme.Info, desc="Atravessa paredes", func=function()
            ToggleStates.NOCLIP = not ToggleStates.NOCLIP
            ShowNotification("NOCLIP", ToggleStates.NOCLIP and "Ativado" or "Desativado",2)
        end},
        {txt="TELEPORTE", color=Theme.Accent, desc="Painel de teleporte", func=function()
            if not PlayerGui:FindFirstChild("SantzMobileTele") then
                ShowNotification("TELEPORTE", "Painel de teleporte aberto!",2)
                CreateTelePanel(ScreenGui) -- função abaixo
            else
                PlayerGui.SantzMobileTele.MainFrame.Visible = not PlayerGui.SantzMobileTele.MainFrame.Visible
            end
        end},
    }
    for i, btn in ipairs(btns) do
        CreateStyledButton(MainFrame, btn.txt, btn.color, UDim2.new(0,10,0,btnY), UDim2.new(1,-20,0,40), btn.func)
        btnY = btnY + 46
    end
end

-- Painel de Teleporte (mobile, independente)
function CreateTelePanel(parentGui)
    local TeleGui = Instance.new("ScreenGui", parentGui)
    TeleGui.Name = "SantzMobileTele"
    TeleGui.ResetOnSpawn = false
    TeleGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local MainFrame = Instance.new("Frame", TeleGui)
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0,220,0,260)
    MainFrame.Position = UDim2.new(0.5,120,0.5,-100)
    MainFrame.BackgroundColor3 = Theme.MainBg
    MainFrame.BackgroundTransparency = Theme.PanelTransparency
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    local corner = Instance.new("UICorner", MainFrame)
    corner.CornerRadius = UDim.new(0,14)
    MakeDraggable(MainFrame)

    local Title = Instance.new("TextLabel", MainFrame)
    Title.Size = UDim2.new(1,0,0,38)
    Title.Position = UDim2.new(0,0,0,0)
    Title.BackgroundTransparency = 1
    Title.Text = "🚀 TELEPORTE"
    Title.TextColor3 = Theme.Accent
    Title.TextScaled = true
    Title.Font = Enum.Font.GothamBold

    local CloseBtn = CreateStyledButton(MainFrame, "✖", Theme.Disabled, UDim2.new(1,-50,0,12), UDim2.new(0,38,0,33), function()
        MainFrame.Visible = false
    end)

    -- Adicione aqui sua lógica de teleporte (botões de players, posição, etc)
    local Info = Instance.new("TextLabel", MainFrame)
    Info.Size = UDim2.new(1,-16,0,60)
    Info.Position = UDim2.new(0,8,0,50)
    Info.BackgroundTransparency = 1
    Info.Text = "Funções de teleporte disponíveis em breve!"
    Info.TextColor3 = Theme.Info
    Info.TextScaled = true
    Info.Font = Enum.Font.Gotham
end

-- Inicialização
CreateMainPanel()
ShowNotification("SANTZ STORE MOBILE", "Painel carregado! Toque nos botões para ativar/desativar funções.", 5)

-- FIM --  
