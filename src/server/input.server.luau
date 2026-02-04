local rs = game:GetService("ReplicatedStorage")

local remotes = rs:WaitForChild("Remotes")
local inputRemote : RemoteEvent = remotes.Input

local shared = rs:WaitForChild("Shared")
local abilities = shared.abilities

--TODO: checks & cd
inputRemote.OnServerEvent:Connect(function(player, code, began : boolean)
    local char = player.Character or player.CharacterAdded:Wait()
    if not char or not abilities:FindFirstChild(code) then return end

    local ability = require(abilities[code])
    if began then
        ability.Begin(player)
    else
        ability.End(player)
    end
end)