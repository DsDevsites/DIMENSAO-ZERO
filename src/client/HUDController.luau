-- Interface principal DZ: inventario E, lanterna F, camera V, ajuda H.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CameraController = require(script.Parent:WaitForChild("CameraController"))
local FlashlightController = require(script.Parent:WaitForChild("FlashlightController"))

local HUD = {}
local player = Players.LocalPlayer
local palette = {
	panel=Color3.fromRGB(24,29,34), panel2=Color3.fromRGB(35,41,47),
	line=Color3.fromRGB(94,108,118), text=Color3.fromRGB(232,236,238),
	muted=Color3.fromRGB(158,168,174), accent=Color3.fromRGB(111,151,174),
	good=Color3.fromRGB(92,158,119), danger=Color3.fromRGB(190,75,67),
}
local inventoryRemote, inventoryPanel, helpPanel, detailLabel, useButton
local slots, items = {}, {}
local selectedIndex = nil
local panelOpen = nil
local buttons = {}

local function make(class, props, parent)
	local obj=Instance.new(class)
	for k,v in pairs(props) do obj[k]=v end
	obj.Parent=parent
	return obj
end
local function style(obj, radius)
	make("UICorner",{CornerRadius=UDim.new(0,radius or 7)},obj)
	make("UIStroke",{Color=palette.line,Transparency=0.55,Thickness=1},obj)
end
local function button(parent,name,text,pos,size)
	local b=make("TextButton",{Name=name,Text=text,Position=pos,Size=size,
		BackgroundColor3=palette.panel2,BorderSizePixel=0,TextColor3=palette.text,
		Font=Enum.Font.GothamSemibold,TextSize=12,AutoButtonColor=true},parent)
	style(b,7); return b
end
local function closePanels()
	if inventoryPanel then inventoryPanel.Visible=false end
	if helpPanel then helpPanel.Visible=false end
	panelOpen=nil
end
local function openPanel(which)
	closePanels(); panelOpen=which
	local panel=which=="Inventory" and inventoryPanel or helpPanel
	panel.Visible=true; panel.BackgroundTransparency=1
	TweenService:Create(panel,TweenInfo.new(0.16),{BackgroundTransparency=0.03}):Play()
	if which=="Inventory" then inventoryRemote:FireServer("Request") end
end
local function toggle(which)
	if panelOpen==which then closePanels() else openPanel(which) end
end
local function updateCamera()
	if buttons.camera then buttons.camera.Text=CameraController.IsFirstPerson() and "1ª PESSOA  [V]" or "3ª PESSOA  [V]" end
end
local function updateFlashlight()
	if buttons.flashlight then buttons.flashlight.Text=FlashlightController.IsEnabled() and "LANTERNA  LIGADA [F]" or "LANTERNA  DESLIGADA [F]" end
end
local function renderInventory(data,equipped)
	items=data or {}
	for i=1,20 do
		local item=items[i]
		local b=slots[i]
		if item then
			b.Text=string.format("%02d\n%s\n×%s",i,item.name or item.id,item.quantity or 1)
			b.BackgroundColor3=(item.id==equipped) and Color3.fromRGB(62,88,103) or palette.panel2
			b.TextColor3=palette.text
		else
			b.Text=string.format("%02d\nVAZIO",i)
			b.BackgroundColor3=palette.panel
			b.TextColor3=palette.muted
		end
	end
	if selectedIndex and items[selectedIndex] then
		local item=items[selectedIndex]
		detailLabel.Text=item.name.."  |  "..(item.category or "Item").."\n"..(item.description or "")
		useButton.Visible=item.id=="MEDKIT"
	else
		detailLabel.Text="Selecione um item para ver seus detalhes."
		useButton.Visible=false
	end
end
local function bindHealth(character, healthText, fill)
	local hum=character:WaitForChild("Humanoid",10); if not hum then return end
	local function update()
		local ratio=math.clamp(hum.Health/math.max(hum.MaxHealth,1),0,1)
		healthText.Text=string.format("VIDA  %d / %d",math.floor(hum.Health+0.5),math.floor(hum.MaxHealth+0.5))
		fill.Size=UDim2.new(ratio,0,1,0)
		fill.BackgroundColor3=ratio<=0.25 and palette.danger or (ratio<=0.55 and palette.accent or palette.good)
	end
	hum.HealthChanged:Connect(update); hum:GetPropertyChangedSignal("MaxHealth"):Connect(update); update()
