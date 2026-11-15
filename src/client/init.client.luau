-- Inicializacao central do cliente DIMENSAO ZERO.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Constants = require(ReplicatedStorage.Shared:WaitForChild("Constants"))
local CameraController = require(script:WaitForChild("CameraController"))
local FlashlightController = require(script:WaitForChild("FlashlightController"))
local CombatController = require(script:WaitForChild("CombatController"))
local HUDController = require(script:WaitForChild("HUDController"))

CameraController.Init()
FlashlightController.Init()
CombatController.Init()
HUDController.Init()

print(string.format("[%s] Cliente inicializado. Versao %s", Constants.GameName, Constants.Version))
