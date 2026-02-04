local uis = game:GetService("UserInputService")
local rs = game:GetService("ReplicatedStorage")

local remotes = rs:WaitForChild("Remotes")
local inputRemote = remotes.Input

local shared = rs:WaitForChild("Shared")
local inputMap = require(shared.inputMap)

uis.InputBegan:Connect(function(input, gpe)
    if gpe then return end

    local map = inputMap[input.UserInputType]
    if not map then return end

    local code = map[input.KeyCode]
    if not code then return end

    inputRemote:FireServer(code, true)
end)

uis.InputEnded:Connect(function(input, gpe)
    local map = inputMap[input.UserInputType]
    if not map then return end

    local code = map[input.KeyCode]
    if not code then return end

    inputRemote:FireServer(code, false)
end)
