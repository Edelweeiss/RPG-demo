local rs = game:GetService("ReplicatedStorage")

local shared = rs:WaitForChild("Shared")
local assets = rs:WaitForChild("Assets")
local remotes = rs:WaitForChild("Remotes")

local world = require(shared.world.world)
local components = require(shared.world.components)
local utils = require(shared.utils.utils)

local animations = assets.Animations
local vfx = assets.Vfx

world:added(components.HitTicket, function(entity, id, ticket)
    local eHum = ticket.target:FindFirstChildOfClass("Humanoid")
    local eEntt = utils.getEnttFromCharacter(ticket.target)
    if not eEntt or not eHum then return end

    world:delete(entity)

    local barVal = world:get(eEntt, components.BlockBar)
    if not barVal then return end
    if world:has(eEntt, components.Parry) then
        world:set(eEntt, components.BlockBar, math.clamp(barVal+10, 0, 100))

        local plrEntt = utils.getEnttFromCharacter(ticket.issuer)
        world:set(plrEntt, components.Effects.Stun, 1)

        return
    elseif barVal > 0 and utils.findAnimationTrack(eHum.Animator, "Block") then
        world:set(eEntt, components.BlockBar, math.clamp(barVal-(ticket.damage*20), 0, 100))
        return
    end

    eHum:TakeDamage(ticket.damage)

    for effect, duration in ticket.effects do
        if world:has(eEntt, effect) then continue end
        world:set(eEntt, effect, duration)
    end

    eHum.Animator:LoadAnimation(animations.Hit[math.random(1,#animations.Hit:GetChildren())]):Play()
    remotes.Vfx:FireAllClients(vfx.Hit.Hit, eHum.RootPart.CFrame, 1)
end)