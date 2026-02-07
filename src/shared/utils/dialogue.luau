local rs = game:GetService("ReplicatedStorage")

local shared = rs:WaitForChild("Shared")
local world = require(shared.world.world)
local components = require(shared.world.components)

function spawnDialogue(context: components.DialogueContext_t, start_node: number?)
    local dialogue = world:entity()
    -- ORDER MATTERS
    world:set(dialogue, components.ActiveDialogue, start_node or 1)
    world:set(dialogue, components.DialogueContext, context)
end

return {
    spawnDialogue = spawnDialogue
}