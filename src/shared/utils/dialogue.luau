local rs = game:GetService("ReplicatedStorage")

local shared = rs:WaitForChild("Shared")
local signal_lib = require(shared.utils.lemon_signal)
local world = require(shared.world.world)
local components = require(shared.world.components)
local map = require(shared.dialougeMap)

function spawnDialogue(context: components.DialogueContext_t, start_node: number?) : signal_lib.Signal<>
    local dialogue = world:entity()
    local data = map[context.speaker]
    -- ORDER MATTERS
    world:set(dialogue, components.ActiveDialogue, start_node or data.StartNode(context.listner.UserId))
    world:set(dialogue, components.DialogueContext, context)

    return data.EndSignal
end

return {
    spawnDialogue = spawnDialogue
}