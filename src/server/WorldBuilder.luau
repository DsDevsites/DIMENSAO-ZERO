-- Construtor procedural do SETOR 01. A geometria e criada no servidor.
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local WorldBuilder = {}
local ROOT_NAME = "DIMENSAO_ZERO_WORLD"

local C = {
    floor = Color3.fromRGB(38, 45, 52),
    wall = Color3.fromRGB(65, 75, 83),
    dark = Color3.fromRGB(19, 25, 31),
    orange = Color3.fromRGB(255, 111, 35),
    cyan = Color3.fromRGB(40, 205, 220),
    white = Color3.fromRGB(205, 218, 225),
}

local function part(parent, name, size, position, color, material)
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.Position = position
    p.Anchored = true
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    p.Color = color
    p.Material = material or Enum.Material.Concrete
    p.Parent = parent
    return p
end

local function light(parent, color, brightness, range)
    local lamp = Instance.new("PointLight")
    lamp.Color = color
    lamp.Brightness = brightness
    lamp.Range = range
    lamp.Shadows = true
    lamp.Parent = parent
end

local function label(parent, text, face)
    local gui = Instance.new("SurfaceGui")
    gui.Name = "SignGui"
    gui.Face = face or Enum.NormalId.Front
    gui.CanvasSize = Vector2.new(600, 180)
    gui.Parent = parent
    local txt = Instance.new("TextLabel")
    txt.Size = UDim2.fromScale(1, 1)
    txt.BackgroundColor3 = C.dark
    txt.BackgroundTransparency = 0.12
    txt.Text = text
    txt.TextColor3 = C.orange
    txt.Font = Enum.Font.GothamBold
    txt.TextScaled = true
    txt.Parent = gui
end

local function configureLighting()
    Lighting.ClockTime = 14
    Lighting.Brightness = 2.1
    Lighting.Ambient = Color3.fromRGB(72, 82, 94)
    Lighting.OutdoorAmbient = Color3.fromRGB(38, 45, 55)
    Lighting.FogColor = Color3.fromRGB(25, 35, 43)
    Lighting.FogStart = 120
    Lighting.FogEnd = 360
    Lighting.GlobalShadows = true
    Lighting.Technology = Enum.Technology.Future
    Lighting.ExposureCompensation = -0.15

    local atmosphere = Lighting:FindFirstChild("DZ_Atmosphere")
    if not atmosphere then
        atmosphere = Instance.new("Atmosphere")
        atmosphere.Name = "DZ_Atmosphere"
        atmosphere.Parent = Lighting
    end
    atmosphere.Color = Color3.fromRGB(155, 185, 200)
    atmosphere.Decay = Color3.fromRGB(55, 75, 90)
    atmosphere.Density = 0.18
    atmosphere.Glare = 0
    atmosphere.Haze = 1
end

