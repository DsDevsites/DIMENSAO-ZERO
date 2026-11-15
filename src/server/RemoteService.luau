-- Centraliza os RemoteEvents do jogo.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Constants = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Constants"))

local RemoteService = {}

function RemoteService.Init()
    local folder = ReplicatedStorage:FindFirstChild(Constants.RemotesFolderName)
    if not folder then
        folder = Instance.new("Folder")
        folder.Name = Constants.RemotesFolderName
        folder.Parent = ReplicatedStorage
    end

    local function getOrCreateRemote(name)
        local remote = folder:FindFirstChild(name)
        if not remote then
            remote = Instance.new("RemoteEvent")
            remote.Name = name
            remote.Parent = folder
        end
        return remote
    end

    return {
        CombatRequest = getOrCreateRemote(Constants.CombatRequestName),
        CombatFeedback = getOrCreateRemote(Constants.CombatFeedbackName),
        ReloadRequest = getOrCreateRemote(Constants.ReloadRequestName),
        InventoryRequest = getOrCreateRemote("InventoryRequest"),
        InventoryUpdate = getOrCreateRemote("InventoryUpdate"),
    }
end

return RemoteService
