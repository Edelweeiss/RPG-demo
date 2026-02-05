local rs = game:GetService("ReplicatedStorage")

local shared = rs:WaitForChild("Shared")
-- local assets = rs:WaitForChild("Assets")
-- local remotes = rs:WaitForChild("Remotes")

local world = require(shared.world.world)
local components = require(shared.world.components)
local utils = require(shared.utils.utils)

-- local vfx = assets.Vfx

world:added(components.Effects.Stun, function(entity, id, duration)
    local char = utils.getCharacterFromEntt(entity)
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local originalSpeed = hum.WalkSpeed
    local originalJump = hum.JumpPower

    hum.WalkSpeed = 0
    hum.JumpPower = 0

    world:add(entity, components.Busy)
    world:add(entity, components.CancelAtk)

    task.delay(duration, function()
        world:remove(entity, components.Effects.Stun)
        world:remove(entity, components.Busy)

        hum.WalkSpeed = originalSpeed
        hum.JumpPower = originalJump
    end)
end)

world:added(components.Effects.Knockback, function(entity, id, data)
    local char = utils.getCharacterFromEntt(entity)
    if not char then return end
    local rootPart = char:FindFirstChild("HumanoidRootPart")

    local linearVel = Instance.new("LinearVelocity")
    linearVel.Attachment0 = rootPart:FindFirstChildOfClass("Attachment")
    linearVel.MaxForce = math.huge
    linearVel.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
    linearVel.RelativeTo = Enum.ActuatorRelativeTo.World
    linearVel.VectorVelocity = data.vel
    linearVel.Parent = rootPart

    task.delay(data.duration, function()
        world:remove(entity, components.Effects.Knockback)
        linearVel:Destroy()
    end)
end)

-- TODO
world:added(components.Effects.Bleed, function(entity, id, duration)
    task.delay(duration, world.remove, world, entity, components.Effects.Bleed)
end)