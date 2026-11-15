-- SETOR 01: construcao procedural modular, fechada e com salas conectadas.
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local WorldBuilder = {}
local ROOT = "DIMENSAO_ZERO_WORLD"

local C = {
	floor=Color3.fromRGB(58,64,70), floorAlt=Color3.fromRGB(43,49,55),
	wall=Color3.fromRGB(103,111,118), dark=Color3.fromRGB(27,32,37),
	trim=Color3.fromRGB(132,140,145), white=Color3.fromRGB(205,211,214),
	blue=Color3.fromRGB(82,125,151), green=Color3.fromRGB(75,135,101),
	yellow=Color3.fromRGB(190,145,58), red=Color3.fromRGB(150,57,52),
}

local function part(parent,name,size,pos,color,material,collide)
	local p=Instance.new("Part")
	p.Name=name; p.Size=size; p.Position=pos; p.Anchored=true
	p.TopSurface=Enum.SurfaceType.Smooth; p.BottomSurface=Enum.SurfaceType.Smooth
	p.Color=color; p.Material=material or Enum.Material.Metal
	p.CanCollide=collide ~= false; p.Parent=parent
	return p
end

local function pointLight(parent,color,brightness,range)
	local l=Instance.new("PointLight"); l.Color=color; l.Brightness=brightness; l.Range=range; l.Shadows=true; l.Parent=parent
end

local function sign(parent,text,pos,width,color)
	local board=part(parent,"SectorSign",Vector3.new(width,3.2,0.35),pos,C.dark,Enum.Material.Metal)
	local gui=Instance.new("SurfaceGui"); gui.Face=Enum.NormalId.Front; gui.CanvasSize=Vector2.new(600,180); gui.Parent=board
	local label=Instance.new("TextLabel"); label.Size=UDim2.fromScale(1,1); label.BackgroundTransparency=1
	label.Text=text; label.TextColor3=color or C.white; label.Font=Enum.Font.GothamBold; label.TextScaled=true; label.Parent=gui
	return board
end

local function lamp(parent,pos,color)
	local fixture=part(parent,"IndustrialLuminaire",Vector3.new(5.5,0.25,1.1),pos,C.white,Enum.Material.Metal,false)
	local face=part(parent,"LuminaireLens",Vector3.new(4.8,0.08,0.72),pos+Vector3.new(0,-0.17,0),color,Enum.Material.SmoothPlastic,false)
	pointLight(face,color,1.35,25)
end

local function room(parent,name,cx,cz,w,d,doorSide)
	local folder=Instance.new("Folder"); folder.Name=name; folder.Parent=parent
	local yFloor=-0.5
	part(folder,name.."_Floor",Vector3.new(w,1,d),Vector3.new(cx,yFloor,cz),C.floor,Enum.Material.DiamondPlate)
	part(folder,name.."_Ceiling",Vector3.new(w,1,d),Vector3.new(cx,16.5,cz),C.dark,Enum.Material.Metal)
	local t=1.2
	if doorSide=="South" then
		part(folder,"NorthWall",Vector3.new(w,17,t),Vector3.new(cx,8,cz-d/2),C.wall)
		part(folder,"SouthLeft",Vector3.new((w-12)/2,17,t),Vector3.new(cx-(w+12)/4,8,cz+d/2),C.wall)
		part(folder,"SouthRight",Vector3.new((w-12)/2,17,t),Vector3.new(cx+(w+12)/4,8,cz+d/2),C.wall)
		part(folder,"SouthLintel",Vector3.new(12,4,t),Vector3.new(cx,14,cz+d/2),C.wall)
	else
		part(folder,"NorthWall",Vector3.new(w,17,t),Vector3.new(cx,8,cz-d/2),C.wall)
		part(folder,"SouthWall",Vector3.new(w,17,t),Vector3.new(cx,8,cz+d/2),C.wall)
	end
	if doorSide=="East" then
		part(folder,"WestWall",Vector3.new(t,17,d),Vector3.new(cx-w/2,8,cz),C.wall)
		part(folder,"EastLower",Vector3.new(t,17,(d-12)/2),Vector3.new(cx+w/2,8,cz-(d+12)/4),C.wall)
		part(folder,"EastUpper",Vector3.new(t,17,(d-12)/2),Vector3.new(cx+w/2,8,cz+(d+12)/4),C.wall)
		part(folder,"EastLintel",Vector3.new(t,4,12),Vector3.new(cx+w/2,14,cz),C.wall)
	elseif doorSide=="West" then
		part(folder,"EastWall",Vector3.new(t,17,d),Vector3.new(cx+w/2,8,cz),C.wall)
		part(folder,"WestLower",Vector3.new(t,17,(d-12)/2),Vector3.new(cx-w/2,8,cz-(d+12)/4),C.wall)
		part(folder,"WestUpper",Vector3.new(t,17,(d-12)/2),Vector3.new(cx-w/2,8,cz+(d+12)/4),C.wall)
		part(folder,"WestLintel",Vector3.new(t,4,12),Vector3.new(cx-w/2,14,cz),C.wall)
	else
		part(folder,"WestWall",Vector3.new(t,17,d),Vector3.new(cx-w/2,8,cz),C.wall)
		part(folder,"EastWall",Vector3.new(t,17,d),Vector3.new(cx+w/2,8,cz),C.wall)
	end
	for x=cx-w/2+6,cx+w/2-6,12 do lamp(folder,Vector3.new(x,15.85,cz),C.white) end
	sign(folder,name:upper(),Vector3.new(cx,11,cz-d/2+0.75),math.min(w-4,24),C.blue)
	return folder
