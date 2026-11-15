-- Ponto central de inicializacao do servidor DIMENSAO ZERO.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Constants = require(ReplicatedStorage.Shared:WaitForChild("Constants"))
local RemoteService = require(script:WaitForChild("RemoteService"))
local PlayerService = require(script:WaitForChild("PlayerService"))
local CombatService = require(script:WaitForChild("CombatService"))
local WorldBuilder = require(script:WaitForChild("WorldBuilder"))

local remotes = RemoteService.Init()
PlayerService.Init()
CombatService.Init(remotes)
WorldBuilder.Init()

print(string.format("[%s] Servidor inicializado. Versao %s", Constants.GameName, Constants.Version))
