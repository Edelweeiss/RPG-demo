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
        for _, character in workspace.Enemies:GetChildren() do
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

return {
    getEnttFromCharacter = getEnttFromCharacter,
    getCharacterFromEntt = getCharacterFromEntt,
    findAnimationTrack = findAnimationTrack
}