end

local function configureLighting()
	Lighting.ClockTime=0
	Lighting.Brightness=2.2
	Lighting.Ambient=Color3.fromRGB(78,84,91)
	Lighting.OutdoorAmbient=Color3.fromRGB(55,61,68)
	Lighting.FogColor=Color3.fromRGB(31,37,43)
	Lighting.FogStart=150; Lighting.FogEnd=520
	Lighting.GlobalShadows=true
	Lighting.ExposureCompensation=0
	pcall(function() Lighting.Technology=Enum.Technology.Future end)
	local atmosphere=Lighting:FindFirstChild("DZ_Atmosphere") or Instance.new("Atmosphere")
	atmosphere.Name="DZ_Atmosphere"; atmosphere.Color=Color3.fromRGB(174,184,190)
	atmosphere.Decay=Color3.fromRGB(66,75,83); atmosphere.Density=0.12
	atmosphere.Glare=0; atmosphere.Haze=0.8; atmosphere.Parent=Lighting
	local cc=Lighting:FindFirstChild("DZ_ColorCorrection") or Instance.new("ColorCorrectionEffect")
	cc.Name="DZ_ColorCorrection"; cc.Brightness=0.015; cc.Contrast=0.08; cc.Saturation=-0.12; cc.Parent=Lighting
end

