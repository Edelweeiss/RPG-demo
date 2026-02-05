local players = game:GetService("Players")
local rs = game:GetService("ReplicatedStorage")

local shared = rs:WaitForChild("Shared")
local world = require(shared.world.world)
local components = require(shared.world.components)

players.PlayerAdded:Connect(function(player)
    local plrEntt = world:entity(player.UserId)

    world:set(plrEntt, components.Circles, 0)
    world:set(plrEntt, components.Stars, 0)

    player.CharacterAdded:Connect(function()
        world:remove(plrEntt, components.Busy)
        world:set(plrEntt, components.Combo, 1)
        world:set(plrEntt, components.BlockBar, 100)
        world:set(plrEntt, components.CooldownList, {})
    end)
end)

function createEnemeyEntt(enemy: Model)
    local enemyEntt = world:entity()

    local id = Instance.new("IntValue")
    id.Name = "id"
    id.Value = enemyEntt
    id.Parent = enemy

    world:set(enemyEntt, components.Combo, 1)
    world:set(enemyEntt, components.BlockBar, 100)
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