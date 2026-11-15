-- Inventario autoritativo em memoria. DataStore sera conectado em etapa propria.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local InventoryService = {}
local inventories = {}
local SLOT_COUNT = 20
local MEDKIT_HEAL = 40

local DEFINITIONS = {
	DZ_RIFLE = {id="DZ_RIFLE", name="Rifle DZ-01", category="Arma", description="Rifle de assalto de serviço da instalação. 30 disparos por carregador.", stack=false},
	MEDKIT = {id="MEDKIT", name="Kit Médico", category="Consumível", description="Recupera 40 pontos de vida. Não pode ser usado com vida cheia.", stack=true},
	AMMO_556 = {id="AMMO_556", name="Munição 5.56", category="Munição", description="Munição de reserva compatível com a DZ-01.", stack=true},
	DZ_FLASHLIGHT = {id="DZ_FLASHLIGHT", name="Lanterna DZ", category="Equipamento", description="Lanterna tática integrada. Tecla F.", stack=false},
}

local function newInventory()
	local slots = table.create(SLOT_COUNT, false)
	slots[1] = {id="DZ_RIFLE", name=DEFINITIONS.DZ_RIFLE.name, category="Arma", description=DEFINITIONS.DZ_RIFLE.description, quantity=1}
	slots[2] = {id="MEDKIT", name=DEFINITIONS.MEDKIT.name, category="Consumível", description=DEFINITIONS.MEDKIT.description, quantity=2}
	slots[3] = {id="AMMO_556", name=DEFINITIONS.AMMO_556.name, category="Munição", description=DEFINITIONS.AMMO_556.description, quantity=90}
	slots[4] = {id="DZ_FLASHLIGHT", name=DEFINITIONS.DZ_FLASHLIGHT.name, category="Equipamento", description=DEFINITIONS.DZ_FLASHLIGHT.description, quantity=1}
	return slots
end

local function safeSnapshot(slots)
	local copy = table.create(SLOT_COUNT)
	for i=1,SLOT_COUNT do
		local item = slots[i]
		copy[i] = item and {
			id=item.id, name=item.name, category=item.category,
			description=item.description, quantity=item.quantity
		} or false
	end
	return copy
end

local function send(player)
	local slots = inventories[player.UserId]
	if slots then
		ReplicatedStorage.DZ_Remotes.InventoryUpdate:FireClient(player, safeSnapshot(slots), player:GetAttribute("DZ_EquippedItem"))
	end
end

local function makeRifleTool()
	local tool = Instance.new("Tool")
	tool.Name = "DZ-01"
	tool.ToolTip = "Rifle de assalto | Clique para disparar | R para recarregar"
	tool.RequiresHandle = true
	tool.CanBeDropped = false
	tool:SetAttribute("DZ_WeaponId", "DZ-01")
	local handle = Instance.new("Part")
	handle.Name = "Handle"
	handle.Size = Vector3.new(0.45, 0.55, 2.1)
	handle.Color = Color3.fromRGB(45, 50, 56)
	handle.Material = Enum.Material.Metal
	handle.CanCollide = false
	handle.Massless = true
	handle.Parent = tool
	local barrel = Instance.new("Part")
	barrel.Name = "Barrel"
	barrel.Size = Vector3.new(0.16, 0.16, 1.2)
	barrel.Color = Color3.fromRGB(25, 29, 34)
	barrel.Material = Enum.Material.Metal
	barrel.CanCollide = false
	barrel.Massless = true
	barrel.CFrame = handle.CFrame * CFrame.new(0, 0.05, -1.45)
	barrel.Parent = tool
	local muzzleLight = Instance.new("PointLight")
	muzzleLight.Name = "DZ_MuzzleFlash"
	muzzleLight.Color = Color3.fromRGB(255, 205, 130)
	muzzleLight.Brightness = 3
	muzzleLight.Range = 7
	muzzleLight.Enabled = false
	muzzleLight.Parent = barrel
	local weld = Instance.new("WeldConstraint")
	weld.Part0 = handle
	weld.Part1 = barrel
	weld.Parent = handle
	local sight = Instance.new("Part")
	sight.Name = "Sight"
	sight.Size = Vector3.new(0.18, 0.18, 0.45)
	sight.Color = Color3.fromRGB(90, 98, 104)
	sight.Material = Enum.Material.Metal
	sight.CanCollide = false
	sight.Massless = true
	sight.CFrame = handle.CFrame * CFrame.new(0, 0.32, -0.1)
	sight.Parent = tool
	local sightWeld = Instance.new("WeldConstraint")
	sightWeld.Part0 = handle
	sightWeld.Part1 = sight
	sightWeld.Parent = handle
	return tool
end

local function giveRifle(player)
	local backpack = player:FindFirstChildOfClass("Backpack") or player:WaitForChild("Backpack", 5)
	if not backpack then return end
	if backpack:FindFirstChild("DZ-01") or (player.Character and player.Character:FindFirstChild("DZ-01")) then return end
	makeRifleTool().Parent = backpack
end

local function onPlayerAdded(player)
	inventories[player.UserId] = newInventory()
	player:SetAttribute("DZ_EquippedItem", nil)
	player:SetAttribute("DZ_AmmoInMagazine", 30)
	player:SetAttribute("DZ_AmmoReserve", 90)
	player.CharacterAdded:Connect(function()
		task.delay(0.5, function() giveRifle(player) end)
	end)
	task.defer(function()
		giveRifle(player)
		send(player)
	end)
end

function InventoryService.Init()
	local remotes = ReplicatedStorage:WaitForChild("DZ_Remotes")
	remotes.InventoryRequest.OnServerEvent:Connect(function(player, action, slotIndex)
		local slots = inventories[player.UserId]
		if not slots or typeof(action) ~= "string" then return end
		if action == "Request" then send(player); return end
		if action == "Equip" then
			if typeof(slotIndex) ~= "number" or slotIndex % 1 ~= 0 or slotIndex < 1 or slotIndex > SLOT_COUNT then return end
			local item = slots[slotIndex]
			if not item then return end
			if item.id == "DZ_RIFLE" then
				giveRifle(player)
				local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
				local tool = player:FindFirstChildOfClass("Backpack") and player.Backpack:FindFirstChild("DZ-01")
				if humanoid and tool then humanoid:EquipTool(tool) end
				player:SetAttribute("DZ_EquippedItem", item.id)
			else
				player:SetAttribute("DZ_EquippedItem", item.id)
			end
			send(player)
		elseif action == "Unequip" then
			local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
			if humanoid then humanoid:UnequipTools() end
			player:SetAttribute("DZ_EquippedItem", nil)
			send(player)
		elseif action == "Use" then
			if typeof(slotIndex) ~= "number" or slotIndex % 1 ~= 0 or slotIndex < 1 or slotIndex > SLOT_COUNT then return end
			local item = slots[slotIndex]
			if not item or item.id ~= "MEDKIT" or item.quantity < 1 then return end
			local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
			if not humanoid or humanoid.Health <= 0 or humanoid.Health >= humanoid.MaxHealth then return end
			humanoid.Health = math.min(humanoid.MaxHealth, humanoid.Health + MEDKIT_HEAL)
			item.quantity -= 1
			if item.quantity <= 0 then slots[slotIndex] = false end
			send(player)
		end
	end)
	Players.PlayerAdded:Connect(onPlayerAdded)
	Players.PlayerRemoving:Connect(function(player) inventories[player.UserId] = nil end)
	for _, player in Players:GetPlayers() do onPlayerAdded(player) end
end

return InventoryService
