-- Detalhamento visual modular do SETOR 01.
-- Este modulo adiciona acabamento ao mundo criado por WorldBuilder sem alterar gameplay.
local Workspace = game:GetService("Workspace")

local EnvironmentBuilder = {}
local ROOT_NAME = "DIMENSAO_ZERO_WORLD"
local DETAIL_NAME = "DZ_EnvironmentDetails"

local COLORS = {
	dark = Color3.fromRGB(22, 28, 33),
	panel = Color3.fromRGB(48, 57, 64),
	steel = Color3.fromRGB(105, 116, 123),
	edge = Color3.fromRGB(145, 154, 158),
	cyan = Color3.fromRGB(74, 157, 184),
	amber = Color3.fromRGB(190, 139, 54),
	red = Color3.fromRGB(154, 55, 50),
	white = Color3.fromRGB(190, 204, 210),
}

local function makePart(parent, name, size, cf, color, material, canCollide, shape)
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.CFrame = cf
	p.Anchored = true
	p.Color = color
	p.Material = material or Enum.Material.Metal
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.CanCollide = canCollide == true
	p.CanTouch = false
	p.CanQuery = canCollide == true
	p.CastShadow = true
	if shape then p.Shape = shape end
	p.Parent = parent
	return p
end

local function box(parent, name, size, position, color, material, collide)
	return makePart(parent, name, size, CFrame.new(position), color, material, collide, nil)
end

local function pipe(parent, name, a, b, radius, color)
	local delta = b - a
	local length = delta.Magnitude
	local center = (a + b) / 2
	local cf = CFrame.lookAt(center, b) * CFrame.Angles(math.rad(90), 0, 0)
	return makePart(parent, name, Vector3.new(radius * 2, length, radius * 2), cf, color, Enum.Material.Metal, false, Enum.PartType.Cylinder)
end

local function addStrip(parent, position, size, color)
	local p = box(parent, "InsetFloorMarker", size, position, color, Enum.Material.Metal, false)
	p.CastShadow = false
	return p
end

local function wallPanel(parent, position, facing, width, height)
	local cf = CFrame.new(position) * CFrame.Angles(0, facing, 0)
	box(parent, "RecessedWallPanel", Vector3.new(width + 0.35, height + 0.35, 0.22), position, COLORS.dark, Enum.Material.Metal, false)
	local facePos = position + cf.LookVector * 0.14
	box(parent, "WallPanelFace", Vector3.new(width, height, 0.08), facePos, COLORS.panel, Enum.Material.CorrodedMetal, false)
	box(parent, "PanelStatusLight", Vector3.new(0.12, 0.12, 0.06), facePos + Vector3.new(-width * 0.32, height * 0.28, 0.08), COLORS.cyan, Enum.Material.Neon, false)
end

local function ceilingSupport(parent, z)
	box(parent, "CeilingCrossBeam", Vector3.new(27.5, 0.42, 0.55), Vector3.new(0, 15.65, z), COLORS.dark, Enum.Material.Metal, false)
	for _, x in ipairs({-12.8, 12.8}) do
		box(parent, "BeamBracket", Vector3.new(0.65, 0.9, 0.8), Vector3.new(x, 15.2, z), COLORS.steel, Enum.Material.DiamondPlate, false)
	end
end

local function addCeilingPipes(parent)
	for _, x in ipairs({-11.8, -10.9, 10.9, 11.8}) do
		pipe(parent, "MainCeilingPipe", Vector3.new(x, 14.35, -39), Vector3.new(x, 14.35, 39), 0.19, COLORS.steel)
		for _, z in ipairs({-30, -10, 10, 30}) do
			box(parent, "PipeClamp", Vector3.new(0.75, 0.16, 0.35), Vector3.new(x, 14.35, z), COLORS.dark, Enum.Material.Metal, false)
		end
	end
	pipe(parent, "CentralCableTray", Vector3.new(-8.5, 15.05, -39), Vector3.new(8.5, 15.05, -39), 0.12, COLORS.edge)
end

local function addRoomEquipment(parent)
	-- Equipamentos decorativos encostados nas paredes das alas, fora das rotas principais.
	local positions = {
		{Vector3.new(-49, 3.0, -22), "SecurityTerminal"},
		{Vector3.new(49, 3.0, -22), "MedicalStorage"},
		{Vector3.new(-49, 3.0, 22), "ArmoryCabinet"},
		{Vector3.new(49, 3.0, 22), "ControlRack"},
	}
	for _, item in ipairs(positions) do
		local pos, name = item[1], item[2]
		box(parent, name, Vector3.new(3.2, 5.8, 1.4), pos, COLORS.dark, Enum.Material.Metal, true)
		box(parent, name .. "_Door", Vector3.new(2.75, 4.9, 0.12), pos + Vector3.new(0, 0, -0.77), COLORS.panel, Enum.Material.DiamondPlate, false)
		box(parent, name .. "_Display", Vector3.new(1.15, 0.72, 0.08), pos + Vector3.new(0, 1.25, -0.86), COLORS.cyan, Enum.Material.SmoothPlastic, false)
		box(parent, name .. "_Handle", Vector3.new(0.12, 0.8, 0.12), pos + Vector3.new(1.05, -0.1, -0.88), COLORS.edge, Enum.Material.Metal, false)
	end
