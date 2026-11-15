-- Ponto central de inicialização do servidor DIMENSÃO ZERO.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Constants = require(ReplicatedStorage.Shared:WaitForChild("Constants"))
local RemoteService = require(script:WaitForChild("RemoteService"))
local PlayerService = require(script:WaitForChild("PlayerService"))
local CombatService = require(script:WaitForChild("CombatService"))

local remotes = RemoteService.Init()
PlayerService.Init()
CombatService.Init(remotes)

print(string.format("[%s] Servidor inicializado. Versão %s", Constants.GameName, Constants.Version))
