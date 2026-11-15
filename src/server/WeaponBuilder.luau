-- Cria a DZ-01 proceduralmente para o prototipo. Todas as pecas sao soldadas ao Handle.
-- A arma e entregue pelo StarterPack e continua usando os remotes de combate existentes.
local StarterPack = game:GetService("StarterPack")
local WeaponBuilder = {}

local function makePart(parent, name, size, offset, color, material, shape)
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.CFrame = CFrame.new(offset)
	part.Color = color
	part.Material = material or Enum.Material.Metal
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Anchored = false
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.Massless = true
	part.CastShadow = true
	if shape then part.Shape = shape end
	part.Parent = parent
	local weld = Instance.new("WeldConstraint")
	weld.Part0 = parent:FindFirstChild("Handle")
	weld.Part1 = part
	weld.Parent = part
	return part
end

local GRAPHITE = Color3.fromRGB(27, 31, 36)
local DARK = Color3.fromRGB(13, 16, 20)
local STEEL = Color3.fromRGB(82, 89, 96)
local CYAN = Color3.fromRGB(0, 210, 235)
local YELLOW = Color3.fromRGB(235, 174, 35)

local function addSideMark(part, face, text, color, width, height)
	local gui = Instance.new("SurfaceGui")
	gui.Name = "DZ_Markings"
	gui.Face = face
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 70
	gui.Parent = part
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = color
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.Parent = gui
end

