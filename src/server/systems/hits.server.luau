local rs = game:GetService("ReplicatedStorage")

local shared = rs:WaitForChild("Shared")
local assets = rs:WaitForChild("Assets")
local remotes = rs:WaitForChild("Remotes")

local jecs = require(rs.pkgs.jecs)
local world = require(shared.world.world)
local components = require(shared.world.components)

local animations = assets.Animations
local vfx = assets.Vfx

world:set(components.HitTicket, jecs.OnAdd, function(entity, id, ticket)
    local eHum = ticket.target:FindFirstChildOfClass("Humanoid")
    local eEntt = ticket.target:FindFirstChild("id")
    if not eEntt or not eHum then return end
    eEntt = eEntt.Value
    eHum:TakeDamage(ticket.damage)

    for effect, duration in ticket.effects do
        if world:has(eEntt, effect) then continue end
        world:set(eEntt, effect, duration)
    end

    eHum.Animator:LoadAnimation(animations.Hit[math.random(1,3)]):Play()
    remotes.Vfx:FireAllClients(vfx.Hit.Hit, eHum.RootPart.CFrame, 1)

    world:delete(entity)
end)