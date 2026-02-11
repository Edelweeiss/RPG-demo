local rs = game:GetService("ReplicatedStorage")
local rns = game:GetService("RunService")
local players = game:GetService("Players")

local shared = rs:WaitForChild("Shared")
-- local assets = rs:WaitForChild("Assets")

local world = require(shared.world.world)
local components = require(shared.world.components)
local utils = require(shared.utils.utils)
local m1 = require(shared.abilities.M1)

local connections = {}
local playersCache = {}

local function stateChange(entt, from, to)
    if connections[entt] then
        connections[entt]:Disconnect()
        connections[entt] = nil
    end

    world:remove(entt, from)
    world:add(entt, to)
end

players.PlayerAdded:Connect(function(player)
    table.insert(playersCache, player)
end)
players.PlayerRemoving:Connect(function(player)
    table.remove(playersCache, table.find(playersCache, player))
end)

world:added(components.Idle, function(entt, id)
    local char = utils.getCharacterFromEntt(entt)
    if not char then return end
    
    local chaseRadius = world:get(entt, components.ChaseRadius)
    if not chaseRadius then return end

    connections[entt] = rns.Heartbeat:Connect(function()
        for _,player in playersCache do
            if not player then continue end
            local plrChar = player.Character
            if not plrChar then continue end

            if (char.PrimaryPart.Position - plrChar.PrimaryPart.Position).Magnitude <= chaseRadius then
                world:set(entt, components.MoveToTarget, plrChar.PrimaryPart)
                stateChange(entt, components.Idle, components.Chase)
            end
        end
    end)
end)

world:added(components.Chase, function(entt, id)
    local char = utils.getCharacterFromEntt(entt)
    if not char then return end
    local hum: Humanoid = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    local chaseRadius = world:get(entt, components.ChaseRadius)
    local attackRadius = world:get(entt, components.AttackRadius)
    if not chaseRadius or not attackRadius then return end

    local target = world:get(entt, components.MoveToTarget)
    connections[entt] = rns.Heartbeat:Connect(function()
        if not target then
            stateChange(entt, components.Chase, components.Idle)
        end
        local distance = (char.PrimaryPart.Position - target.Position).Magnitude

        hum:MoveTo(target.Position)
        if distance <= attackRadius then
            stateChange(entt, components.Chase, components.Attack)
        elseif distance > chaseRadius then
            stateChange(entt, components.Chase, components.Idle)
        end
    end)
end)

world:added(components.Attack, function(entt, id)
    local char = utils.getCharacterFromEntt(entt)
    if not char then return end

    local weapon = world:get(entt, components.EquippedWeapon)
    if not weapon then return end

    local signal = m1.Begin(char, entt)
    if signal then signal:Wait() end
    local target = world:get(entt, components.MoveToTarget)
    if not target then
        stateChange(entt, components.Attack, components.Idle)
    else
        local targetHum = target.Parent:FindFirstChildOfClass("Humanoid")
        if targetHum.Health <= 0 then
            stateChange(entt, components.Attack, components.Idle)
            return
        end

        stateChange(entt, components.Attack, components.Chase)
    end
end)