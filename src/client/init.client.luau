-- Ponto central de inicialização do cliente DIMENSÃO ZERO.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Constants = require(ReplicatedStorage.Shared:WaitForChild("Constants"))
local CameraController = require(script:WaitForChild("CameraController"))
local CombatController = require(script:WaitForChild("CombatController"))
local HUDController = require(script:WaitForChild("HUDController"))

CameraController.Init()
CombatController.Init()
HUDController.Init()

print(string.format("[%s] Cliente inicializado. Versão %s", Constants.GameName, Constants.Version))
