
local rs = game:GetService("ReplicatedStorage")
local remotes = rs:WaitForChild("Remotes")

remotes.Vfx.OnClientEvent:Connect(function(asset : Model | BasePart, cframe : CFrame, duration: number)
    if not asset:IsA("BasePart") then return end

    local vfx = asset:Clone()
    vfx.Parent = workspace.Visual
    vfx.CFrame = cframe
    
    for _, particle in vfx:GetDescendants() do
        if not particle:IsA("ParticleEmitter") then continue end
        task.delay(particle:GetAttribute("EmitDelay"), particle.Emit, particle, particle:GetAttribute("EmitCount"))
    end

    task.delay(duration, vfx.Destroy, vfx)
end)