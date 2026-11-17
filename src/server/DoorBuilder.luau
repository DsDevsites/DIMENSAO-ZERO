-- DZ-DOOR-001 | Porta automatica de acesso do SETOR 01
-- Modelo procedural modular, com duas folhas deslizantes e interacao por ProximityPrompt.
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local DoorBuilder = {}
local ROOT_NAME = "DIMENSAO_ZERO_WORLD"
local MODEL_NAME = "DZ_DOOR_001"

local C = {
	graphite = Color3.fromRGB(23, 27, 32),
	darkSteel = Color3.fromRGB(52, 58, 64),
	metal = Color3.fromRGB(119, 126, 132),
	cyan = Color3.fromRGB(0, 187, 214),
	yellow = Color3.fromRGB(213, 161, 44),
	light = Color3.fromRGB(174, 183, 189),
	black = Color3.fromRGB(12, 15, 18),
}

local function makePart(parent, name, size, position, color, material, canCollide)
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.Position = position
	p.Anchored = true
	p.Color = color
	p.Material = material or Enum.Material.Metal
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.CanCollide = canCollide ~= false
	p.Parent = parent
	return p
end

local function addLight(parent)
	local light = Instance.new("PointLight")
	light.Color = C.cyan
	light.Brightness = 0.7
	light.Range = 9
	light.Shadows = false
	light.Parent = parent
end

