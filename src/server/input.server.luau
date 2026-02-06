local rs = game:GetService("ReplicatedStorage")

local remotes = rs:WaitForChild("Remotes")
local inputRemote : RemoteEvent = remotes.Input

local shared = rs:WaitForChild("Shared")
local components = require(shared.world.components)
local world = require(shared.world.world)
local abilities = shared.abilities

inputRemote.OnServerEvent:Connect(function(player, inputBuffer)
    local char = player.Character
    if not char then return end
    local cooldownList = world:get(player.UserId, components.CooldownList)

    for _, input in inputBuffer do
        local abilityPath = abilities:FindFirstChild(input.code)
        if not abilityPath or table.find(cooldownList, input.code) then return end
        local ability = require(abilityPath)

        if input.begin then
            local event = ability.Begin(char, player.UserId)
            if event then event:Wait() end
        else
            ability.End(char, player.UserId)

            -- CD
            table.insert(cooldownList, input.code)
            world:set(player.UserId, components.CooldownList, cooldownList)
            task.delay(ability.CooldownDuration, function()
                local code_i = table.find(cooldownList, input.code)
                if not code_i then return end
                table.remove(cooldownList, code_i)
                world:set(player.UserId, components.CooldownList, cooldownList)
            end)
        end
    end
end)