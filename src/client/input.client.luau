local uis = game:GetService("UserInputService")
local rs = game:GetService("ReplicatedStorage")
local rns = game:GetService("RunService")

local remotes = rs:WaitForChild("Remotes")
local inputRemote = remotes.Input

local shared = rs:WaitForChild("Shared")
local inputMap = require(shared.inputMap)

local FIXED_INPUT_DELAY = 4
local MAX_BUFFER_LEN = 8
local inputBuffer = {}

function handleInput(input : InputObject)
    if #inputBuffer >= MAX_BUFFER_LEN then return end

    local map = inputMap[input.UserInputType]
    if not map then return end

    local code = map[input.KeyCode]
    if not code then return end

    if input.UserInputState == Enum.UserInputState.Begin then
        table.insert(inputBuffer, {code = code, begin = true})
    elseif input.UserInputState == Enum.UserInputState.End then
        table.insert(inputBuffer, {code = code, begin = false})
    end
end

local frame = 0
rns.Heartbeat:Connect(function()
    frame += 1
    if frame < FIXED_INPUT_DELAY or #inputBuffer == 0 then return end
    inputRemote:FireServer(inputBuffer)
    table.clear(inputBuffer)
    frame = 0
end)

uis.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    handleInput(input)
end)

uis.InputEnded:Connect(function(input, gpe)
    handleInput(input)
end)