local function buildDoor(root)
	local old = root:FindFirstChild(MODEL_NAME)
	if old then old:Destroy() end

	local model = Instance.new("Model")
	model.Name = MODEL_NAME
	model.Parent = root

	-- A abertura existente no limite sul tem 18 studs de largura e 13 de altura.
	local center = Vector3.new(0, 0, 44)
	local frameZ = 44
	local floorY = 0
	local height = 13
	local leafWidth = 9
	local leafThickness = 0.85
	local closedOffset = 4.5
	local openOffset = 9.4

	-- Batentes e trilho superior.
	makePart(model, "Frame_Left", Vector3.new(0.75, height, 1.8), Vector3.new(-9.25, floorY + height/2, frameZ), C.darkSteel)
	makePart(model, "Frame_Right", Vector3.new(0.75, height, 1.8), Vector3.new(9.25, floorY + height/2, frameZ), C.darkSteel)
	makePart(model, "Header_Cover", Vector3.new(18.5, 1.15, 2.1), Vector3.new(0, 13.55, frameZ), C.graphite)
	makePart(model, "Upper_Rail", Vector3.new(17.2, 0.28, 1.25), Vector3.new(0, 12.82, frameZ), C.metal, Enum.Material.Metal, false)

	-- Revestimentos laterais fixos e sinalizacao de risco.
	for _, x in ipairs({-9.25, 9.25}) do
		makePart(model, "Side_Armor", Vector3.new(0.28, 10.8, 0.22), Vector3.new(x, 6.1, frameZ - 0.98), C.darkSteel, Enum.Material.Metal, false)
		local warning = makePart(model, "Safety_Marking", Vector3.new(0.12, 8.5, 0.08), Vector3.new(x + (x < 0 and 0.23 or -0.23), 5.8, frameZ - 1.12), C.yellow, Enum.Material.SmoothPlastic, false)
	end

	local leaves = {}
	for index, side in ipairs({-1, 1}) do
		local leaf = Instance.new("Model")
		leaf.Name = index == 1 and "Left_Sliding_Leaf" or "Right_Sliding_Leaf"
		leaf.Parent = model

		local x = side * closedOffset
		local body = makePart(leaf, "Armored_Panel", Vector3.new(leafWidth, height, leafThickness), Vector3.new(x, floorY + height/2, frameZ), C.graphite)
		body.Material = Enum.Material.Metal
		makePart(leaf, "Inset_Armor", Vector3.new(leafWidth - 1.1, height - 1.2, 0.12), Vector3.new(x, 6.5, frameZ - 0.49), C.darkSteel, Enum.Material.Metal, false)
		makePart(leaf, "Vertical_Rib", Vector3.new(0.22, 10.6, 0.1), Vector3.new(x + side * 3.35, 6.5, frameZ - 0.61), C.metal, Enum.Material.Metal, false)
		makePart(leaf, "Lower_Impact_Stripe", Vector3.new(leafWidth - 1.1, 0.24, 0.1), Vector3.new(x, 1.25, frameZ - 0.62), C.yellow, Enum.Material.SmoothPlastic, false)
		makePart(leaf, "Upper_Status_Line", Vector3.new(leafWidth - 1.4, 0.09, 0.08), Vector3.new(x, 11.55, frameZ - 0.62), C.cyan, Enum.Material.Neon, false)
		table.insert(leaves, {model = leaf, body = body, side = side, closedX = x, openX = side * openOffset})
	end

	-- Painel de acesso montado ao lado direito da porta, voltado para o corredor.
	local access = makePart(model, "Access_Panel", Vector3.new(1.15, 2.1, 0.28), Vector3.new(10.35, 4.2, 42.75), C.graphite, Enum.Material.Metal, false)
	makePart(model, "Access_Screen", Vector3.new(0.72, 0.85, 0.08), Vector3.new(10.35, 4.55, 42.57), C.cyan, Enum.Material.Neon, false)
	addLight(access)
	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "DoorAccessPrompt"
	prompt.ActionText = "Abrir porta"
	prompt.ObjectText = "ACESSO SETOR 01"
	prompt.KeyboardKeyCode = Enum.KeyCode.E
	prompt.HoldDuration = 0.35
	prompt.MaxActivationDistance = 10
	prompt.RequiresLineOfSight = false
	prompt.Parent = access

	local isOpen = false
	local busy = false
	prompt.Triggered:Connect(function(_player)
		if busy then return end
		busy = true
		isOpen = not isOpen
		prompt.Enabled = false
		prompt.ActionText = isOpen and "Fechar porta" or "Abrir porta"

		for _, item in ipairs(leaves) do
			item.body.CanCollide = false
			local target = Vector3.new(isOpen and item.openX or item.closedX, item.body.Position.Y, item.body.Position.Z)
			local tween = TweenService:Create(item.model.PrimaryPart or item.body, TweenInfo.new(1.15, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut), {Position = target})
			-- O corpo e os detalhes sao movidos juntos por PivotTo em pequenos passos.
			local startPivot = item.model:GetPivot()
			local startX = startPivot.Position.X
			local deltaX = (isOpen and item.openX or item.closedX) - startX
			local driver = Instance.new("NumberValue")
			driver.Value = 0
			local connection
			connection = driver.Changed:Connect(function(alpha)
				item.model:PivotTo(startPivot + Vector3.new(deltaX * alpha, 0, 0))
			end)
			local move = TweenService:Create(driver, TweenInfo.new(1.15, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut), {Value = 1})
			move:Play()
			move.Completed:Connect(function()
				if connection then connection:Disconnect() end
				driver:Destroy()
				item.body.CanCollide = not isOpen
			end)
		end

		task.delay(1.25, function()
			prompt.Enabled = true
			busy = false
		end)
	end)

	model:SetAttribute("AssetId", MODEL_NAME)
	model:SetAttribute("AssetLevel", "Hero")
	model:SetAttribute("Status", "Prototype")
end

function DoorBuilder.Init()
	local root = Workspace:WaitForChild(ROOT_NAME, 15)
	if not root then
		warn("[DIMENSÃO ZERO] Nao foi possivel criar DZ-DOOR-001: mundo nao encontrado.")
		return
	end
	buildDoor(root)
	print("[DIMENSÃO ZERO] DZ-DOOR-001 criada. Teste abertura, fechamento e colisao no Studio.")
end

return DoorBuilder
