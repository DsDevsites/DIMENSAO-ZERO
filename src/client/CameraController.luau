-- Alternância simples entre primeira e terceira pessoa.
-- Usa as propriedades padrão da câmera do Roblox para preservar os controles móveis.
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Shared:WaitForChild("GameConfig"))
local CameraController = {}

local player = Players.LocalPlayer
local firstPerson = false

local function applyCameraMode()
    player.CameraMode = firstPerson and Enum.CameraMode.LockFirstPerson or Enum.CameraMode.Classic
end

function CameraController.Toggle()
    firstPerson = not firstPerson
    applyCameraMode()
    return firstPerson
end

function CameraController.IsFirstPerson()
    return firstPerson
end

function CameraController.Init()
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then
            return
        end
        if input.KeyCode.Name == GameConfig.CameraToggleKeyName then
            CameraController.Toggle()
        end
    end)
    applyCameraMode()
end

return CameraController
