local rs = game:GetService("ReplicatedStorage")
local ts = game:GetService("TweenService")

local shared = rs:WaitForChild("Shared")
local assets = rs:WaitForChild("Assets")

local world = require(shared.world.world)
local components = require(shared.world.components)
local utils = require(shared.utils.utils)

local tween_info = TweenInfo.new(0.3, Enum.EasingStyle.Sine)
local disappear_queue: {[number]: thread} = {}

local function setModelVisible(model: Model, visible: boolean)
    for _, part in model:GetDescendants() do
        if part:IsA("BasePart") then
            ts:Create(
                part,
                tween_info,
                {Transparency = visible and 0 or 1}
            ):Play()
        end
    end
end

function createWeaponModel(entt, id, weapon)
    local weapon_name = world:get(weapon, components.Name)
    local asset = assets.Weapons:FindFirstChild(weapon_name)
    if not asset then return end

    local char = utils.getCharacterFromEntt(entt)
    local model: Model = asset:Clone()
    local grip = model:FindFirstChild("Grip")
    if not char or not grip then return end
    local old_weapon = char:FindFirstChild("Weapon")
    if old_weapon then old_weapon:Destroy() end

    local weld = Instance.new("Motor6D")
    weld.Part0 = char["Right Arm"]
    weld.Part1 = model.PrimaryPart
    weld.C1 = grip.Value
    weld.Parent = model

    model.Parent = char
    model.Name = "Weapon"
    setModelVisible(model, false)
end

world:added(components.Busy, function(entt)
    local char = utils.getCharacterFromEntt(entt)
    if not char then return end

    local model = char:FindFirstChild("Weapon")
    if not model then return end

    setModelVisible(model, true)

    if disappear_queue[entt] then
        task.cancel(disappear_queue[entt])
        disappear_queue[entt] = nil
    end
end)
world:removed(components.Busy, function(entt)
    local char = utils.getCharacterFromEntt(entt)
    if not char then return end

    local model = char:FindFirstChild("Weapon")
    if not model then return end

    if disappear_queue[entt] then
        task.cancel(disappear_queue[entt])
    end

    disappear_queue[entt] = task.delay(2, function()
        disappear_queue[entt] = nil
        setModelVisible(model, false)
    end)
end)

world:added(components.EquippedWeapon, createWeaponModel)
world:changed(components.EquippedWeapon, createWeaponModel)