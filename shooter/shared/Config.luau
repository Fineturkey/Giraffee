--!strict
local weapons: { [string]: { Name: string, Magazine: number, FireInterval: number, ReloadTime: number, Damage: number, HeadDamage: number, Range: number } } = {
    Pulse = {Name = "PULSE BLASTER", Magazine = 24, FireInterval = 0.12, ReloadTime = 1.7, Damage = 25, HeadDamage = 40, Range = 350},
    Arc = {Name = "ARC PISTOL", Magazine = 8, FireInterval = 0.42, ReloadTime = 1.3, Damage = 40, HeadDamage = 65, Range = 400},
}
return {
    Weapons = weapons,
    Title = "NEON CROSSFIRE",
    Magazine = 24,
    FireInterval = 0.12,
    ReloadTime = 1.7,
    Damage = 25,
    HeadDamage = 40,
    Range = 350,
    WalkSpeed = 20,
    RoundSeconds = 180,
    Intermission = 8,
    ScoreToWin = 10,
    SpawnProtection = 2.5,
    Red = Color3.fromRGB(255, 95, 116),
    Blue = Color3.fromRGB(74, 191, 255),
}
