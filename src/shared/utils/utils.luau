function getEnttFromCharacter(char: Model)
    local player = game.Players:GetPlayerFromCharacter(char)
    if player then return player.UserId end
    
    local id = char:FindFirstChild("id")
    if not id then return nil end

    return id.Value
end

local function getCharacterFromEntt(entity)
    local char = nil
    local plr = game.Players:GetPlayerByUserId(entity)
    if plr then
        char = plr.Character
    else
        local characters = {}
        table.insert(characters, table.unpack(workspace.Enemies:GetChildren()))
        table.insert(characters, table.unpack(workspace["NPC's"]:GetChildren()))
        for _, character in characters do
            local _id = character:FindFirstChild("id")
            if not _id then continue end
            if _id.Value == entity then
                char = character
                break
            end
        end
    end

    return char
end

function findAnimationTrack(animator: Animator, name: string) : AnimationTrack?
    for _, track in animator:GetPlayingAnimationTracks() do
        if track.Name == name then return track end
    end

    return nil
end

function createLimbCollidors(char: Model)
    local hum = char:FindFirstChildOfClass("Humanoid")
    hum.BreakJointsOnDeath = false
    hum.RequiresNeck = false

    for _,v in char:GetChildren() do
        if not v:IsA("BasePart") or v == hum.RootPart then return end
        local fakeLimb = Instance.fromExisting(v)
        fakeLimb.CanCollide = false
        fakeLimb.CanTouch = false
        fakeLimb.CanQuery = false
        fakeLimb.Massless = true
        fakeLimb.Size = Vector3.one
        fakeLimb.Transparency = 1
        fakeLimb.Name = "FakeLimb"
        fakeLimb:ClearAllChildren()
        fakeLimb.Parent = v

        local weld = Instance.new("Weld")
        weld.Part0 = v
        weld.Part1 = fakeLimb
        weld.Parent = fakeLimb
    end
end

return {
    getEnttFromCharacter = getEnttFromCharacter,
    getCharacterFromEntt = getCharacterFromEntt,
    findAnimationTrack = findAnimationTrack,
    createLimbCollidors = createLimbCollidors
}