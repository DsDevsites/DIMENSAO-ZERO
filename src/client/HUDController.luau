-- HUD, inventario, painel de ajuda e controles desktop/mobile do DIMENSAO ZERO.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local CameraController = require(script.Parent:WaitForChild("CameraController"))
local FlashlightController = require(script.Parent:WaitForChild("FlashlightController"))

local HUDController = {}
local player = Players.LocalPlayer
local CYAN = Color3.fromRGB(65, 210, 225)
local PANEL = Color3.fromRGB(10, 17, 25)
local MUTED = Color3.fromRGB(155, 174, 188)
local inventoryRequest
local inventoryPanel
local helpPanel
local flashlightButton
local inventoryButton
local helpButton
local cameraButton
local healthFill
local healthText
local inventorySlots = {}
local panelOpen = nil
local helpShownThisSession = false

local function create(className, properties, parent)
    local instance = Instance.new(className)
    for property, value in properties do
        instance[property] = value
    end
    instance.Parent = parent
    return instance
end

local function round(instance, radius)
    create("UICorner", { CornerRadius = UDim.new(0, radius or 8) }, instance)
end

local function stroke(instance, color, transparency)
    create("UIStroke", {
        Color = color or CYAN,
        Transparency = transparency or 0.55,
        Thickness = 1,
    }, instance)
end

local function makeButton(parent, name, text, position, size)
    local button = create("TextButton", {
        Name = name,
        Position = position,
        Size = size,
        BackgroundColor3 = Color3.fromRGB(18, 55, 72),
        BorderSizePixel = 0,
        Font = Enum.Font.GothamBold,
        Text = text,
        TextColor3 = Color3.fromRGB(240, 248, 255),
        TextSize = 12,
        AutoButtonColor = true,
    }, parent)
    round(button, 7)
    return button
end

local function animatePanel(panel, visible)
    panel.Visible = true
    if visible then
        panel.BackgroundTransparency = 1
        TweenService:Create(panel, TweenInfo.new(0.18), { BackgroundTransparency = 0.06 }):Play()
    else
        local tween = TweenService:Create(panel, TweenInfo.new(0.14), { BackgroundTransparency = 1 })
        tween:Play()
        tween.Completed:Once(function()
            panel.Visible = false
        end)
    end
end

local function closePanels()
    if panelOpen == "Inventory" then animatePanel(inventoryPanel, false) end
    if panelOpen == "Help" then animatePanel(helpPanel, false) end
    panelOpen = nil
end

local function openPanel(name)
    closePanels()
    panelOpen = name
    if name == "Inventory" then
        animatePanel(inventoryPanel, true)
        inventoryRequest:FireServer("Request")
    elseif name == "Help" then
        animatePanel(helpPanel, true)
    end
end

local function togglePanel(name)
    if panelOpen == name then closePanels() else openPanel(name) end
end

local function updateCameraButton()
    cameraButton.Text = CameraController.IsFirstPerson() and "CÂMERA: 1ª PESSOA [V]" or "CÂMERA: 3ª PESSOA [V]"
end

local function updateFlashlightButton()
    flashlightButton.Text = FlashlightController.IsEnabled() and "LANTERNA: LIGADA [F]" or "LANTERNA: DESLIGADA [F]"
    flashlightButton.BackgroundColor3 = FlashlightController.IsEnabled()
        and Color3.fromRGB(20, 105, 112) or Color3.fromRGB(18, 55, 72)
end

local function updateHealth(humanoid)
    if not humanoid or not humanoid.Parent then return end
    local current = math.max(0, humanoid.Health)
    local maximum = math.max(1, humanoid.MaxHealth)
    local ratio = math.clamp(current / maximum, 0, 1)
    healthText.Text = string.format("%d / %d", math.floor(current + 0.5), math.floor(maximum + 0.5))
    healthFill.Size = UDim2.new(ratio, 0, 1, 0)
    healthFill.BackgroundColor3 = ratio <= 0.3 and Color3.fromRGB(235, 75, 75)
        or (ratio <= 0.6 and Color3.fromRGB(235, 170, 65) or CYAN)
end

local function bindCharacter(character)
    local humanoid = character:WaitForChild("Humanoid", 10)
    if not humanoid then return end
    updateHealth(humanoid)
    humanoid.HealthChanged:Connect(function() updateHealth(humanoid) end)
    humanoid:GetPropertyChangedSignal("MaxHealth"):Connect(function() updateHealth(humanoid) end)
end