end

function HUD.Init()
	local guiParent=player:WaitForChild("PlayerGui")
	local old=guiParent:FindFirstChild("DZ_HUD"); if old then old:Destroy() end
	local remotes=ReplicatedStorage:WaitForChild("DZ_Remotes")
	inventoryRemote=remotes:WaitForChild("InventoryRequest")
	local inventoryUpdate=remotes:WaitForChild("InventoryUpdate")
	local gui=make("ScreenGui",{Name="DZ_HUD",ResetOnSpawn=false,DisplayOrder=30,IgnoreGuiInset=false},guiParent)

	local status=make("Frame",{Name="Status",AnchorPoint=Vector2.new(0,1),Position=UDim2.new(0,16,1,-16),
		Size=UDim2.fromOffset(260,88),BackgroundColor3=palette.panel,BackgroundTransparency=0.04,BorderSizePixel=0},gui)
	style(status,9)
	make("TextLabel",{BackgroundTransparency=1,Position=UDim2.fromOffset(13,8),Size=UDim2.new(1,-26,0,17),
		Text=string.upper(player.DisplayName),TextColor3=palette.text,Font=Enum.Font.GothamBold,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left},status)
	local healthText=make("TextLabel",{BackgroundTransparency=1,Position=UDim2.fromOffset(13,29),Size=UDim2.new(1,-26,0,16),
		Text="VIDA  100 / 100",TextColor3=palette.good,Font=Enum.Font.GothamMedium,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left},status)
	local back=make("Frame",{Position=UDim2.fromOffset(13,51),Size=UDim2.new(1,-26,0,8),BackgroundColor3=Color3.fromRGB(12,15,18),BorderSizePixel=0},status)
	style(back,4)
	local fill=make("Frame",{Size=UDim2.fromScale(1,1),BackgroundColor3=palette.good,BorderSizePixel=0},back); make("UICorner",{CornerRadius=UDim.new(0,4)},fill)
	make("TextLabel",{BackgroundTransparency=1,Position=UDim2.fromOffset(13,66),Size=UDim2.new(1,-26,0,13),
		Text="SETOR 01  •  OPERADOR",TextColor3=palette.muted,Font=Enum.Font.Gotham,TextSize=9,TextXAlignment=Enum.TextXAlignment.Left},status)

	local actions=make("Frame",{Name="Actions",AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-16,0,16),
		Size=UDim2.fromOffset(176,174),BackgroundTransparency=1},gui)
	buttons.inventory=button(actions,"InventoryButton","INVENTÁRIO [E]",UDim2.fromOffset(0,0),UDim2.fromOffset(176,34))
	buttons.flashlight=button(actions,"FlashlightButton","LANTERNA [F]",UDim2.fromOffset(0,40),UDim2.fromOffset(176,34))
	buttons.help=button(actions,"HelpButton","AJUDA [?] [H]",UDim2.fromOffset(0,80),UDim2.fromOffset(176,34))
	buttons.camera=button(actions,"CameraButton","3ª PESSOA [V]",UDim2.fromOffset(0,120),UDim2.fromOffset(176,34))

	inventoryPanel=make("Frame",{Name="InventoryPanel",AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),
		Size=UDim2.new(0.88,0,0,390),BackgroundColor3=palette.panel,BorderSizePixel=0,Visible=false},gui)
	style(inventoryPanel,10)
	make("TextLabel",{BackgroundTransparency=1,Position=UDim2.fromOffset(18,12),Size=UDim2.new(1,-70,0,27),
		Text="INVENTÁRIO  /  20 ESPAÇOS",TextColor3=palette.text,Font=Enum.Font.GothamBold,TextSize=17,TextXAlignment=Enum.TextXAlignment.Left},inventoryPanel)
	local closeInv=button(inventoryPanel,"Close","X",UDim2.new(1,-48,0,10),UDim2.fromOffset(34,30))
	local grid=make("Frame",{BackgroundTransparency=1,Position=UDim2.fromOffset(16,54),Size=UDim2.new(1,-32,0,224)},inventoryPanel)
	make("UIGridLayout",{CellSize=UDim2.new(0.19,0,0,48),CellPadding=UDim2.new(0.012,0,0,7),SortOrder=Enum.SortOrder.LayoutOrder},grid)
	for i=1,20 do
		local b=button(grid,"Slot"..i,string.format("%02d\nVAZIO",i),UDim2.new(),UDim2.fromOffset(60,48))
		b.LayoutOrder=i; b.TextSize=10; slots[i]=b
		b.Activated:Connect(function()
			selectedIndex=i
			local item=items[i]
			if item then
				detailLabel.Text=item.name.."  |  "..(item.category or "Item").."\n"..(item.description or "")
				useButton.Visible=item.id=="MEDKIT"
				inventoryRemote:FireServer("Equip",i)
			else
				detailLabel.Text="Espaço vazio."; useButton.Visible=false
			end
		end)
	end
	detailLabel=make("TextLabel",{BackgroundTransparency=1,Position=UDim2.new(0,18,0,292),Size=UDim2.new(1,-36,0,48),
		Text="Selecione um item para ver seus detalhes.",TextColor3=palette.muted,Font=Enum.Font.Gotham,TextSize=11,
		TextWrapped=true,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Top},inventoryPanel)
	useButton=button(inventoryPanel,"UseItem","USAR KIT MÉDICO",UDim2.new(1,-172,1,-42),UDim2.fromOffset(154,30))
	useButton.Visible=false
	useButton.Activated:Connect(function() if selectedIndex then inventoryRemote:FireServer("Use",selectedIndex) end end)
	closeInv.Activated:Connect(closePanels)

	helpPanel=make("Frame",{Name="HelpPanel",AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),
		Size=UDim2.new(0.88,0,0,340),BackgroundColor3=palette.panel,BorderSizePixel=0,Visible=false},gui)
	style(helpPanel,10)
	make("TextLabel",{BackgroundTransparency=1,Position=UDim2.fromOffset(18,15),Size=UDim2.new(1,-70,0,28),
		Text="DIMENSÃO ZERO  /  CENTRAL DE CONTROLES",TextColor3=palette.text,Font=Enum.Font.GothamBold,TextSize=15,TextXAlignment=Enum.TextXAlignment.Left},helpPanel)
	local helpClose=button(helpPanel,"Close","X",UDim2.new(1,-48,0,10),UDim2.fromOffset(34,30))
	make("TextLabel",{BackgroundTransparency=1,Position=UDim2.fromOffset(22,60),Size=UDim2.new(1,-44,1,-78),
		Text="W A S D   —   Movimentar\nESPAÇO   —   Pular\nMOUSE   —   Câmera\nV   —   Alternar perspectiva\nE   —   Inventário\nF   —   Lanterna\nH   —   Reabrir esta ajuda\nR   —   Recarregar DZ-01\nESC   —   Fechar painéis\n\nNo celular, use os botões na tela e os controles padrão do Roblox.",
		TextColor3=palette.muted,Font=Enum.Font.Gotham,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Top},helpPanel)
	helpClose.Activated:Connect(closePanels)

	buttons.inventory.Activated:Connect(function() toggle("Inventory") end)
	buttons.flashlight.Activated:Connect(function() FlashlightController.Toggle(); updateFlashlight() end)
	buttons.help.Activated:Connect(function() toggle("Help") end)
	buttons.camera.Activated:Connect(function() CameraController.Toggle(); updateCamera() end)
	UserInputService.InputBegan:Connect(function(input,processed)
		if input.KeyCode==Enum.KeyCode.Escape then closePanels(); return end
		if processed then return end
		if input.KeyCode==Enum.KeyCode.E then toggle("Inventory")
		elseif input.KeyCode==Enum.KeyCode.F then FlashlightController.Toggle(); updateFlashlight()
		elseif input.KeyCode==Enum.KeyCode.H then toggle("Help")
		elseif input.KeyCode==Enum.KeyCode.V then task.defer(updateCamera) end
	end)
	inventoryUpdate.OnClientEvent:Connect(renderInventory)
	player.CharacterAdded:Connect(function(char) bindHealth(char,healthText,fill) end)
	if player.Character then task.spawn(bindHealth,player.Character,healthText,fill) end
	updateCamera(); updateFlashlight()
	inventoryRemote:FireServer("Request")
	task.delay(0.8,function() if helpPanel and helpPanel.Parent then openPanel("Help") end end)
end
return HUD
