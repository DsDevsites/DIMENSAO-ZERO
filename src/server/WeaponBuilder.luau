-- DZ-01: modelo procedural de prototipo, inspirado na referencia visual oficial.
-- Todas as pecas sao soldadas ao Handle; sem meshes externos ou IDs de asset.
local StarterPack = game:GetService("StarterPack")
local WeaponBuilder = {}

local C = {
	Graphite = Color3.fromRGB(29, 32, 36),
	Dark = Color3.fromRGB(12, 15, 19),
	Steel = Color3.fromRGB(91, 96, 101),
	Edge = Color3.fromRGB(125, 129, 132),
	Rubber = Color3.fromRGB(19, 21, 23),
	Cyan = Color3.fromRGB(0, 205, 229),
	Yellow = Color3.fromRGB(226, 164, 31),
	White = Color3.fromRGB(218, 224, 228),
}

local function part(tool, name, size, pos, color, material, rotation, shape)
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.CFrame = CFrame.new(pos) * CFrame.Angles(math.rad(rotation and rotation.X or 0), math.rad(rotation and rotation.Y or 0), math.rad(rotation and rotation.Z or 0))
	p.Color = color
	p.Material = material or Enum.Material.Metal
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Anchored = false
	p.CanCollide = false
	p.CanTouch = false
	p.CanQuery = false
	p.Massless = true
	p.CastShadow = true
	if shape then p.Shape = shape end
	p.Parent = tool
	local weld = Instance.new("WeldConstraint")
	weld.Part0 = tool.Handle
	weld.Part1 = p
	weld.Parent = p
	return p
end

local function mark(p, face, text, color, fontSize)
	local gui = Instance.new("SurfaceGui")
	gui.Name = "DZ_Stencil"
	gui.Face = face
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 100
	gui.Parent = p
	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Size = UDim2.fromScale(1, 1)
	label.Text = text
	label.TextColor3 = color
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.Parent = gui
end

