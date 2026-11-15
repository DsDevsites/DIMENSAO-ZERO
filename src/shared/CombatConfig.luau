-- Balanceamento central da DZ-01. Ajustes futuros devem ser feitos aqui.
local CombatConfig = {
	Enabled = true,
	WeaponId = "DZ-01",
	MagazineSize = 30,
	ReserveAmmo = 90,
	ShotCooldown = 0.12,
	ReloadTime = 2.2,
	BodyDamage = 20,
	HeadshotMultiplier = 2,
	MaxShotDistance = 500,
	OriginTolerance = 12,
}
return table.freeze(CombatConfig)
