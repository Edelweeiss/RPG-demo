local rs = game:GetService("ReplicatedStorage")

local shared = rs:WaitForChild("Shared")
-- local assets = rs:WaitForChild("Assets")
-- local remotes = rs:WaitForChild("Remotes")

local jecs = require(rs.pkgs.jecs)
local world = require(shared.world.world)
local components = require(shared.world.components)

-- local vfx = assets.Vfx

local function getCharacterFromEntity(entity)
    local char = nil
    local plr = game.Players:GetPlayerByUserId(entity)
    if plr then
        char = plr.Character
    else
        for _, character in workspace.Enemies:GetChildren() do
            local _id = character:FindFirstChild("id")
            if not _id then continue end
            if _id.Value == entity then
                char = character
                break
            end
        end
    end

    return char
end

world:set(components.Effects.Stun, jecs.OnAdd, function(entity, id, duration)
    local char = getCharacterFromEntity(entity)
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local originalSpeed = hum.WalkSpeed
    local originalJump = hum.JumpPower

    hum.WalkSpeed = 0
    hum.JumpPower = 0

    if not world:has(entity, components.Busy) then
        world:add(entity, components.Busy)
    end

    task.delay(duration, function()
        world:remove(entity, components.Effects.Stun)

        hum.WalkSpeed = originalSpeed
        hum.JumpPower = originalJump
    end)
end)

-- TODO
world:set(components.Effects.Bleed, jecs.OnAdd, function(entity, id, duration)
    task.delay(duration, world.remove, world, entity, components.Effects.Stun)
end)