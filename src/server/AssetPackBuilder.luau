-- Biblioteca inicial de assets 3D do SETOR 01.
-- Props modulares de baixa complexidade; todos ancorados e sem colisao por padrao.
local Workspace = game:GetService("Workspace")
local AssetPackBuilder = {}
local ROOT_NAME = "DZ_ASSET_PACK_01"

local C = {
	graphite = Color3.fromRGB(29, 33, 38),
	dark = Color3.fromRGB(13, 16, 20),
	steel = Color3.fromRGB(91, 98, 104),
	edge = Color3.fromRGB(126, 132, 137),
	rubber = Color3.fromRGB(22, 24, 26),
	cyan = Color3.fromRGB(0, 190, 218),
	yellow = Color3.fromRGB(215, 157, 35),
	white = Color3.fromRGB(205, 213, 218),
}

local function part(parent, name, size, cf, color, material, collide)
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.CFrame = cf
	p.Color = color
	p.Material = material or Enum.Material.Metal
	p.Anchored = true
	p.CanCollide = collide == true
	p.CanTouch = false
	p.CanQuery = collide == true
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = parent
	return p
end

local function model(root, name)
	local m = Instance.new("Model")
	m.Name = name
	m.Parent = root
	return m
end

local function makeChair(root, origin, yaw)
	local m = model(root, "DZ_Chair_Operational")
	local base = CFrame.new(origin) * CFrame.Angles(0, math.rad(yaw or 0), 0)
	local function p(n,s,o,c,mat,collide)
		return part(m,n,s,base*CFrame.new(o),c,mat,collide)
	end
	p("Seat_Cushion",Vector3.new(1.5,0.22,1.35),Vector3.new(0,1.65,0),C.rubber,Enum.Material.Rubber,true)
	p("Seat_Frame",Vector3.new(1.58,0.12,1.4),Vector3.new(0,1.51,0),C.steel,Enum.Material.Metal)
	p("Backrest_Frame",Vector3.new(1.48,1.65,0.18),Vector3.new(0,2.52,0.58),C.graphite,Enum.Material.Metal,true)
	p("Backrest_Pad",Vector3.new(1.28,1.42,0.12),Vector3.new(0,2.52,0.43),C.rubber,Enum.Material.Rubber)
	p("Center_Column",Vector3.new(0.22,1.15,0.22),Vector3.new(0,0.91,0),C.steel,Enum.Material.Metal)
	p("Base_Cross",Vector3.new(1.65,0.12,0.22),Vector3.new(0,0.28,0),C.dark,Enum.Material.Metal)
	p("Base_Cross_2",Vector3.new(0.22,0.12,1.65),Vector3.new(0,0.28,0),C.dark,Enum.Material.Metal)
	for _,x in ipairs({-0.67,0.67}) do
		p("Arm_Rest",Vector3.new(0.18,0.72,0.18),Vector3.new(x,2.02,0.08),C.steel,Enum.Material.Metal)
		p("Arm_Pad",Vector3.new(0.28,0.10,0.55),Vector3.new(x,2.38,0.05),C.rubber,Enum.Material.Rubber)
	end
	return m
end

local function makeDesk(root, origin, yaw)
	local m = model(root, "DZ_Desk_Control")
	local base = CFrame.new(origin) * CFrame.Angles(0, math.rad(yaw or 0), 0)
	local function p(n,s,o,c,mat,collide)
		return part(m,n,s,base*CFrame.new(o),c,mat,collide)
	end
	p("Worktop",Vector3.new(5.5,0.22,2.2),Vector3.new(0,2.7,0),C.graphite,Enum.Material.Metal,true)
	p("Front_Fascia",Vector3.new(5.3,0.62,0.16),Vector3.new(0,2.28,-1.0),C.steel,Enum.Material.DiamondPlate)
	for _,x in ipairs({-2.35,2.35}) do
		p("Desk_Leg",Vector3.new(0.22,2.55,0.22),Vector3.new(x,1.35,0.78),C.dark,Enum.Material.Metal,true)
	end
	p("Status_Line",Vector3.new(3.8,0.045,0.035),Vector3.new(0,2.55,-1.095),C.cyan,Enum.Material.Neon)
	return m
end

local function makeTerminal(root, origin, yaw)
	local m = model(root, "DZ_Terminal_Security")
	local base = CFrame.new(origin) * CFrame.Angles(0, math.rad(yaw or 0), 0)
	local function p(n,s,o,c,mat,collide)
		return part(m,n,s,base*CFrame.new(o),c,mat,collide)
	end
	p("Terminal_Pedestal",Vector3.new(1.5,2.8,1.2),Vector3.new(0,1.4,0),C.dark,Enum.Material.Metal,true)
	p("Console_Body",Vector3.new(2.8,1.25,1.25),Vector3.new(0,3.1,0),C.steel,Enum.Material.Metal,true)
	local screen=p("Display",Vector3.new(2.35,0.9,0.06),Vector3.new(0,3.28,-0.66),C.cyan,Enum.Material.Glass)
	screen.Transparency=0.18
	p("Display_Frame",Vector3.new(2.65,1.12,0.12),Vector3.new(0,3.28,-0.70),C.graphite,Enum.Material.Metal)
	p("Keyboard",Vector3.new(1.9,0.08,0.55),Vector3.new(0,2.58,-0.48),C.dark,Enum.Material.Metal)
	for i=1,5 do
		p("Key_Row",Vector3.new(1.65,0.025,0.035),Vector3.new(0,2.63,-0.68+i*0.08),C.edge,Enum.Material.Metal)
	end
	return m
