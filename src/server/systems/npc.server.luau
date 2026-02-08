local rs = game:GetService("ReplicatedStorage")

local shared = rs:WaitForChild("Shared")
-- local assets = rs:WaitForChild("Assets")

local world = require(shared.world.world)
local components = require(shared.world.components)
local utils = require(shared.utils.utils)
local dialogue = require(shared.utils.dialogue)
local dialogueMap = require(shared.dialougeMap)

world:added(components.NPC, function(entt, id)
    local npc = utils.getCharacterFromEntt(entt)
    if not npc then return end

    local prompt = Instance.new("ProximityPrompt")
    prompt.ActionText = "Talk"
    prompt.ObjectText = npc.Name
    prompt.RequiresLineOfSight = false
    prompt.MaxActivationDistance = 5
    prompt.HoldDuration = 0.5
    prompt.Parent = npc.PrimaryPart

    prompt.Triggered:Connect(function(player)
        local entt = player.UserId
        if world:has(entt, components.Effects.Stun) or world:has(entt, components.Busy) then return end

        world:add(entt, components.Effects.Stun)
        dialogue.spawnDialogue({listner = player, speaker = npc.Name}):Once(function()
            world:remove(entt, components.Effects.Stun)
        end)
    end)
end)

-- TODO: effects and stuff
dialogueMap["Aura Teacher (3-STAR)"][3].signal:Connect(function(entt)
    world:set(entt, components.Stars, 1)
end)