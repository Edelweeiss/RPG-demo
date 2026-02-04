local rs = game:GetService("ReplicatedStorage")

local shared = rs:WaitForChild("Shared")
local world = require(shared.world.world)
local components = require(shared.world.components)

local function spawn(char: Model, size: Vector3, cframe: CFrame, exclude: {}, effects: {}, visual: boolean)
    local params = OverlapParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = exclude

    if visual then
        local part = Instance.new("Part")
        part.Parent = workspace.Visual
        part.CFrame = cframe
        part.Size = size
        part.Transparency = 0.8
        part.Color = Color3.new(1, 0.266667, 0.266667)
        part.Material = Enum.Material.SmoothPlastic
        part.Anchored = true
        part.CanCollide = false

        task.delay(0.2, part.Destroy, part)
    end

    local recvParts = workspace:GetPartBoundsInBox(cframe, size, params)
    for _, part in recvParts do
        local eChar = part.Parent
        local eHum = eChar:FindFirstChildOfClass("Humanoid")
        local enemyEntt = eChar:FindFirstChild("id")
        if not eHum or not enemyEntt then continue end

        -- sends it off to the hit_system
        local ticket: components.HitTicket = {
            issuer = char,
            target = eChar,
            damage = 1,
            effects = effects
        }
        local hitbox = world:entity()
        world:set(hitbox, components.HitTicket, ticket)

        -- cancel atk if we can
        world:add(enemyEntt.Value, components.CancelAtk)
        break
    end
end

return {
    spawn = spawn
}