end

local function makeCabinet(root, origin, yaw)
	local m = model(root, "DZ_Cabinet_Equipment")
	local base = CFrame.new(origin) * CFrame.Angles(0, math.rad(yaw or 0), 0)
	local function p(n,s,o,c,mat,collide)
		return part(m,n,s,base*CFrame.new(o),c,mat,collide)
	end
	p("Cabinet_Body",Vector3.new(2.6,5.8,1.25),Vector3.new(0,2.9,0),C.graphite,Enum.Material.Metal,true)
	p("Door_Left",Vector3.new(1.18,5.45,0.08),Vector3.new(-0.63,2.9,-0.67),C.steel,Enum.Material.DiamondPlate)
	p("Door_Right",Vector3.new(1.18,5.45,0.08),Vector3.new(0.63,2.9,-0.67),C.steel,Enum.Material.DiamondPlate)
	p("Center_Seam",Vector3.new(0.035,5.2,0.025),Vector3.new(0,2.9,-0.72),C.dark,Enum.Material.Metal)
	p("Access_Light",Vector3.new(0.12,0.12,0.035),Vector3.new(0.9,5.1,-0.73),C.cyan,Enum.Material.Neon)
	p("Hazard_Band",Vector3.new(2.35,0.16,0.035),Vector3.new(0,0.48,-0.73),C.yellow,Enum.Material.Metal)
	return m
end

local function makeGenerator(root, origin)
	local m = model(root, "DZ_Generator_Industrial")
	local cf = CFrame.new(origin)
	local function p(n,s,o,c,mat,collide)
		return part(m,n,s,cf*CFrame.new(o),c,mat,collide)
	end
	p("Generator_Base",Vector3.new(5.2,0.45,2.6),Vector3.new(0,0.25,0),C.dark,Enum.Material.Metal,true)
	p("Generator_Housing",Vector3.new(4.8,2.6,2.25),Vector3.new(0,1.75,0),C.graphite,Enum.Material.DiamondPlate,true)
	for i=1,7 do
		p("Cooling_Fin",Vector3.new(0.10,1.75,1.75),Vector3.new(-1.75+i*0.48,1.75,-1.18),C.steel,Enum.Material.Metal)
	end
	p("Control_Panel",Vector3.new(1.1,0.75,0.08),Vector3.new(1.25,2.0,-1.18),C.dark,Enum.Material.Metal)
	p("Power_Indicator",Vector3.new(0.55,0.08,0.035),Vector3.new(1.25,2.2,-1.23),C.cyan,Enum.Material.Neon)
	p("Warning_Stripe",Vector3.new(3.8,0.12,0.035),Vector3.new(0,0.65,-1.18),C.yellow,Enum.Material.Metal)
	return m
end

local function makeAccessPanel(root, origin, yaw)
	local m = model(root, "DZ_Access_Control_Panel")
	local base = CFrame.new(origin) * CFrame.Angles(0, math.rad(yaw or 0), 0)
	local function p(n,s,o,c,mat)
		return part(m,n,s,base*CFrame.new(o),c,mat)
	end
	p("Panel_Backplate",Vector3.new(2.2,3.1,0.22),Vector3.new(0,0,0),C.dark,Enum.Material.Metal)
	p("Panel_Face",Vector3.new(1.85,2.7,0.10),Vector3.new(0,0,-0.16),C.steel,Enum.Material.DiamondPlate)
	p("Screen",Vector3.new(1.3,0.72,0.035),Vector3.new(0,0.65,-0.23),C.cyan,Enum.Material.Glass)
	p("Keypad",Vector3.new(0.9,0.65,0.05),Vector3.new(0,-0.45,-0.23),C.dark,Enum.Material.Metal)
	p("Status",Vector3.new(0.14,0.14,0.04),Vector3.new(0.65,-1.0,-0.24),C.yellow,Enum.Material.Neon)
	return m
end

local function build()
	local world = Workspace:FindFirstChild("DIMENSAO_ZERO_WORLD")
	if not world then
		warn("[DZ Assets] World nao encontrado; pack nao foi criado.")
		return
	end
	local old = world:FindFirstChild(ROOT_NAME)
	if old then old:Destroy() end
	local root = Instance.new("Folder")
	root.Name = ROOT_NAME
	root.Parent = world

	-- Props colocados dentro das quatro alas, mantendo o corredor central livre.
	makeDesk(root, Vector3.new(-39,0,-31), 0)
	makeChair(root, Vector3.new(-39,0,-34), 0)
	makeCabinet(root, Vector3.new(-50,0,-37), 0)
	makeAccessPanel(root, Vector3.new(-55,6,-22), 90)

	makeGenerator(root, Vector3.new(30,0,-34))
	makeCabinet(root, Vector3.new(48,0,-36), 180)

	makeCabinet(root, Vector3.new(-49,0,17), 0)
	makeAccessPanel(root, Vector3.new(-55,6,28), 90)

	makeDesk(root, Vector3.new(34,0,30), 180)
	makeTerminal(root, Vector3.new(34,0,25), 180)
	makeChair(root, Vector3.new(34,0,34), 180)
	makeGenerator(root, Vector3.new(46,0,18))
end

function AssetPackBuilder.Init()
	build()
	print("[DZ Assets] Asset Pack 01 do SETOR 01 criado.")
end

return AssetPackBuilder
