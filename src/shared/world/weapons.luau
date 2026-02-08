local world = require("./world")
local components = require("./components")

local fist = world:entity()
world:set(fist, components.Damage, {
    normal = 1,
    comboEnd = 5,
    critical = 10
})
world:set(fist, components.HitEffects, {
    normal = {
        [components.Effects.Knockback] = {
            vel = Vector3.one * 5,
            duration = 0.05
        },
        [components.Effects.Stun] = 0.15,
    },
    comboEnd = {
        [components.Effects.Knockback] = {
            vel = Vector3.one * 20,
            duration = 0.2
        },
        [components.Effects.Ragdoll] = 0.6,
        [components.Effects.Stun] = 0.6,
    },
    critical = {
    }
})
world:set(fist, components.Name, "Fist")
world:set(fist, components.MaxCombo, 4)

local katana = world:entity()
world:set(katana, components.Damage, {
    normal = 1,
    comboEnd = 5,
    critical = 10
})
world:set(katana, components.HitEffects, {
    normal = {
        [components.Effects.Knockback] = {
            vel = Vector3.one * 5,
            duration = 0.05
        },
        [components.Effects.Stun] = 0.15,
    },
    comboEnd = {
        [components.Effects.Knockback] = {
            vel = Vector3.one * 20,
            duration = 0.2
        },
        [components.Effects.Ragdoll] = 0.6,
        [components.Effects.Stun] = 0.6,
    },
    critical = {
    }
})
world:set(katana, components.Name, "Katana")
world:set(katana, components.MaxCombo, 5)

return {
    ["Fist"] = fist,
    ["Katana"] = katana
}