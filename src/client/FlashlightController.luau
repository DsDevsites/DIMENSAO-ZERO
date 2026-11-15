-- Lanterna local: a luz acompanha a cabeca do personagem nas duas perspectivas.
local Players = game:GetService("Players")

local FlashlightController = {}
local player = Players.LocalPlayer
local enabled = false
local currentLight

local function attachToCharacter(character)
    local head = character:WaitForChild("Head", 10)
    if not head then
        return
    end

    local attachment = head:FindFirstChild("DZ_FlashlightAttachment")
    if not attachment then
        attachment = Instance.new("Attachment")
        attachment.Name = "DZ_FlashlightAttachment"
        attachment.Position = Vector3.new(0, 0, -0.45)
        attachment.Parent = head
    end

    local spot = attachment:FindFirstChild("DZ_Flashlight")
    if not spot then
        spot = Instance.new("SpotLight")
        spot.Name = "DZ_Flashlight"
        spot.Color = Color3.fromRGB(220, 245, 255)
        spot.Brightness = 2.6
        spot.Range = 42
        spot.Angle = 58
        spot.Shadows = true
        spot.Enabled = false
        spot.Parent = attachment
    end

    currentLight = spot
    currentLight.Enabled = enabled
end

function FlashlightController.SetEnabled(value)
    enabled = value == true
    if currentLight and currentLight.Parent then
        currentLight.Enabled = enabled
    elseif player.Character then
        task.spawn(attachToCharacter, player.Character)
    end
    return enabled
end

function FlashlightController.Toggle()
    return FlashlightController.SetEnabled(not enabled)
end

function FlashlightController.IsEnabled()
    return enabled
end

function FlashlightController.Init()
    player.CharacterAdded:Connect(function(character)
        currentLight = nil
        task.spawn(attachToCharacter, character)
    end)
    if player.Character then
        task.spawn(attachToCharacter, player.Character)
    end
end

return FlashlightController
