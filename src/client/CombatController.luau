-- Controle local da ferramenta DZ-01. O cliente solicita; o servidor valida e aplica dano.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local CombatController = {}
local player = Players.LocalPlayer
local remotes
local equippedTool
local connections = {}

local function disconnectAll()
	for _, connection in ipairs(connections) do connection:Disconnect() end
	table.clear(connections)
end

local function fire()
	if not equippedTool or not equippedTool.Parent or not player.Character then return end
	local camera=workspace.CurrentCamera
	if not camera then return end
	remotes.CombatRequest:FireServer(camera.CFrame.Position,camera.CFrame.LookVector)
end

local function bindTool(tool)
	if tool.Name~="DZ-01" or not tool:IsA("Tool") then return end
	equippedTool=tool
	disconnectAll()
	table.insert(connections,tool.Activated:Connect(fire))
	table.insert(connections,tool.Unequipped:Connect(function() equippedTool=nil end))
end

function CombatController.Init()
	local folder=ReplicatedStorage:WaitForChild("DZ_Remotes")
	remotes={CombatRequest=folder:WaitForChild("CombatRequest"),ReloadRequest=folder:WaitForChild("ReloadRequest"),CombatFeedback=folder:WaitForChild("CombatFeedback")}
	remotes.CombatFeedback.OnClientEvent:Connect(function(data)
		if typeof(data)=="table" then
			player:SetAttribute("DZ_AmmoInMagazine",data.Ammo)
			player:SetAttribute("DZ_AmmoReserve",data.Reserve)
		end
	end)
	local function watchCharacter(character)
		character.ChildAdded:Connect(function(child) if child:IsA("Tool") then bindTool(child) end end)
		for _,child in ipairs(character:GetChildren()) do if child:IsA("Tool") then bindTool(child) end end
	end
	player.CharacterAdded:Connect(watchCharacter)
	if player.Character then watchCharacter(player.Character) end
	UserInputService.InputBegan:Connect(function(input,processed)
		if processed then return end
		if input.KeyCode==Enum.KeyCode.R and equippedTool then remotes.ReloadRequest:FireServer() end
	end)
end
return CombatController
