local rs = game:GetService("ReplicatedStorage")

local jecs = require(rs.pkgs.jecs)
local world = require("../world/world")
local components = require("../world/components")
local hb = require("../utils/hitbox")

local animations = rs:WaitForChild("Assets").Animations.M1

--TODO: make it a prop instead of a constant!
local MAX_COMBO = 4

function Begin(player: Player)
    local plrEntt = player.UserId
    if not plrEntt then return end

    if world:has(plrEntt, components.Busy) or world:has(plrEntt, components.Effects.Stun) then return end
    world:remove(plrEntt, components.CancelAtk)
    world:add(plrEntt, components.Busy)

    local char = player.Character or player.CharacterAdded:Wait()
    local hum = char:FindFirstChildOfClass("Humanoid")
    local rootPart = hum.RootPart

    local combo = world:get(plrEntt, components.Combo)
    local anim : AnimationTrack = hum.Animator:LoadAnimation(animations[combo])
    anim:Play()

    local hitConn = nil
    local endConn = nil

    hitConn = anim:GetMarkerReachedSignal("hit"):Connect(function()
        -- pack up gng 💔
        if world:has(plrEntt, components.CancelAtk) then
            endConn:Disconnect()
            anim:Stop()
            world:remove(plrEntt, components.CancelAtk)
            world:remove(plrEntt, components.Busy)
            hitConn:Disconnect()
            return
        end

        hb.spawn(
            char,
            Vector3.one * 5,
            rootPart.CFrame * CFrame.new(0,0,-3.5),
            {char, workspace.Map},
            {
                [components.Effects.Stun] = 0.15
            },
            true
        )
    end)

    endConn = anim:GetMarkerReachedSignal("end"):Connect(function()
        if combo >= MAX_COMBO then
            world:set(plrEntt, components.Combo, 1)
            task.wait(0.3)
        else
            world:set(plrEntt, components.Combo, combo+1)
        end
        world:remove(plrEntt, components.Busy)
        world:remove(plrEntt, components.CancelAtk)

        -- Rest combat if not busy for more than 1.5 seconds
        local comboReset = task.delay(1.5, function()
            world:set(plrEntt, components.Combo, 1)
        end)
        world:set(components.Busy, jecs.OnAdd, function(entity, id, data)
            task.cancel(comboReset)
        end)
    end)
end

function End(player: Player)
end

return {
    Begin = Begin,
    End = End
}