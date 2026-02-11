local players = game:GetService("Players")
local rs = game:GetService("ReplicatedStorage")

local shared = rs:WaitForChild("Shared")
local pkgs = rs:WaitForChild("pkgs")

local world = require(shared.world.world)
local jecs = require(pkgs.jecs)
local components = require(shared.world.components)
local weapons = require(shared.world.weapons)
local utils = require(shared.utils.utils)
local enemy = require(shared.utils.enemy)

function characterSetup(char)
    local hum = char:FindFirstChildOfClass("Humanoid") or char:WaitForChild("Humanoid")
    local plrEntt = utils.getEnttFromCharacter(char)
    world:set(plrEntt, components.EquippedWeapon, weapons.Katana)

    world:remove(plrEntt, components.Busy)
    world:set(plrEntt, components.Combo, 1)
    world:set(plrEntt, components.BlockBar, 100)
    world:set(plrEntt, components.CooldownList, {})
    world:set(plrEntt, components.MovementData, {
        walkSpeed = hum.WalkSpeed,
        jumpHeight = hum.JumpHeight
    })

    utils.createLimbCollidors(char)
end

players.PlayerAdded:Connect(function(player)
    local plrEntt = world:entity(player.UserId)

    world:set(plrEntt, components.Circles, 0)
    world:set(plrEntt, components.Stars, 0)

    local char = player.Character
    if char then characterSetup(char) end

    player.CharacterAdded:Connect(characterSetup)
end)

function createNPCEntt(npc: Model)
    local hum = npc:FindFirstChildOfClass("Humanoid")
    if not hum then hum = npc:WaitForChild("Humanoid") end
    local npcEntt = world:entity()

    local id = Instance.new("IntValue")
    id.Name = "id"
    id.Value = npcEntt
    id.Parent = npc

    -- Poll until the hook is set
    while not world:has(components.NPC, jecs.OnAdd) do task.wait() end
    world:add(npcEntt, components.NPC)
end

for _,npc in workspace["NPC's"]:GetChildren() do
    createNPCEntt(npc)
end


-- FOR TESTING
task.wait(2) -- naive way of waiting for state hooks to be implemented
local enemy_entt = enemy.createEnemy(workspace.Enemies.Dummy, {
    movementData = {walkSpeed = 16, jumpHeight = 50},
    maxHealth = 100
})
world:set(enemy_entt, components.EquippedWeapon, weapons.Fist)
world:set(enemy_entt, components.Stars, 3)
world:set(enemy_entt, components.ChaseRadius, 30)
world:set(enemy_entt, components.AttackRadius, 5)
world:add(enemy_entt, components.Idle)