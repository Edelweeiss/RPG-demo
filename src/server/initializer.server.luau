local players = game:GetService("Players")
local rs = game:GetService("ReplicatedStorage")

local shared = rs:WaitForChild("Shared")
local world = require(shared.world.world)
local components = require(shared.world.components)
local weapons = require(shared.world.weapons)

function createLimbCollidors(char: Model)
    local hum = char:FindFirstChildOfClass("Humanoid")
    hum.BreakJointsOnDeath = false
    hum.RequiresNeck = false

    for _,v in char:GetChildren() do
        if not v:IsA("BasePart") or v == hum.RootPart then return end
        local fakeLimb = Instance.fromExisting(v)
        fakeLimb.CanCollide = false
        fakeLimb.CanTouch = false
        fakeLimb.CanQuery = false
        fakeLimb.Massless = true
        fakeLimb.Size = Vector3.one
        fakeLimb.Transparency = 1
        fakeLimb.Name = "FakeLimb"
        fakeLimb:ClearAllChildren()
        fakeLimb.Parent = v

        local weld = Instance.new("Weld")
        weld.Part0 = v
        weld.Part1 = fakeLimb
        weld.Parent = fakeLimb
    end
end

players.PlayerAdded:Connect(function(player)
    local plrEntt = world:entity(player.UserId)

    world:set(plrEntt, components.Circles, 0)
    world:set(plrEntt, components.Stars, 0)
    -- ONLY READ FROM WEAPONS!!
    world:set(plrEntt, components.EquippedWeapon, weapons.fist)

    player.CharacterAdded:Connect(function(char)
        world:remove(plrEntt, components.Busy)
        world:set(plrEntt, components.Combo, 1)
        world:set(plrEntt, components.BlockBar, 100)
        world:set(plrEntt, components.CooldownList, {})

        createLimbCollidors(char)
    end)
end)

function createEnemeyEntt(enemy: Model)
    local enemyEntt = world:entity()

    local id = Instance.new("IntValue")
    id.Name = "id"
    id.Value = enemyEntt
    id.Parent = enemy

    world:set(enemyEntt, components.EquippedWeapon, weapons.fist)
    world:set(enemyEntt, components.Combo, 1)
    world:set(enemyEntt, components.BlockBar, 100)

    createLimbCollidors(enemy)
end

for _,enemy in workspace.Enemies:GetChildren() do
    createEnemeyEntt(enemy)
end

workspace.Enemies.ChildAdded:Connect(function(enemy)
    createEnemeyEntt(enemy)
end)

workspace.Enemies.ChildRemoved:Connect(function(enemy)
    local enemyEntt = enemy:FindFirstChild("id")
    if not enemyEntt then return end

    world:delete(enemyEntt)
end)