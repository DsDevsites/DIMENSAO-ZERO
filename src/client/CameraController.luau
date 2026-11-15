-- Alternancia de camera entre primeira e terceira pessoa.
-- Mantem o controle de camera padrao do Roblox, inclusive no celular.
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Shared:WaitForChild("GameConfig"))
local CameraController = {}

local player = Players.LocalPlayer
local firstPerson = false

local function applyCameraMode()
    if firstPerson then
        player.CameraMode = Enum.CameraMode.LockFirstPerson
    else
        player.CameraMode = Enum.CameraMode.Classic
        player.CameraMinZoomDistance = 0.5
        player.CameraMaxZoomDistance = 12
    end
end

function CameraController.Toggle()
    firstPerson = not firstPerson
    applyCameraMode()
    print("[DIMENSAO ZERO] Camera: " .. (firstPerson and "primeira pessoa" or "terceira pessoa"))
    return firstPerson
end

function CameraController.IsFirstPerson()
    return firstPerson
end

function CameraController.Init()
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode[GameConfig.CameraToggleKeyName] then
            CameraController.Toggle()
        end
    end)

    player.CharacterAdded:Connect(function()
        task.wait(0.2)
        applyCameraMode()
    end)

    applyCameraMode()
end

return CameraController
