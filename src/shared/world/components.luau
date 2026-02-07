local rs = game:GetService("ReplicatedStorage")

local pkgs = rs:WaitForChild("pkgs")
local jecs = require(pkgs.jecs)

local world = require("./world")

export type HitTicket_t = {
    issuer: Model,
    target: Model,
    damage: number,
    effects: {}
}

export type KbData_t = {
    vel: Vector3,
    duration: number
}

export type Map_t<T,V> = {[T]:V}

export type HitEffects_t = {
    normal: Map_t<jecs.Id<any>,any>,
    comboEnd: Map_t<jecs.Id<any>,any>,
    critical: Map_t<jecs.Id<any>,any>
}

export type Damage_t = {
    normal: number,
    comboEnd: number,
    critical: number
}

export type MovementData_t = {
    walkSpeed: number,
    jumpHeight: number,
}

export type DialogueContext_t = {
    listner: Player,
    speaker: string
}

return {
    Effects = {
        Bleed = world:component() :: jecs.Id<number>, -- number: duration
        Stun = world:component() :: jecs.Id<number>,
        Ragdoll = world:component() :: jecs.Id<number>,
        Knockback = world:component() :: jecs.Id<KbData_t>,
    },

    Busy = world:component(), -- tag
    CancelAtk = world:component(),
    Parry = world:component(),
    BlockBar = world:component() :: jecs.Id<number>, -- number: (0 - 100), when 0 -> block break occurs
    CooldownList = world:component() :: jecs.Id<{string}>,
    EquippedWeapon = world:component() :: jecs.Id<jecs.Entity>,

    Combo = world:component() :: jecs.Id<number>,
    Circles = world:component() :: jecs.Id<number>, -- number: (0 - 9), for magic!
    Stars = world:component() :: jecs.Id<number>, -- number: (0 - 9), for aura!
    HitTicket = world:component() :: jecs.Id<HitTicket_t>,
    MovementData = world:component() :: jecs.Id<MovementData_t>,

    -- Weapon comps
    Damage = world:component() :: jecs.Id<Damage_t>,
    HitEffects = world:component() :: jecs.Id<HitEffects_t>,
    Name = world:component() :: jecs.Id<string>,

    -- Dialogue sys
    DialogueContext = world:component() :: jecs.Id<DialogueContext_t>,
    ActiveDialogue = world:component() :: jecs.Id<number>, -- number: node_id
}