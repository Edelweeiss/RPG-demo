local rs = game:GetService("ReplicatedStorage")

local shared = rs:WaitForChild("Shared")
-- local assets = rs:WaitForChild("Assets")
-- local remotes = rs:WaitForChild("Remotes")

local world = require(shared.world.world)
local components = require(shared.world.components)
local utils = require(shared.utils.utils)

-- local vfx = assets.Vfx

world:added(components.Effects.Stun, function(entity, id, duration)
    local char = utils.getCharacterFromEntt(entity)
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local originalSpeed = hum.WalkSpeed
    local originalJump = hum.JumpPower

    hum.WalkSpeed = 0
    hum.JumpPower = 0

    world:add(entity, components.Busy)
    world:add(entity, components.CancelAtk)

    task.delay(duration, function()
        world:remove(entity, components.Effects.Stun)
        world:remove(entity, components.Busy)

        hum.WalkSpeed = originalSpeed
        hum.JumpPower = originalJump
    end)
end)

world:added(components.Effects.Knockback, function(entity, id, data)
    local char = utils.getCharacterFromEntt(entity)
    if not char then return end
    local rootPart = char:FindFirstChild("HumanoidRootPart")

    local linearVel = Instance.new("LinearVelocity")
    linearVel.Attachment0 = rootPart:FindFirstChildOfClass("Attachment")
    linearVel.MaxForce = math.huge
    linearVel.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
    linearVel.RelativeTo = Enum.ActuatorRelativeTo.World
    linearVel.VectorVelocity = data.vel
    linearVel.Parent = rootPart

    task.delay(data.duration, function()
        world:remove(entity, components.Effects.Knockback)
        linearVel:Destroy()
    end)
end)

-- TODO
world:added(components.Effects.Bleed, function(entity, id, duration)
    task.delay(duration, world.remove, world, entity, components.Effects.Bleed)
end)


---RAGDOLLL---
local function enableMotor6D(char: Model, enabled: boolean)
    local excluded = {"Handle", "RootJoint", "Neck"}

    for _,v in char:GetDescendants() do
        if table.find(excluded, v.Name) then continue end
        if v:IsA("Motor6D") then v.Enabled = enabled end
    end
end

-- OFFSETS from <https://pastebin.com/UPSBgNNs>
local LIMBS = {"Head", "Torso", "Left Arm", "Left Leg", "Right Arm", "Right Leg"}
local OFFSETS = {
    Head = {
        CFrame = {CFrame.new(0, 1, 0, 0, -1, 0, 1, 0, -0, 0, 0, 1), CFrame.new(0, -0.5, 0, 0, -1, 0, 1, 0, -0, 0, 0, 1)}
    },
    Torso = {
        CFrame = {CFrame.new(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0), CFrame.new(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)}
    },
    ["Right Arm"] = {
        CFrame = {CFrame.new(1.3, 0.75, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1), CFrame.new(-0.2, 0.75, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)}
    },
    ["Left Arm"] = {
        CFrame = {CFrame.new(-1.3, 0.75, 0, -1, 0, 0, 0, -1, 0, 0, 0, 1), CFrame.new(0.2, 0.75, 0, -1, 0, 0, 0, -1, 0, 0, 0, 1)}
    },
    ["Right Leg"] = {
        CFrame = {CFrame.new(0.5, -1, 0, 0, 1, -0, -1, 0, 0, 0, 0, 1), CFrame.new(0, 1, 0, 0, 1, -0, -1, 0, 0, 0, 0, 1)}
    },
    ["Left Leg"] = {
        CFrame = {CFrame.new(-0.5, -1, 0, 0, 1, -0, -1, 0, 0, 0, 0, 1), CFrame.new(0, 1, 0, 0, 1, -0, -1, 0, 0, 0, 0, 1)}
    }
}

world:added(components.Effects.Ragdoll, function(entity, id, duration)
    local char = utils.getCharacterFromEntt(entity)
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = hum.RootPart

    for _,track in hum.Animator:GetPlayingAnimationTracks() do
        track:Stop()
    end
    local animPlayed = hum.Animator.AnimationPlayed:Connect(function(track)
        track:Stop()
    end)

    enableMotor6D(char, false)
    hum:ChangeState(Enum.HumanoidStateType.Physics)

    for _, limbName in LIMBS do
        local a0, a1 = Instance.new("Attachment"), Instance.new("Attachment")
        local limb: BasePart = char:FindFirstChild(limbName)
        local joint = Instance.new("BallSocketConstraint")

        a0.Name = "RA_ATTACHMENT"
        a0.CFrame = OFFSETS[limbName].CFrame[2]
        a0.Parent = limb

        a1.Name = "RA_ATTACHMENT"
        a1.CFrame = OFFSETS[limbName].CFrame[1]
        a1.Parent = hrp

		joint.Name = "RA_JOINT"
		joint.Attachment0 = a0
		joint.Attachment1 = a1
		joint.Parent = limb

        limb.Massless = true
        local fakeLimb = limb:FindFirstChild("FakeLimb")
        if fakeLimb then fakeLimb.CanCollide = true end
    end

    hum.AutoRotate = false
    hum.PlatformStand = true

    task.delay(duration, function()
        animPlayed:Disconnect()
        world:remove(entity, components.Effects.Ragdoll)
    end)
end)

world:removed(components.Effects.Ragdoll, function(entity, id, duration)
    local char = utils.getCharacterFromEntt(entity)
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = hum.RootPart

    if hum:GetState() == Enum.HumanoidStateType.Dead then return end
    hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
    hum:ChangeState(Enum.HumanoidStateType.GettingUp)

    for _, limbName in LIMBS do
        local limb = char:FindFirstChild(limbName)

        for _, ra in limb:GetChildren() do
            if ra.Name == "RA_JOINT" or ra.Name == "RA_ATTACHMENT" then ra:Destroy() end
        end
        for _, ra in hrp:GetChildren() do
            if ra.Name == "RA_ATTACHMENT" then ra:Destroy() end
        end

        limb.Massless = false
        local fakeLimb = limb:FindFirstChild("FakeLimb")
        if fakeLimb then fakeLimb.CanCollide = false end
    end

    enableMotor6D(char, true)
    hum.AutoRotate = true
    hum.PlatformStand = false
end)