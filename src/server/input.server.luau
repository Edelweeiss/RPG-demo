local rs = game:GetService("ReplicatedStorage")

local remotes = rs:WaitForChild("Remotes")
local inputRemote : RemoteEvent = remotes.Input

local shared = rs:WaitForChild("Shared")
local components = require(shared.world.components)
local world = require(shared.world.world)
local abilities = shared.abilities

inputRemote.OnServerEvent:Connect(function(player, code, began : boolean)
    local char = player.Character or player.CharacterAdded:Wait()
    if not char or not abilities:FindFirstChild(code) then return end

    local cooldownList = world:get(player.UserId, components.CooldownList)
    if table.find(cooldownList, code) then return end
    local ability = require(abilities[code])

    if began then
        ability.Begin(char, player.UserId)
    else
        ability.End(char, player.UserId)

        -- CD
        table.insert(cooldownList, code)
        world:set(player.UserId, components.CooldownList, cooldownList)
        task.delay(ability.CooldownDuration, function()
            table.remove(cooldownList, table.find(cooldownList, code))
            world:set(player.UserId, components.CooldownList, cooldownList)
        end)
    end
end)