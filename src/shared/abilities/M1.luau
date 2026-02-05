local rs = game:GetService("ReplicatedStorage")

local world = require("../world/world")
local components = require("../world/components")
local hb = require("../utils/hitbox")

local assets = rs:WaitForChild("Assets")

--TODO: make it a prop instead of a constant!
local MAX_COMBO = 4

function Begin(char: Model, entt)
    if world:has(entt, components.Busy) or world:has(entt, components.Effects.Stun) then return end
    world:remove(entt, components.CancelAtk)
    world:add(entt, components.Busy)

    local weapon = world:get(entt, components.EquippedWeapon)
    local animations = assets.Animations[world:get(weapon, components.Name)]
    local hum = char:FindFirstChildOfClass("Humanoid")
    local rootPart = hum.RootPart

    local combo = world:get(entt, components.Combo)
    local anim : AnimationTrack = hum.Animator:LoadAnimation(animations[combo])
    anim:Play()

    local hitConn = nil
    local endConn = nil

    hitConn = anim:GetMarkerReachedSignal("hit"):Connect(function()
        -- pack up gng 💔
        if world:has(entt, components.CancelAtk) then
            endConn:Disconnect()
            anim:Stop()
            world:remove(entt, components.CancelAtk)
            world:remove(entt, components.Busy)
            hitConn:Disconnect()
            return
        end

        local damage = world:get(weapon, components.Damage)
        local effects = world:get(weapon, components.HitEffects)

        for _, effectTable in {effects.normal, effects.comboEnd, effects.critical} do
            local knockback = effectTable[components.Effects.Knockback]
            if knockback then
                knockback.vel = knockback.vel.Magnitude * rootPart.CFrame.LookVector
            end
        end

        if combo >= MAX_COMBO then
            hb.spawn(
                char,
                Vector3.one * 5,
                rootPart.CFrame * CFrame.new(0,0,-3.5),
                damage.comboEnd,
                {char, workspace.Map},
                effects.comboEnd,
                true
            )
        else
            hb.spawn(
                char,
                Vector3.one * 5,
                rootPart.CFrame * CFrame.new(0,0,-3.5),
                damage.normal,
                {char, workspace.Map},
                effects.normal,
                true
            )
        end
    end)

    endConn = anim:GetMarkerReachedSignal("end"):Connect(function()
        if combo >= MAX_COMBO then
            world:set(entt, components.Combo, 1)
            task.wait(0.3)
        else
            world:set(entt, components.Combo, combo+1)
        end
        world:remove(entt, components.Busy)
        world:remove(entt, components.CancelAtk)

        -- Rest combat if not busy for more than 1.5 seconds
        local comboReset = task.delay(1.5, function()
            world:set(entt, components.Combo, 1)
        end)
        world:added(components.Busy, function(e, id, value)
            task.cancel(comboReset)
        end)
    end)
end

function End(char: Model, entt)
end

return {
    Begin = Begin,
    End = End,
    CooldownDuration = 0
}