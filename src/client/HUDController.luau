-- Interface inicial criada por código para funcionar em desktop e telas touch.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CameraController = require(script.Parent:WaitForChild("CameraController"))

local HUDController = {}
local player = Players.LocalPlayer

local function create(className, properties, parent)
    local instance = Instance.new(className)
    for property, value in properties do
        instance[property] = value
    end
    instance.Parent = parent
    return instance
end

function HUDController.Init()
    local playerGui = player:WaitForChild("PlayerGui")
    local existing = playerGui:FindFirstChild("DZ_HUD")
    if existing then
        existing:Destroy()
    end

    local gui = create("ScreenGui", {
        Name = "DZ_HUD",
        ResetOnSpawn = false,
        IgnoreGuiInset = false,
        DisplayOrder = 10,
    }, playerGui)

    local panel = create("Frame", {
        Name = "StatusPanel",
        AnchorPoint = Vector2.new(0, 1),
        Position = UDim2.new(0, 16, 1, -16),
        Size = UDim2.fromOffset(230, 76),
        BackgroundColor3 = Color3.fromRGB(12, 16, 22),
        BackgroundTransparency = 0.12,
        BorderSizePixel = 0,
    }, gui)
    create("UICorner", { CornerRadius = UDim.new(0, 8) }, panel)

    local title = create("TextLabel", {
        Name = "PlayerName",
        Position = UDim2.fromOffset(12, 7),
        Size = UDim2.new(1, -24, 0, 20),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = string.upper(player.DisplayName),
        TextColor3 = Color3.fromRGB(235, 240, 245),
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, panel)

    local healthText = create("TextLabel", {
        Name = "Health",
        Position = UDim2.fromOffset(12, 32),
        Size = UDim2.new(1, -24, 0, 18),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Text = "VIDA 100 / 100",
        TextColor3 = Color3.fromRGB(110, 220, 145),
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, panel)

    local weaponText = create("TextLabel", {
        Name = "Weapon",
        Position = UDim2.fromOffset(12, 52),
        Size = UDim2.new(1, -24, 0, 16),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Text = "SEM ARMA EQUIPADA",
        TextColor3 = Color3.fromRGB(175, 185, 195),
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, panel)

    local cameraButton = create("TextButton", {
        Name = "CameraToggle",
        AnchorPoint = Vector2.new(1, 1),
        Position = UDim2.new(1, -16, 1, -16),
        Size = UDim2.fromOffset(150, 42),
        BackgroundColor3 = Color3.fromRGB(20, 75, 105),
        BorderSizePixel = 0,
        Font = Enum.Font.GothamBold,
        Text = "CÂMERA: 3ª PESSOA",
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 11,
        AutoButtonColor = true,
    }, gui)
    create("UICorner", { CornerRadius = UDim.new(0, 8) }, cameraButton)

    local function updateHealth()
        local character = player.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            healthText.Text = string.format("VIDA %d / %d",
                math.floor(humanoid.Health + 0.5), math.floor(humanoid.MaxHealth + 0.5))
            healthText.TextColor3 = humanoid.Health <= 30
                and Color3.fromRGB(245, 90, 80)
                or Color3.fromRGB(110, 220, 145)
            humanoid.HealthChanged:Connect(updateHealth)
        end
    end

    local function updateCameraButton()
        cameraButton.Text = CameraController.IsFirstPerson()
            and "CÂMERA: 1ª PESSOA"
            or "CÂMERA: 3ª PESSOA"
    end

    cameraButton.Activated:Connect(function()
        CameraController.Toggle()
        updateCameraButton()
    end)

    player.CharacterAdded:Connect(function()
        task.wait(0.2)
        updateHealth()
    end)
    if player.Character then
        updateHealth()
    end

    updateCameraButton()
end

return HUDController
