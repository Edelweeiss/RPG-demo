local rs = game:GetService("ReplicatedStorage")
local shared = rs:WaitForChild("Shared")

local jecs = require(rs.pkgs.jecs)
local world = require(shared.world.world)
local components = require(shared.world.components)
local utils = require(shared.utils.utils)

export type EnemyData = {
    movementData: components.MovementData_t,
    maxHealth: number,
}

function createEnemy(enemy: Model ,data: EnemyData) : jecs.Entity
    local hum = enemy:FindFirstChildOfClass("Humanoid")
    if not hum then hum = enemy:WaitForChild("Humanoid") end
    local enemyEntt = world:entity()

    local id = Instance.new("IntValue")
    id.Name = "id"
    id.Value = enemyEntt
    id.Parent = enemy

    hum.WalkSpeed = data.movementData.walkSpeed
    hum.JumpHeight = data.movementData.jumpHeight
    hum.MaxHealth = data.maxHealth
    hum.Health = data.maxHealth

    world:set(enemyEntt, components.Combo, 1)
    world:set(enemyEntt, components.BlockBar, 100)
    world:set(enemyEntt, components.MovementData, data.movementData)
    utils.createLimbCollidors(enemy)

    return enemyEntt
end

return {
    createEnemy = createEnemy
}