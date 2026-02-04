local players = game:GetService("Players")
local rs = game:GetService("ReplicatedStorage")

local shared = rs:WaitForChild("Shared")
local world = require(shared.world.world)
local components = require(shared.world.components)

players.PlayerAdded:Connect(function(player)
    local plrEntt = world:entity(player.UserId)

    player.CharacterAdded:Connect(function()
        world:remove(plrEntt, components.Busy)
        world:set(plrEntt, components.Combo, 1)
    end)
end)

for _,enemy in workspace.Enemies:GetChildren() do
    local enemyEntt = world:entity()

    local id = Instance.new("IntValue")
    id.Name = "id"
    id.Value = enemyEntt
    id.Parent = enemy
end

workspace.Enemies.ChildAdded:Connect(function(enemy)
    local enemyEntt = enemy:FindFirstChild("id")
    if not enemyEntt then return end
    enemyEntt = world:entity()

    local id = Instance.new("IntValue")
    id.Name = "id"
    id.Value = enemyEntt
    id.Parent = enemy
end)

workspace.Enemies.ChildRemoved:Connect(function(enemy)
    local enemyEntt = enemy:FindFirstChild("id")
    if not enemyEntt then return end

    world:delete(enemyEntt)
end)