--!strict
return {
    GameName = "Steal a Monster Egg",
    BasePosition = Vector3.new(0, 2, 45),
    NestPosition = Vector3.new(0, 2, -65),
    SafeRadius = 15,
    WalkSpeed = 20,
    WakeDelay = 2,
    MonsterSpeed = 24,
    CatchDistance = 5,
    RespawnSeconds = 10,
    UpgradeCost = 60,
    MaxUpgradeLevel = 3,
    HatchSeconds = 3,
    SprintBonus = 7,
    SprintDrain = 25,
    StaminaRecovery = 18,
    CollectionBonus = 100,
    Eggs = {
        { Name = "Mossling", Color = Color3.fromRGB(121, 238, 147), Value = 20, Speed = 18 },
        { Name = "Emberhorn", Color = Color3.fromRGB(255, 155, 74), Value = 40, Speed = 16 },
        { Name = "Voidwing", Color = Color3.fromRGB(186, 135, 255), Value = 75, Speed = 14 },
    },
}
