-- Camera DZ: usa a camera padrao do Roblox e altera somente o zoom.
-- Isso evita dois controladores concorrentes e preserva mouse/touch/gamepad.
local Players = game:GetService("Players")
local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameConfig = require(ReplicatedStorage.Shared:WaitForChild("GameConfig"))

local CameraController = {}
local player = Players.LocalPlayer
local firstPerson = false
local ACTION = "DZ_ToggleCamera"

local function applyCameraMode()
	player.CameraMode = Enum.CameraMode.Classic
	if firstPerson then
		player.CameraMinZoomDistance = 0.5
		player.CameraMaxZoomDistance = 0.5
	else
		player.CameraMinZoomDistance = 6
		player.CameraMaxZoomDistance = 14
	end
end

function CameraController.Toggle()
	firstPerson = not firstPerson
	applyCameraMode()
	print("[DZ] Câmera: " .. (firstPerson and "primeira pessoa" or "terceira pessoa"))
	return firstPerson
end

function CameraController.SetMode(value)
	firstPerson = value == "FirstPerson" or value == true
	applyCameraMode()
	return firstPerson
end

function CameraController.IsFirstPerson()
	return firstPerson
end

function CameraController.Init()
	ContextActionService:UnbindAction(ACTION)
	ContextActionService:BindActionAtPriority(ACTION, function(_, state)
		if state == Enum.UserInputState.Begin then
			CameraController.Toggle()
		end
		return Enum.ContextActionResult.Sink
	end, false, 3000, Enum.KeyCode[GameConfig.CameraToggleKeyName or "V"])

	player.CharacterAdded:Connect(function()
		task.wait(0.25)
		applyCameraMode()
	end)
	applyCameraMode()
end

return CameraController
