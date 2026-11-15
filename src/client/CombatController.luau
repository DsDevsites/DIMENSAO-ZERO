-- Ponte cliente para o sistema de combate. Não calcula dano nem munição localmente.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Constants = require(ReplicatedStorage.Shared:WaitForChild("Constants"))

local CombatController = {}
local remotes

function CombatController.Init()
    local folder = ReplicatedStorage:WaitForChild(Constants.RemotesFolderName)
    remotes = {
        CombatRequest = folder:WaitForChild(Constants.CombatRequestName),
        CombatFeedback = folder:WaitForChild(Constants.CombatFeedbackName),
        ReloadRequest = folder:WaitForChild(Constants.ReloadRequestName),
    }

    remotes.CombatFeedback.OnClientEvent:Connect(function(payload)
        if typeof(payload) == "table" then
            print(string.format("[DZ] Combate: %s | Munição: %s",
                tostring(payload.Type), tostring(payload.Ammo)))
        end
    end)
end

function CombatController.RequestShot(origin, direction)
    if remotes then
        remotes.CombatRequest:FireServer(origin, direction)
    end
end

function CombatController.RequestReload()
    if remotes then
        remotes.ReloadRequest:FireServer()
    end
end

return CombatController
