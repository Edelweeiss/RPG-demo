local rs = game:GetService("ReplicatedStorage")

local pkgs = rs:WaitForChild("pkgs")
local jecs = require(pkgs.jecs)

return jecs.world()