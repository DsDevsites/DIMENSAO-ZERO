-- Gerencia o ciclo de vida básico dos jogadores.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayerConfig = require(ReplicatedStorage.Shared:WaitForChild("PlayerConfig"))
local GameConfig = require(ReplicatedStorage.Shared:WaitForChild("GameConfig"))

local PlayerService = {}

local function configureCharacter(character)
    local humanoid = character:WaitForChild("Humanoid", 10)
    if not humanoid then
        warn("[DZ] Personagem surgiu sem Humanoid.")
        return
    end

    humanoid.MaxHealth = PlayerConfig.MaxHealth
    humanoid.Health = PlayerConfig.MaxHealth
    humanoid.WalkSpeed = PlayerConfig.WalkSpeed
    humanoid.UseJumpPower = true
    humanoid.JumpPower = PlayerConfig.JumpPower
end

local function onPlayerAdded(player)
    -- Dados temporários nesta versão. Persistência será implementada com DataStore
    -- após definirmos o formato definitivo dos dados do jogador.
    player:SetAttribute("DZ_DataLoaded", true)
    player:SetAttribute("DZ_Level", GameConfig.StartingLevel)
    player:SetAttribute("DZ_Experience", GameConfig.StartingExperience)

    player.CharacterAdded:Connect(configureCharacter)
    if player.Character then
        task.spawn(configureCharacter, player.Character)
    end

    print(string.format("[DZ] Jogador conectado: %s (%d)", player.Name, player.UserId))
end

function PlayerService.Init()
    Players.CharacterAutoLoads = true
    Players.PlayerAdded:Connect(onPlayerAdded)
    Players.PlayerRemoving:Connect(function(player)
        print(string.format("[DZ] Jogador desconectado: %s", player.Name))
    end)

    for _, player in Players:GetPlayers() do
        task.spawn(onPlayerAdded, player)
    end
end

return PlayerService
