local rs = game:GetService("ReplicatedStorage")

local shared = rs:WaitForChild("Shared")
local jecs = require(rs.pkgs.jecs)
local world = require(shared.world.world)
local components = require(shared.world.components)

world:set(components.hitTicket, jecs.OnAdd, function(entity, id, ticket)
    local eHum = ticket.target:FindFirstChildOfClass("Humanoid")
    eHum:TakeDamage(ticket.damage)

    world:delete(entity)
end)