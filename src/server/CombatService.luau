-- Base segura do combate. O servidor controla cadência, munição e dano.
-- Nenhuma arma é habilitada nesta etapa (CombatConfig.Enabled = false).
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CombatConfig = require(ReplicatedStorage.Shared:WaitForChild("CombatConfig"))

local CombatService = {}
local shotState = {}

local function validVector3(value)
    return typeof(value) == "Vector3"
        and value.X == value.X and value.Y == value.Y and value.Z == value.Z
        and math.abs(value.X) < 100000
        and math.abs(value.Y) < 100000
        and math.abs(value.Z) < 100000
end

local function sendFeedback(remote, player, message, ammo)
    remote:FireClient(player, {
        Type = message,
        Ammo = ammo,
    })
end

function CombatService.Init(remotes)
    remotes.CombatRequest.OnServerEvent:Connect(function(player, origin, direction)
        if not CombatConfig.Enabled then
            return
        end
        if not validVector3(origin) or not validVector3(direction) then
            return
        end

        local character = player.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local head = character and character:FindFirstChild("Head")
        if not humanoid or humanoid.Health <= 0 or not head then
            return
        end

        local directionMagnitude = direction.Magnitude
        if directionMagnitude < 0.9 or directionMagnitude > 1.1 then
            return
        end
        if (origin - head.Position).Magnitude > CombatConfig.OriginTolerance then
            return
        end

        local now = os.clock()
        local state = shotState[player]
        if not state then
            state = { LastShot = 0, Ammo = CombatConfig.MagazineSize, Reloading = false }
            shotState[player] = state
        end
        if state.Reloading or now - state.LastShot < CombatConfig.ShotCooldown then
            return
        end
        if state.Ammo <= 0 then
            sendFeedback(remotes.CombatFeedback, player, "Empty", state.Ammo)
            return
        end

        state.LastShot = now
        state.Ammo -= 1

        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        params.FilterDescendantsInstances = { character }
        params.IgnoreWater = true

        local result = workspace:Raycast(origin, direction.Unit * CombatConfig.MaxShotDistance, params)
        if result then
            local targetModel = result.Instance:FindFirstAncestorOfClass("Model")
            local targetHumanoid = targetModel and targetModel:FindFirstChildOfClass("Humanoid")
            if targetHumanoid and targetHumanoid.Health > 0 and targetModel ~= character then
                local damage = CombatConfig.BodyDamage
                if result.Instance.Name == "Head" then
                    damage *= CombatConfig.HeadshotMultiplier
                end
                targetHumanoid:TakeDamage(damage)
            end
        end

        sendFeedback(remotes.CombatFeedback, player, "Shot", state.Ammo)
    end)

    remotes.ReloadRequest.OnServerEvent:Connect(function(player)
        if not CombatConfig.Enabled then
            return
        end
        local state = shotState[player]
        if not state or state.Reloading or state.Ammo >= CombatConfig.MagazineSize then
            return
        end

        state.Reloading = true
        task.delay(CombatConfig.ReloadTime, function()
            if player.Parent ~= Players then
                return
            end
            state.Ammo = CombatConfig.MagazineSize
            state.Reloading = false
            sendFeedback(remotes.CombatFeedback, player, "Reloaded", state.Ammo)
        end)
    end)

    Players.PlayerRemoving:Connect(function(player)
        shotState[player] = nil
    end)
end

return CombatService
