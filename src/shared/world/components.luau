local rs = game:GetService("ReplicatedStorage")

local pkgs = rs:WaitForChild("pkgs")
local jecs = require(pkgs.jecs)

local world = require("./world")

export type HitTicket = {
    issuer: Model,
    target: Model,
    damage: number,
    effects: {}
}

return {
    Effects = {
        Bleed = world:component() :: jecs.Id<number>, -- number: duration
        Stun = world:component() :: jecs.Id<number>,
    },

    Busy = world:component(), -- tag
    Combo = world:component() :: jecs.Id<number>,
    CancelAtk = world:component(),

    HitTicket = world:component() :: jecs.Id<HitTicket>
}