local function createWeapon()
	local old = StarterPack:FindFirstChild("DZ-01")
	if old then old:Destroy() end

	local tool = Instance.new("Tool")
	tool.Name = "DZ-01"
	tool.ToolTip = "Rifle experimental DZ-01"
	tool.RequiresHandle = true
	tool.CanBeDropped = false
	tool.Grip = CFrame.new(0, -0.18, -0.72) * CFrame.Angles(0, math.rad(90), 0)

	local handle = Instance.new("Part")
	handle.Name = "Handle"
	handle.Size = Vector3.new(0.34, 0.34, 1.15)
	handle.Color = GRAPHITE
	handle.Material = Enum.Material.Metal
	handle.Transparency = 1
	handle.CanCollide = false
	handle.Massless = true
	handle.Parent = tool

	-- Eixo longitudinal: coronha em +Z e cano em -Z.
	makePart(tool, "Receiver_Core", Vector3.new(0.48, 0.48, 1.35), Vector3.new(0, 0, 0), GRAPHITE, Enum.Material.Metal)
	makePart(tool, "Upper_Receiver", Vector3.new(0.42, 0.16, 1.48), Vector3.new(0, 0.29, -0.02), STEEL, Enum.Material.Metal)
	makePart(tool, "Lower_Receiver", Vector3.new(0.40, 0.13, 1.12), Vector3.new(0, -0.29, 0.05), DARK, Enum.Material.Metal)

	-- Coronha reforcada.
	makePart(tool, "Stock_Neck", Vector3.new(0.30, 0.30, 0.55), Vector3.new(0, 0.02, 0.92), DARK, Enum.Material.Metal)
	makePart(tool, "Stock_Butt", Vector3.new(0.48, 0.62, 0.16), Vector3.new(0, 0.02, 1.27), GRAPHITE, Enum.Material.DiamondPlate)
	makePart(tool, "Stock_Pad", Vector3.new(0.50, 0.54, 0.07), Vector3.new(0, 0.02, 1.39), DARK, Enum.Material.Rubber)
	makePart(tool, "Stock_Rib_L", Vector3.new(0.06, 0.40, 0.55), Vector3.new(-0.20, 0.02, 1.00), STEEL, Enum.Material.Metal)
	makePart(tool, "Stock_Rib_R", Vector3.new(0.06, 0.40, 0.55), Vector3.new(0.20, 0.02, 1.00), STEEL, Enum.Material.Metal)

	-- Guarda-mao e cano.
	makePart(tool, "Handguard", Vector3.new(0.52, 0.48, 1.02), Vector3.new(0, 0.00, -1.13), GRAPHITE, Enum.Material.DiamondPlate)
	makePart(tool, "Barrel", Vector3.new(0.17, 0.17, 0.88), Vector3.new(0, 0.02, -2.02), STEEL, Enum.Material.Metal, Enum.PartType.Cylinder)
	makePart(tool, "Muzzle", Vector3.new(0.27, 0.27, 0.24), Vector3.new(0, 0.02, -2.52), DARK, Enum.Material.Metal, Enum.PartType.Cylinder)
	makePart(tool, "Muzzle_Ring", Vector3.new(0.30, 0.30, 0.06), Vector3.new(0, 0.02, -2.39), STEEL, Enum.Material.Metal, Enum.PartType.Cylinder)

	-- Trilho superior e mira holografica.
	makePart(tool, "Top_Rail", Vector3.new(0.16, 0.09, 1.72), Vector3.new(0, 0.40, -0.45), DARK, Enum.Material.Metal)
	for i = 1, 9 do
		makePart(tool, "Rail_Tooth_" .. i, Vector3.new(0.22, 0.035, 0.075), Vector3.new(0, 0.46, -1.18 + (i - 1) * 0.18), STEEL, Enum.Material.Metal)
	end
	makePart(tool, "Optic_Base", Vector3.new(0.34, 0.10, 0.40), Vector3.new(0, 0.52, -0.12), DARK, Enum.Material.Metal)
	makePart(tool, "Optic_Frame", Vector3.new(0.34, 0.36, 0.22), Vector3.new(0, 0.73, -0.12), GRAPHITE, Enum.Material.Metal)
	local lens = makePart(tool, "Optic_Lens", Vector3.new(0.025, 0.23, 0.16), Vector3.new(0, 0.73, -0.245), CYAN, Enum.Material.Glass)
	lens.Transparency = 0.38

	-- Empunhadura e carregador.
	makePart(tool, "Pistol_Grip", Vector3.new(0.32, 0.62, 0.36), Vector3.new(0, -0.53, 0.27), DARK, Enum.Material.Rubber)
	makePart(tool, "Grip_Panel_L", Vector3.new(0.035, 0.48, 0.28), Vector3.new(-0.17, -0.54, 0.27), GRAPHITE, Enum.Material.DiamondPlate)
	makePart(tool, "Grip_Panel_R", Vector3.new(0.035, 0.48, 0.28), Vector3.new(0.17, -0.54, 0.27), GRAPHITE, Enum.Material.DiamondPlate)
	makePart(tool, "Magazine", Vector3.new(0.34, 0.78, 0.48), Vector3.new(0, -0.70, -0.22), DARK, Enum.Material.Metal)
	for i = 1, 3 do
		makePart(tool, "Magazine_Ridge_" .. i, Vector3.new(0.36, 0.045, 0.50), Vector3.new(0, -0.48 - i * 0.17, -0.22), STEEL, Enum.Material.Metal)
	end

	-- Detalhes industriais laterais.
	for _, side in ipairs({-1, 1}) do
		makePart(tool, "Receiver_Side_Plate", Vector3.new(0.035, 0.28, 0.86), Vector3.new(side * 0.255, 0.02, -0.02), STEEL, Enum.Material.Metal)
		makePart(tool, "Cyan_Status_Light", Vector3.new(0.025, 0.07, 0.42), Vector3.new(side * 0.282, 0.18, -1.12), CYAN, Enum.Material.Neon)
		makePart(tool, "Hazard_Mark", Vector3.new(0.025, 0.10, 0.28), Vector3.new(side * 0.282, -0.18, -0.08), YELLOW, Enum.Material.Neon)
		for i = 1, 3 do
			makePart(tool, "Handguard_Vent", Vector3.new(0.025, 0.045, 0.18), Vector3.new(side * 0.268, 0.02, -1.42 + i * 0.22), DARK, Enum.Material.Metal)
		end
	end

	local receiverMark = tool:FindFirstChild("Receiver_Side_Plate")
	if receiverMark then
		addSideMark(receiverMark, Enum.NormalId.Right, "DZ-01", Color3.fromRGB(225, 232, 238))
	end
	local leftMark = tool:FindFirstChild("Receiver_Side_Plate")
	if leftMark then
		addSideMark(leftMark, Enum.NormalId.Left, "DIMENSAO ZERO", Color3.fromRGB(205, 215, 222))
	end

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
	createWeapon()
	print("[DZ] DZ-01 modelada e adicionada ao StarterPack.")
end

return WeaponBuilder
