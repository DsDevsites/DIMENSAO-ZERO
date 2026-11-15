-- Inicializacao central do servidor DIMENSAO ZERO.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Constants = require(ReplicatedStorage.Shared:WaitForChild("Constants"))
local RemoteService = require(script:WaitForChild("RemoteService"))
local PlayerService = require(script:WaitForChild("PlayerService"))
local CombatService = require(script:WaitForChild("CombatService"))
local InventoryService = require(script:WaitForChild("InventoryService"))
local WorldBuilder = require(script:WaitForChild("WorldBuilder"))
local EnvironmentBuilder = require(script:WaitForChild("EnvironmentBuilder"))

local remotes = RemoteService.Init()
PlayerService.Init()
CombatService.Init(remotes)
InventoryService.Init(remotes)
WorldBuilder.Init()
EnvironmentBuilder.Init()

print(string.format("[%s] Servidor inicializado. Versao %s", Constants.GameName, Constants.Version))