local function renderInventory(slots, equippedItem)
    for index = 1, 20 do
        local item = slots[index]
        local button = inventorySlots[index]
        if item then
            button.Text = string.format("%02d\n%s\nx%d", index, item.name, item.quantity or 1)
            button.TextColor3 = Color3.fromRGB(230, 245, 250)
            button.BackgroundColor3 = item.id == equippedItem
                and Color3.fromRGB(20, 100, 110) or Color3.fromRGB(24, 35, 47)
        else
            button.Text = string.format("%02d\nVAZIO", index)
            button.TextColor3 = MUTED
            button.BackgroundColor3 = Color3.fromRGB(16, 25, 35)
        end
    end
end

function HUDController.Init()
    local playerGui = player:WaitForChild("PlayerGui")
    local existing = playerGui:FindFirstChild("DZ_HUD")
    if existing then existing:Destroy() end

    local remotes = ReplicatedStorage:WaitForChild("DZ_Remotes")
    inventoryRequest = remotes:WaitForChild("InventoryRequest")
    local inventoryUpdate = remotes:WaitForChild("InventoryUpdate")

    local gui = create("ScreenGui", {
        Name = "DZ_HUD",
        ResetOnSpawn = false,
        IgnoreGuiInset = false,
        DisplayOrder = 20,
    }, playerGui)

    local status = create("Frame", {
        Name = "StatusPanel",
        AnchorPoint = Vector2.new(0, 1),
        Position = UDim2.new(0, 14, 1, -14),
        Size = UDim2.new(0, 245, 0, 88),
        BackgroundColor3 = PANEL,
        BackgroundTransparency = 0.08,
        BorderSizePixel = 0,
    }, gui)
    round(status, 9); stroke(status)
    create("TextLabel", {
        BackgroundTransparency = 1, Position = UDim2.fromOffset(12, 7),
        Size = UDim2.new(1, -24, 0, 18), Font = Enum.Font.GothamBold,
        Text = string.upper(player.DisplayName), TextColor3 = Color3.fromRGB(240, 248, 255),
        TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
    }, status)
    healthText = create("TextLabel", {
        BackgroundTransparency = 1, Position = UDim2.fromOffset(12, 29),
        Size = UDim2.new(1, -24, 0, 16), Font = Enum.Font.GothamMedium,
        Text = "100 / 100", TextColor3 = CYAN, TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, status)
    local healthBack = create("Frame", {
        Position = UDim2.fromOffset(12, 51), Size = UDim2.new(1, -24, 0, 9),
        BackgroundColor3 = Color3.fromRGB(35, 45, 55), BorderSizePixel = 0,
    }, status)
    round(healthBack, 5)
    healthFill = create("Frame", {
        Size = UDim2.fromScale(1, 1), BackgroundColor3 = CYAN, BorderSizePixel = 0,
    }, healthBack)
    round(healthFill, 5)
    create("TextLabel", {
        BackgroundTransparency = 1, Position = UDim2.fromOffset(12, 65),
        Size = UDim2.new(1, -24, 0, 14), Font = Enum.Font.Gotham,
        Text = "MUNIÇÃO  -- / --     |     SETOR 01", TextColor3 = MUTED,
        TextSize = 9, TextXAlignment = Enum.TextXAlignment.Left,
    }, status)

    local actionFrame = create("Frame", {
        Name = "ActionButtons", AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -14, 0, 14), Size = UDim2.fromOffset(178, 158),
        BackgroundTransparency = 1,
    }, gui)
    inventoryButton = makeButton(actionFrame, "InventoryButton", "INVENTÁRIO [I]", UDim2.fromOffset(0, 0), UDim2.fromOffset(178, 34))
    flashlightButton = makeButton(actionFrame, "FlashlightButton", "LANTERNA: DESLIGADA [F]", UDim2.fromOffset(0, 40), UDim2.fromOffset(178, 34))
    helpButton = makeButton(actionFrame, "HelpButton", "?  AJUDA [H]", UDim2.fromOffset(0, 80), UDim2.fromOffset(178, 34))
    cameraButton = makeButton(actionFrame, "CameraToggle", "CÂMERA: 3ª PESSOA [V]", UDim2.fromOffset(0, 120), UDim2.fromOffset(178, 34))

    -- Inventário responsivo: cinco colunas por quatro linhas.
    inventoryPanel = create("Frame", {
        Name = "InventoryPanel", AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.new(0.9, 0, 0, 330),
        BackgroundColor3 = PANEL, BackgroundTransparency = 0.06,
        BorderSizePixel = 0, Visible = false,
    }, gui)
    round(inventoryPanel, 12); stroke(inventoryPanel)
    create("TextLabel", {
        BackgroundTransparency = 1, Position = UDim2.fromOffset(18, 12),
        Size = UDim2.new(1, -70, 0, 28), Font = Enum.Font.GothamBold,
        Text = "INVENTÁRIO  /  20 ESPAÇOS", TextColor3 = CYAN,
        TextSize = 17, TextXAlignment = Enum.TextXAlignment.Left,
    }, inventoryPanel)
    local invClose = makeButton(inventoryPanel, "CloseInventory", "X", UDim2.new(1, -44, 0, 10), UDim2.fromOffset(32, 30))
    local grid = create("Frame", {
        BackgroundTransparency = 1, Position = UDim2.fromOffset(16, 54),
        Size = UDim2.new(1, -32, 1, -70),
    }, inventoryPanel)
    create("UIGridLayout", {
        CellSize = UDim2.new(0.19, 0, 0, 54),
        CellPadding = UDim2.new(0.01, 0, 0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, grid)
    for index = 1, 20 do
        local slot = makeButton(grid, "Slot" .. index, string.format("%02d\nVAZIO", index), UDim2.new(), UDim2.fromOffset(60, 54))
        slot.LayoutOrder = index
        slot.TextSize = 10
        inventorySlots[index] = slot
        slot.Activated:Connect(function() inventoryRequest:FireServer("Equip", index) end)
    end
    invClose.Activated:Connect(closePanels)

    helpPanel = create("Frame", {
        Name = "HelpPanel", AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.new(0.9, 0, 0, 330),
        BackgroundColor3 = PANEL, BackgroundTransparency = 0.06,
        BorderSizePixel = 0, Visible = false,
    }, gui)
    round(helpPanel, 12); stroke(helpPanel)
    create("TextLabel", {
        BackgroundTransparency = 1, Position = UDim2.fromOffset(20, 15),
        Size = UDim2.new(1, -70, 0, 25), Font = Enum.Font.GothamBold,
        Text = "DIMENSÃO ZERO", TextColor3 = CYAN, TextSize = 19,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, helpPanel)
    create("TextLabel", {
        BackgroundTransparency = 1, Position = UDim2.fromOffset(20, 43),
        Size = UDim2.new(1, -40, 0, 22), Font = Enum.Font.Gotham,
        Text = "CENTRAL DE CONTROLES", TextColor3 = Color3.fromRGB(230, 240, 248),
        TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
    }, helpPanel)
    create("TextLabel", {
        BackgroundTransparency = 1, Position = UDim2.fromOffset(22, 82),
        Size = UDim2.new(1, -44, 0, 210), Font = Enum.Font.Gotham,
        Text = "W A S D   —   Movimentar\nESPAÇO   —   Pular\nMOUSE   —   Movimentar câmera\nV   —   Alternar primeira / terceira pessoa\nI   —   Abrir inventário\nF   —   Ligar / desligar lanterna\nH   —   Abrir este painel\nESC   —   Fechar painéis",
        TextColor3 = MUTED, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
    }, helpPanel)
    local helpClose = makeButton(helpPanel, "CloseHelp", "X", UDim2.new(1, -48, 0, 12), UDim2.fromOffset(32, 30))
    helpClose.Activated:Connect(closePanels)

    inventoryButton.Activated:Connect(function() togglePanel("Inventory") end)
    flashlightButton.Activated:Connect(function()
        FlashlightController.Toggle()
        updateFlashlightButton()
    end)
    helpButton.Activated:Connect(function() togglePanel("Help") end)
    cameraButton.Activated:Connect(function()
        CameraController.Toggle()
        updateCameraButton()
    end)

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if input.KeyCode == Enum.KeyCode.Escape then
            closePanels()
            return
        end
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.I then
            togglePanel("Inventory")
        elseif input.KeyCode == Enum.KeyCode.F then
            FlashlightController.Toggle()
            updateFlashlightButton()
        elseif input.KeyCode == Enum.KeyCode.H then
            togglePanel("Help")
        elseif input.KeyCode == Enum.KeyCode.V then
            task.defer(updateCameraButton)
        end
    end)

    inventoryUpdate.OnClientEvent:Connect(renderInventory)
    player.CharacterAdded:Connect(bindCharacter)
    if player.Character then task.spawn(bindCharacter, player.Character) end

    updateCameraButton()
    updateFlashlightButton()
    inventoryRequest:FireServer("Request")

    if not helpShownThisSession then
        helpShownThisSession = true
        task.delay(0.7, function()
            if helpPanel and helpPanel.Parent then openPanel("Help") end
        end)
    end
end

return HUDController
