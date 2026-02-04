local rs = game:GetService("ReplicatedStorage")

local pkgs = rs:WaitForChild("pkgs")
local jecs = require(pkgs.jecs)

local world = require("./world")

export type HitTicket = {
    target: Model,
    damage: number,
}

return {
    Effects = {
        Bleed = world:component() :: jecs.Id<number>, -- number: time on which it is to be removed!
        Stun = world:component() :: jecs.Id<number>,
    },

    Busy = world:component(), -- tag
    Combo = world:component() :: jecs.Id<number>,

    hitTicket = world:component() :: jecs.Id<HitTicket>
}