end

local function addSectorIdentity(parent)
	local function plaque(name, text, position, accent)
		local board = box(parent, name, Vector3.new(8.5, 1.35, 0.18), position, COLORS.dark, Enum.Material.Metal, false)
		local stripe = box(parent, name .. "_Accent", Vector3.new(0.12, 1.0, 0.06), position + Vector3.new(-3.95, 0, -0.12), accent, Enum.Material.Metal, false)
		local gui = Instance.new("SurfaceGui")
		gui.Name = "PlaqueSurface"
		gui.Face = Enum.NormalId.Front
		gui.CanvasSize = Vector2.new(850, 135)
		gui.LightInfluence = 0.35
		gui.Parent = board
		local label = Instance.new("TextLabel")
		label.Size = UDim2.fromScale(1, 1)
		label.BackgroundTransparency = 1
		label.Text = text
		label.TextColor3 = COLORS.white
		label.Font = Enum.Font.GothamBold
		label.TextScaled = true
		label.Parent = gui
		return stripe
	end
	plaque("Sector01Identification", "DIMENSAO ZERO  /  SETOR 01", Vector3.new(0, 12.0, 42.55), COLORS.cyan)
	plaque("RestrictedAreaPlaque", "ACESSO RESTRITO", Vector3.new(0, 10.2, 42.55), COLORS.amber)
end

local function addEmergencyDetails(parent)
	for _, z in ipairs({-34, 34}) do
		local housing = box(parent, "EmergencyLightHousing", Vector3.new(1.8, 0.55, 0.7), Vector3.new(0, 14.55, z), COLORS.dark, Enum.Material.Metal, false)
		local lens = box(parent, "EmergencyLightLens", Vector3.new(1.35, 0.16, 0.42), Vector3.new(0, 14.2, z), COLORS.red, Enum.Material.Neon, false)
		local light = Instance.new("PointLight")
		light.Color = COLORS.red
		light.Brightness = 0.45
		light.Range = 9
		light.Shadows = false
		light.Parent = lens
	end
end

local function build()
	local world = Workspace:FindFirstChild(ROOT_NAME)
	if not world then
		warn("[DIMENSÃO ZERO] WorldBuilder não encontrou o mapa; detalhes visuais ignorados.")
		return
	end

	local old = world:FindFirstChild(DETAIL_NAME)
	if old then old:Destroy() end
	local folder = Instance.new("Folder")
	folder.Name = DETAIL_NAME
	folder.Parent = world

	-- Acabamento do corredor central: faixas embutidas, vigas e tubulações.
	for _, z in ipairs({-36, -24, -12, 0, 12, 24, 36}) do
		ceilingSupport(folder, z)
	end
	addCeilingPipes(folder)

	for _, x in ipairs({-13.55, 13.55}) do
		addStrip(folder, Vector3.new(x, 0.045, 0), Vector3.new(0.12, 0.035, 68), COLORS.amber)
		for _, z in ipairs({-30, -10, 10, 30}) do
			box(folder, "FloorAccessPlate", Vector3.new(2.2, 0.045, 1.4), Vector3.new(x * 0.78, 0.055, z), COLORS.steel, Enum.Material.DiamondPlate, false)
		end
	end

	-- Painéis técnicos laterais e caixas de junção.
	wallPanel(folder, Vector3.new(-54.9, 7.0, -5), math.rad(90), 3.6, 4.8)
	wallPanel(folder, Vector3.new(54.9, 7.0, 5), math.rad(-90), 3.6, 4.8)
	for _, z in ipairs({-37, 37}) do
		box(folder, "ElectricalJunctionBox", Vector3.new(1.8, 2.8, 0.8), Vector3.new(-53.9, 3.0, z), COLORS.panel, Enum.Material.CorrodedMetal, true)
		box(folder, "JunctionIndicator", Vector3.new(0.18, 0.18, 0.08), Vector3.new(-52.95, 3.8, z), COLORS.amber, Enum.Material.Neon, false)
	end

	addRoomEquipment(folder)
	addSectorIdentity(folder)
	addEmergencyDetails(folder)

	print("[DIMENSÃO ZERO] Acabamento industrial do SETOR 01 aplicado.")
end

function EnvironmentBuilder.Init()
	build()
end

return EnvironmentBuilder