local function build()
	local old=Workspace:FindFirstChild(ROOT); if old then old:Destroy() end
	local baseplate=Workspace:FindFirstChild("Baseplate"); if baseplate then baseplate:Destroy() end
	local root=Instance.new("Folder"); root.Name=ROOT; root.Parent=Workspace

	-- Bloco principal com perímetro contínuo e um único corredor de entrada controlado.
	part(root,"MainFloor",Vector3.new(112,1,88),Vector3.new(0,-0.5,0),C.floor,Enum.Material.DiamondPlate)
	part(root,"MainCeiling",Vector3.new(112,1,88),Vector3.new(0,16.5,0),C.dark,Enum.Material.Metal)
	part(root,"NorthBoundary",Vector3.new(112,17,1.5),Vector3.new(0,8,-44),C.wall)
	part(root,"WestBoundary",Vector3.new(1.5,17,88),Vector3.new(-56,8,0),C.wall)
	part(root,"EastBoundary",Vector3.new(1.5,17,88),Vector3.new(56,8,0),C.wall)
	-- Parede sul segmentada com abertura central que conecta ao corredor interno.
	part(root,"SouthBoundaryLeft",Vector3.new(47,17,1.5),Vector3.new(-32.5,8,44),C.wall)
	part(root,"SouthBoundaryRight",Vector3.new(47,17,1.5),Vector3.new(32.5,8,44),C.wall)
	part(root,"SouthLintel",Vector3.new(18,4,1.5),Vector3.new(0,14,44),C.wall)
	-- Corredor de acesso fechado no fim; sem saída para o exterior.
	part(root,"EntryFloor",Vector3.new(18,1,34),Vector3.new(0,-0.5,61),C.floor,Enum.Material.DiamondPlate)
	part(root,"EntryCeiling",Vector3.new(18,1,34),Vector3.new(0,16.5,61),C.dark,Enum.Material.Metal)
	part(root,"EntryLeft",Vector3.new(1.5,17,34),Vector3.new(-9,8,61),C.wall)
	part(root,"EntryRight",Vector3.new(1.5,17,34),Vector3.new(9,8,61),C.wall)
	part(root,"EntryEndWall",Vector3.new(18,17,1.5),Vector3.new(0,8,78),C.wall)
	sign(root,"DIMENSÃO ZERO  |  SETOR 01",Vector3.new(0,12,42.9),24,C.white)

	-- Paredes internas delimitam alas; as salas laterais são ambientes completos.
	room(root,"RECEPÇÃO DE SEGURANÇA",-34, -23,38,34,"East")
	room(root,"ENFERMARIA",34,-23,38,34,"West")
	room(root,"ARSENAL",-34,23,38,34,"East")
	room(root,"SALA DE CONTROLE",34,23,38,34,"West")

	-- Corredor central de ligação e zonas funcionais no núcleo.
	part(root,"CentralWalkway",Vector3.new(28,0.04,72),Vector3.new(0,0.02,0),C.floorAlt,Enum.Material.Metal,false)
	for _,z in ipairs({-30,-10,10,30}) do
		local strip=part(root,"FloorGuidance",Vector3.new(0.18,0.02,4),Vector3.new(0,0.05,z),C.yellow,Enum.Material.SmoothPlastic,false)
	end
	-- Reator central como elemento industrial decorativo.
	local reactor=Instance.new("Model"); reactor.Name="REATOR CENTRAL"; reactor.Parent=root
	local core=part(reactor,"ReactorCore",Vector3.new(10,12,10),Vector3.new(0,6,-4),C.dark,Enum.Material.Metal)
	for _,x in ipairs({-6,6}) do
		part(reactor,"ReactorSupport",Vector3.new(1.1,15,1.1),Vector3.new(x,7.5,-4),C.trim,Enum.Material.Metal)
	end
	local status=part(reactor,"ReactorStatus",Vector3.new(7,0.25,0.25),Vector3.new(0,10,-9.2),C.green,Enum.Material.SmoothPlastic,false)
	pointLight(status,C.green,0.6,10)

	-- Bancadas e armários de apoio ficam dentro das alas, sem criar salas sobrepostas.
	for i=1,4 do
		part(root,"MaintenanceBench",Vector3.new(5,1.1,2),Vector3.new(-45+i*5,1.1,27),C.dark,Enum.Material.Metal)
		part(root,"MaintenanceToolCabinet",Vector3.new(2,5,2),Vector3.new(-47+i*7,2.5,36),C.trim,Enum.Material.Metal)
	end
	for _,x in ipairs({25,34,43}) do
		for z=17,31,7 do
			part(root,"SupplyShelf",Vector3.new(1,6,2),Vector3.new(x,3,z),C.trim,Enum.Material.Metal)
			part(root,"SupplyCrate",Vector3.new(2.2,2,2),Vector3.new(x-1.6,1,z),C.dark,Enum.Material.Metal)
		end
	end
	-- Janela de observação reforçada embutida na parede norte.
	local glass=part(root,"ObservationGlass",Vector3.new(18,7,0.35),Vector3.new(0,8,-43.15),C.blue,Enum.Material.Glass,false)
	glass.Transparency=0.48

	-- Detalhes industriais, rodapés, painéis e luminárias sem neon exagerado.
	for _,x in ipairs({-48,-18,18,48}) do
		for _,z in ipairs({-36,0,36}) do
			local pillar=part(root,"StructuralColumn",Vector3.new(2.4,16,2.4),Vector3.new(x,8,z),C.dark,Enum.Material.Metal)
			part(root,"ColumnBand",Vector3.new(2.5,0.35,2.5),Vector3.new(x,13,z),C.yellow,Enum.Material.Metal,false)
		end
	end

	local spawn=Instance.new("SpawnLocation")
	spawn.Name="Setor01Spawn"; spawn.Size=Vector3.new(6,1,6)
	spawn.Position=Vector3.new(0,0.55,29); spawn.Anchored=true
	spawn.Neutral=true; spawn.Duration=0; spawn.Transparency=1
	spawn.CanCollide=false; spawn.CastShadow=false; spawn.Parent=root

	configureLighting()
end

function WorldBuilder.Init()
	build()
	print("[DIMENSÃO ZERO] SETOR 01 gerado. Verifique rotas e colisões no Studio antes de publicar.")
end
return WorldBuilder