local function build()
	local old = StarterPack:FindFirstChild("DZ-01")
	if old then old:Destroy() end

	local tool = Instance.new("Tool")
	tool.Name = "DZ-01"
	tool.ToolTip = "Rifle experimental DZ-01"
	tool.RequiresHandle = true
	tool.CanBeDropped = false
	-- Ajuste inicial de pegada; refinaremos apos ver no avatar.
	tool.Grip = CFrame.new(0, -0.16, -0.95) * CFrame.Angles(0, math.rad(90), 0)

	local handle = Instance.new("Part")
	handle.Name = "Handle"
	handle.Size = Vector3.new(0.3, 0.3, 1.0)
	handle.Transparency = 1
	handle.CanCollide = false
	handle.Massless = true
	handle.Parent = tool

	-- Receiver central e cobertura superior escalonada.
	part(tool, "Receiver_Main", Vector3.new(0.48, 0.48, 1.48), Vector3.new(0, 0, 0.02), C.Graphite)
	part(tool, "Receiver_Upper", Vector3.new(0.44, 0.15, 1.58), Vector3.new(0, 0.29, -0.02), C.Steel)
	part(tool, "Receiver_Lower", Vector3.new(0.42, 0.12, 1.22), Vector3.new(0, -0.29, 0.02), C.Dark)
	part(tool, "Receiver_Cheek_Ridge", Vector3.new(0.50, 0.055, 1.05), Vector3.new(0, 0.37, 0.02), C.Dark)

	-- Coronha vazada, com duas longarinas e reforco triangular.
	part(tool, "Stock_Upper_Rail", Vector3.new(0.16, 0.15, 0.78), Vector3.new(0, 0.23, 1.03), C.Graphite)
	part(tool, "Stock_Lower_Rail", Vector3.new(0.15, 0.14, 0.78), Vector3.new(0, -0.20, 1.03), C.Dark)
	part(tool, "Stock_Spine_L", Vector3.new(0.09, 0.42, 0.72), Vector3.new(-0.19, 0.02, 1.02), C.Steel, Enum.Material.Metal, Vector3.new(0, 0, -12))
	part(tool, "Stock_Spine_R", Vector3.new(0.09, 0.42, 0.72), Vector3.new(0.19, 0.02, 1.02), C.Steel, Enum.Material.Metal, Vector3.new(0, 0, -12))
	part(tool, "Stock_Brace_L", Vector3.new(0.075, 0.08, 0.66), Vector3.new(-0.19, -0.16, 1.02), C.Edge, Enum.Material.Metal, Vector3.new(0, 0, 32))
	part(tool, "Stock_Brace_R", Vector3.new(0.075, 0.08, 0.66), Vector3.new(0.19, -0.16, 1.02), C.Edge, Enum.Material.Metal, Vector3.new(0, 0, 32))
	part(tool, "Stock_Butt", Vector3.new(0.49, 0.60, 0.13), Vector3.new(0, 0.02, 1.43), C.Graphite, Enum.Material.DiamondPlate)
	part(tool, "Stock_Rubber_Pad", Vector3.new(0.50, 0.54, 0.055), Vector3.new(0, 0.02, 1.52), C.Rubber, Enum.Material.Rubber)
	part(tool, "Stock_Cheek_Rest", Vector3.new(0.40, 0.12, 0.48), Vector3.new(0, 0.34, 1.03), C.Dark, Enum.Material.Rubber)
	part(tool, "Stock_Cyan_Indicator", Vector3.new(0.025, 0.07, 0.38), Vector3.new(-0.25, 0.17, 1.03), C.Cyan, Enum.Material.Neon)
	part(tool, "Stock_Logo_Plate", Vector3.new(0.025, 0.22, 0.28), Vector3.new(-0.252, 0.00, 1.05), C.Steel)

	-- Handguard comprido com painéis laterais, trilho e rasgos escuros.
	part(tool, "Handguard_Core", Vector3.new(0.50, 0.46, 1.32), Vector3.new(0, 0.01, -1.23), C.Graphite, Enum.Material.DiamondPlate)
	part(tool, "Handguard_Upper_Armor", Vector3.new(0.54, 0.09, 1.22), Vector3.new(0, 0.27, -1.22), C.Steel)
	for _, side in ipairs({-1, 1}) do
		part(tool, "Handguard_Side_Armor", Vector3.new(0.045, 0.30, 1.08), Vector3.new(side * 0.27, 0.02, -1.25), C.Steel)
		for i = 1, 5 do
			part(tool, "Vent_Recess", Vector3.new(0.012, 0.075, 0.16), Vector3.new(side * 0.296, 0.035, -1.66 + i * 0.19), C.Dark)
		end
		part(tool, "Handguard_Cyan_Light", Vector3.new(0.018, 0.055, 0.34), Vector3.new(side * 0.30, 0.12, -1.18), C.Cyan, Enum.Material.Neon)
		part(tool, "Handguard_Lower_Rail", Vector3.new(0.12, 0.09, 0.95), Vector3.new(side * 0.19, -0.27, -1.25), C.Dark)
	end

	-- Cano, anel e freio de boca.
	part(tool, "Barrel", Vector3.new(0.16, 0.16, 0.92), Vector3.new(0, 0.02, -2.30), C.Steel, Enum.Material.Metal, nil, Enum.PartType.Cylinder)
	part(tool, "Barrel_Collar", Vector3.new(0.23, 0.23, 0.12), Vector3.new(0, 0.02, -2.72), C.Dark, Enum.Material.Metal, nil, Enum.PartType.Cylinder)
	part(tool, "Muzzle_Brake", Vector3.new(0.27, 0.27, 0.28), Vector3.new(0, 0.02, -2.88), C.Graphite, Enum.Material.Metal, nil, Enum.PartType.Cylinder)
	part(tool, "Muzzle_Ring", Vector3.new(0.29, 0.29, 0.055), Vector3.new(0, 0.02, -2.73), C.Edge, Enum.Material.Metal, nil, Enum.PartType.Cylinder)

	-- Trilho Picatinny longo e mira elevada.
	part(tool, "Top_Rail", Vector3.new(0.17, 0.075, 2.02), Vector3.new(0, 0.40, -0.65), C.Dark)
	for i = 1, 12 do
		part(tool, "Rail_Tooth", Vector3.new(0.23, 0.035, 0.075), Vector3.new(0, 0.455, -1.60 + i * 0.16), C.Edge)
	end
	part(tool, "Optic_Mount", Vector3.new(0.38, 0.10, 0.42), Vector3.new(0, 0.52, -0.20), C.Dark)
	part(tool, "Optic_Left_Wall", Vector3.new(0.075, 0.43, 0.25), Vector3.new(-0.16, 0.77, -0.20), C.Graphite)
	part(tool, "Optic_Right_Wall", Vector3.new(0.075, 0.43, 0.25), Vector3.new(0.16, 0.77, -0.20), C.Graphite)
	part(tool, "Optic_Top", Vector3.new(0.38, 0.075, 0.25), Vector3.new(0, 0.99, -0.20), C.Steel)
	part(tool, "Optic_Lens", Vector3.new(0.018, 0.28, 0.18), Vector3.new(-0.205, 0.77, -0.20), C.Cyan, Enum.Material.Glass)

	-- Empunhadura inclinada e carregador com leve curvatura visual.
	part(tool, "Pistol_Grip", Vector3.new(0.34, 0.62, 0.38), Vector3.new(0, -0.56, 0.27), C.Rubber, Enum.Material.Rubber, Vector3.new(0, 0, 9))
	part(tool, "Grip_Side_L", Vector3.new(0.035, 0.47, 0.29), Vector3.new(-0.18, -0.56, 0.27), C.Graphite, Enum.Material.DiamondPlate)
	part(tool, "Grip_Side_R", Vector3.new(0.035, 0.47, 0.29), Vector3.new(0.18, -0.56, 0.27), C.Graphite, Enum.Material.DiamondPlate)
	part(tool, "Magazine", Vector3.new(0.37, 0.88, 0.49), Vector3.new(0, -0.78, -0.22), C.Dark, Enum.Material.Metal, Vector3.new(13, 0, 0))
	for i = 1, 4 do
		part(tool, "Magazine_Rib", Vector3.new(0.39, 0.045, 0.51), Vector3.new(0, -0.43 - i * 0.17, -0.22 - i * 0.035), C.Steel, Enum.Material.Metal, Vector3.new(13, 0, 0))
	end
	part(tool, "Magazine_Hazard", Vector3.new(0.018, 0.12, 0.27), Vector3.new(0.197, -0.91, -0.28), C.Yellow, Enum.Material.Neon, Vector3.new(13, 0, 0))

	-- Detalhes do receiver, pinos, parafusos e identificacao nos dois lados.
	for _, side in ipairs({-1, 1}) do
		local plate = part(tool, side == 1 and "Receiver_Plate_Right" or "Receiver_Plate_Left", Vector3.new(0.035, 0.27, 0.92), Vector3.new(side * 0.255, 0.015, 0.00), C.Graphite)
		for i = 1, 4 do
			part(tool, "Receiver_Fastener", Vector3.new(0.045, 0.045, 0.045), Vector3.new(side * 0.28, 0.11, -0.34 + i * 0.19), C.Edge, Enum.Material.Metal, nil, Enum.PartType.Ball)
		end
		part(tool, "Selector_Dial", Vector3.new(0.045, 0.13, 0.13), Vector3.new(side * 0.28, -0.12, 0.36), C.Steel, Enum.Material.Metal, nil, Enum.PartType.Cylinder)
		if side == 1 then
			mark(plate, Enum.NormalId.Right, "DZ-01", C.White)
		else
			mark(plate, Enum.NormalId.Left, "DIMENSAO ZERO", C.White)
		end
	end
	part(tool, "Safety_Hazard_Plate", Vector3.new(0.025, 0.16, 0.30), Vector3.new(0.282, -0.20, -0.02), C.Yellow, Enum.Material.Metal)
	part(tool, "Sector_Label", Vector3.new(0.02, 0.08, 0.22), Vector3.new(0.30, -0.29, -0.02), C.White)

	local barrel = tool:FindFirstChild("Barrel")
	local flash = Instance.new("ParticleEmitter")
	flash.Name = "DZ_MuzzleFlash"
	flash.Enabled = false
	flash.Rate = 0
	flash.Lifetime = NumberRange.new(0.035, 0.06)
	flash.Speed = NumberRange.new(0, 0)
	flash.LightEmission = 1
	flash.Color = ColorSequence.new(Color3.fromRGB(120, 235, 255), Color3.fromRGB(255, 210, 120))
	flash.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.34), NumberSequenceKeypoint.new(1, 0)})
	flash.Parent = barrel

	tool.Parent = StarterPack
end

function WeaponBuilder.Init()
	build()
	print("[DZ] DZ-01 atualizada com silhueta industrial da referencia.")
end

return WeaponBuilder
