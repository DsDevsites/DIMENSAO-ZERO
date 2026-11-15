-- Valores-base do combate. Armas específicas serão adicionadas em outra etapa.
local CombatConfig = {
    Enabled = false, -- Ativar quando a primeira arma estiver implementada.
    MaxShotDistance = 500,
    ShotCooldown = 0.15,
    MagazineSize = 30,
    ReloadTime = 2,
    BodyDamage = 20,
    HeadshotMultiplier = 2,
    OriginTolerance = 12,
}
return table.freeze(CombatConfig)
