local rs = game:GetService("ReplicatedStorage")
local ts = game:GetService("TweenService")
local shared = rs:WaitForChild("Shared")

local world = require(shared.world.world)
local components = require(shared.world.components)
local dialogueMap = require(shared.dialougeMap)
local text_plus = require(shared.utils.Text_plus.Text_plus)

local TWEEN_FRAME_OFFSET = UDim2.fromOffset(0, 500)

local function optionCallback(entt, next, dialogue_frame)
    world:set(entt, components.ActiveDialogue, next)
    if next ~= -1 then return end

    local tween = ts:Create(dialogue_frame, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.In),{
        Position = dialogue_frame.Position + TWEEN_FRAME_OFFSET
    })
    tween:Play()
    tween.Completed:Once(function()
        dialogue_frame.Visible = false
        dialogue_frame.Position -= TWEEN_FRAME_OFFSET
    end)
end

local function nextDialogue(data, node, entt, ctx: components.DialogueContext_t)
    local node_data = data[node]
    if not node_data then return end

    local listner_gui = ctx.listner.PlayerGui:WaitForChild("Main")
    if not listner_gui then return end
    local dialogue_frame = listner_gui.Dialogue

    for _,btn in dialogue_frame.OptionsFrame:GetChildren() do
        if not btn:IsA("GuiButton") or btn == dialogue_frame.OptionsFrame.Temp then continue end
        btn:Destroy()
    end

    if not dialogue_frame.Visible then
        dialogue_frame.Visible = true
        dialogue_frame.Position += TWEEN_FRAME_OFFSET
        local tween = ts:Create(dialogue_frame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),{
            Position = dialogue_frame.Position - TWEEN_FRAME_OFFSET
        })
        tween:Play()
        tween.Completed:Wait()
    end

    local text_size = 24
    text_plus.Create(
        dialogue_frame.TextFrame,
        node_data.text,
        {
            Size = text_size,
            Color = Color3.fromRGB(255,255,255),
            Transparency = 1,
            Offset = Vector2.new(0, text_size*0.25),
            WordSorting = true
        }
    )

    for _, character in text_plus.GetCharacters(dialogue_frame.TextFrame) do
        ts:Create(character, TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
            Position = character.Position - UDim2.new(0, text_size*0.25),
            TextTransparency = 0
        }):Play()
        task.wait(0.03)
    end

    local options = node_data.options or {}
    if node_data.next then table.insert(options, {text = "...", next = node_data.next}) end
    for _,option in options do
        local btn = dialogue_frame.OptionsFrame.Temp:Clone()
        btn.Name = option.text
        btn.Text = option.text
        btn.Visible = true
        btn.Parent = dialogue_frame.OptionsFrame

        btn.MouseButton1Click:Connect(function()
            optionCallback(entt, option.next, dialogue_frame)
            if option.signal then option.signal:Fire() end
            if node_data.signal then node_data.signal:Fire() end
        end)
    end
end

world:changed(components.ActiveDialogue, function(entt, id, value)
    if value == -1 then
        world:delete(entt)
        return
    end

    local context = world:get(entt, components.DialogueContext)
    nextDialogue(dialogueMap[context.speaker], value, entt, context)
end)

world:added(components.DialogueContext, function(entt, id, context)
    local data = dialogueMap[context.speaker]
    if not data then return end

    nextDialogue(data, world:get(entt, components.ActiveDialogue), entt, context)
end)