local function build()
    local old = Workspace:FindFirstChild(ROOT_NAME)
    if old then old:Destroy() end

    local root = Instance.new("Folder")
    root.Name = ROOT_NAME
    root.Parent = Workspace

    -- Sala principal: 100 x 72 studs.
    part(root, "MainFloor", Vector3.new(100, 2, 72), Vector3.new(0, -1, 0), C.floor, Enum.Material.Metal)
    part(root, "Ceiling", Vector3.new(100, 2, 72), Vector3.new(0, 18, 0), C.dark, Enum.Material.Metal)
    part(root, "NorthWall", Vector3.new(100, 20, 2), Vector3.new(0, 8, -37), C.wall)
    -- A parede sul agora possui abertura central alinhada ao corredor.
    part(root, "SouthWallLeft", Vector3.new(41, 20, 2), Vector3.new(-29.5, 8, 37), C.wall)
    part(root, "SouthWallRight", Vector3.new(41, 20, 2), Vector3.new(29.5, 8, 37), C.wall)
    part(root, "SouthWallLintel", Vector3.new(18, 5, 2), Vector3.new(0, 15.5, 37), C.wall)
    part(root, "WestWall", Vector3.new(2, 20, 72), Vector3.new(-51, 8, 0), C.wall)
    part(root, "EastWall", Vector3.new(2, 20, 72), Vector3.new(51, 8, 0), C.wall)

    -- Corredor aberto conectado a sala principal.
    part(root, "EntryFloor", Vector3.new(24, 2, 34), Vector3.new(0, -1, 53), C.floor, Enum.Material.Metal)
    part(root, "EntryLeftWall", Vector3.new(2, 20, 34), Vector3.new(-13, 8, 53), C.wall)
    part(root, "EntryRightWall", Vector3.new(2, 20, 34), Vector3.new(13, 8, 53), C.wall)
    part(root, "EntryCeiling", Vector3.new(28, 2, 34), Vector3.new(0, 18, 53), C.dark, Enum.Material.Metal)

    -- Divisorias laterais, preservando corredores de passagem.
    part(root, "LabPartitionA", Vector3.new(2, 15, 26), Vector3.new(22, 6.5, -22), C.wall)
    part(root, "LabPartitionB", Vector3.new(28, 15, 2), Vector3.new(36, 6.5, -9), C.wall)
    part(root, "ControlPartition", Vector3.new(2, 15, 24), Vector3.new(-25, 6.5, -24), C.wall)

    for z = -30, 30, 12 do
        part(root, "FloorSafetyLine", Vector3.new(1, 0.12, 5), Vector3.new(-43, 0.08, z), C.orange, Enum.Material.Neon)
        part(root, "FloorSafetyLine", Vector3.new(1, 0.12, 5), Vector3.new(43, 0.08, z), C.orange, Enum.Material.Neon)
    end

    for _, x in ipairs({-42, -18, 18, 42}) do
        for _, z in ipairs({-29, 29}) do
            part(root, "SupportPillar", Vector3.new(3, 18, 3), Vector3.new(x, 8, z), C.dark, Enum.Material.Metal)
            local strip = part(root, "PillarLight", Vector3.new(0.25, 8, 0.25), Vector3.new(x, 9, z + 1.63), C.cyan, Enum.Material.Neon)
            light(strip, C.cyan, 1.2, 16)
        end
    end

    -- Iluminacao de teto mais forte, sem perder o clima subterraneo.
    for _, x in ipairs({-35, -12, 12, 35}) do
        for _, z in ipairs({-22, 0, 22}) do
            local fixture = part(root, "CeilingLamp", Vector3.new(7, 0.35, 1.2), Vector3.new(x, 16.8, z), C.cyan, Enum.Material.Neon)
            light(fixture, C.cyan, 2.2, 34)
        end
    end
    for _, z in ipairs({43, 58, 68}) do
        local fixture = part(root, "CorridorLamp", Vector3.new(5, 0.3, 1), Vector3.new(0, 16.8, z), C.white, Enum.Material.Neon)
        light(fixture, C.white, 2, 30)
    end

    -- Spawn dentro da sala principal, livre de paredes e consoles.
    local spawn = Instance.new("SpawnLocation")
    spawn.Name = "Setor01Spawn"
    spawn.Size = Vector3.new(6, 1, 6)
    spawn.Position = Vector3.new(0, 0.5, 22)
    spawn.Anchored = true
    spawn.Neutral = true
    spawn.Duration = 1
    spawn.Transparency = 0.35
    spawn.Color = C.orange
    spawn.Material = Enum.Material.Neon
    spawn.Parent = root

    local sign = part(root, "SectorSign", Vector3.new(18, 5, 0.5), Vector3.new(0, 12, 35.7), C.dark, Enum.Material.Metal)
    label(sign, "DIMENSAO ZERO  |  SETOR 01", Enum.NormalId.Front)

    for _, x in ipairs({-37, -30, 30, 37}) do
        local desk = part(root, "ResearchConsole", Vector3.new(7, 3, 3), Vector3.new(x, 1.5, -20), C.dark, Enum.Material.Metal)
        local screen = part(root, "ConsoleScreen", Vector3.new(5.5, 1.5, 0.18), Vector3.new(x, 3.8, -18.4), C.cyan, Enum.Material.Neon)
        light(screen, C.cyan, 0.8, 12)
    end

    configureLighting()
end

function WorldBuilder.Init()
    build()
    print("[DIMENSAO ZERO] SETOR 01 construido: iluminacao revisada, entrada livre e spawn interno.")
end

return WorldBuilder
