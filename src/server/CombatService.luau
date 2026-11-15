-- Combate autoritativo: cliente envia apenas origem/direcao; servidor valida arma, cadencia e dano.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CombatConfig = require(ReplicatedStorage.Shared:WaitForChild("CombatConfig"))
local CombatService = {}
local states = {}

local function validVector(v)
	return typeof(v) == "Vector3" and v.X == v.X and v.Y == v.Y and v.Z == v.Z
		and math.abs(v.X) < 100000 and math.abs(v.Y) < 100000 and math.abs(v.Z) < 100000
end

local function feedback(remote, player, kind, state)
	remote:FireClient(player, {Type=kind, Ammo=state.Ammo, Reserve=state.Reserve})
	player:SetAttribute("DZ_AmmoInMagazine", state.Ammo)
	player:SetAttribute("DZ_AmmoReserve", state.Reserve)
end

function CombatService.Init(remotes)
	remotes.CombatRequest.OnServerEvent:Connect(function(player, origin, direction)
		if not CombatConfig.Enabled or not validVector(origin) or not validVector(direction) then return end
		local character = player.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		local head = character and character:FindFirstChild("Head")
		local equipped = character and character:FindFirstChild("DZ-01")
		if not humanoid or humanoid.Health <= 0 or not head or not equipped or not equipped:IsA("Tool") then return end
		if direction.Magnitude < 0.98 or direction.Magnitude > 1.02 then return end
		if (origin - head.Position).Magnitude > CombatConfig.OriginTolerance then return end
		local now = os.clock()
		local state = states[player]
		if not state then state = {LastShot=0, Ammo=CombatConfig.MagazineSize, Reserve=CombatConfig.ReserveAmmo, Reloading=false}; states[player]=state end
		if state.Reloading or now-state.LastShot < CombatConfig.ShotCooldown then return end
		if state.Ammo <= 0 then feedback(remotes.CombatFeedback, player, "Empty", state); return end
		state.LastShot = now
		state.Ammo -= 1
		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude
		params.FilterDescendantsInstances = {character}
		params.IgnoreWater = true
		local result = workspace:Raycast(origin, direction.Unit * CombatConfig.MaxShotDistance, params)
		if result then
			local model = result.Instance:FindFirstAncestorOfClass("Model")
			local target = model and model:FindFirstChildOfClass("Humanoid")
			if target and target.Health > 0 and model ~= character then
				local damage = CombatConfig.BodyDamage
				if result.Instance.Name == "Head" then damage *= CombatConfig.HeadshotMultiplier end
				target:TakeDamage(damage)
			end
		end
		feedback(remotes.CombatFeedback, player, "Shot", state)
	end)

	remotes.ReloadRequest.OnServerEvent:Connect(function(player)
		local state = states[player]
		local character = player.Character
		if not state or state.Reloading or not character or not character:FindFirstChild("DZ-01") then return end
		if state.Ammo >= CombatConfig.MagazineSize or state.Reserve <= 0 then return end
		state.Reloading = true
		task.delay(CombatConfig.ReloadTime, function()
			if player.Parent ~= Players then return end
			local needed = CombatConfig.MagazineSize - state.Ammo
			local loaded = math.min(needed, state.Reserve)
			state.Ammo += loaded
			state.Reserve -= loaded
			state.Reloading = false
			feedback(remotes.CombatFeedback, player, "Reloaded", state)
		end)
	end)
	Players.PlayerRemoving:Connect(function(player) states[player] = nil end)
end

return CombatService
