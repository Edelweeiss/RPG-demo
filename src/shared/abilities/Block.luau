local rs = game:GetService("ReplicatedStorage")

local jecs = require(rs.pkgs.jecs)
local world = require("../world/world")
local components = require("../world/components")
local utils = require("../utils/utils")

local animations = rs:WaitForChild("Assets").Animations
local PARRY_WINDOW = 0.5

function Begin(char: Model, entt)
    if world:has(entt, components.Busy) or world:has(entt, components.Effects.Stun) then return end
    local weapon = world:get(entt, components.EquippedWeapon)
    if not weapon then return end

    local hum = char:FindFirstChildOfClass("Humanoid")
    hum.Animator:LoadAnimation(animations[world:get(weapon, components.Name)].Block):Play()

    world:add(entt, components.Busy)
    if not world:has(components.BlockBar, jecs.OnChange) then
        world:changed(components.BlockBar, function(e, id, value)
            if value <= 0 then BlockBreak(char, entt) end
        end)
    end

    world:set(entt, components.MovementData, {walkSpeed = hum.WalkSpeed, jumpHeight = hum.JumpHeight})
    hum.WalkSpeed = 4
    hum.JumpHeight = 0

    -- for parying
    world:add(entt, components.Parry)
    task.delay(PARRY_WINDOW, world.remove, world, entt, components.Parry)
end

function End(char: Model, entt)
    local hum = char:FindFirstChildOfClass("Humanoid")

    local track = utils.findAnimationTrack(hum.Animator, "Block")
    if not track then return end
    track:Stop()

    local movementData = world:get(entt, components.MovementData)
    hum.WalkSpeed = movementData.walkSpeed
    hum.JumpHeight = movementData.jumpHeight

    world:remove(entt, components.Busy)
    world:remove(entt, components.Parry)
end

function BlockBreak(char: Model, entt)
    End(char, entt)
    world:set(entt, components.Effects.Stun, 1)
    world:set(entt, components.BlockBar, 100)

    local hum = char:FindFirstChildOfClass("Humanoid")
    hum.Animator:LoadAnimation(animations.Break):Play()
end

return {
    Begin = Begin,
    End = End,
    CooldownDuration = 1
}