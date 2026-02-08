local signal_lib = require("./utils/lemon_signal")
local world = require("./world/world")
local components = require("./world/components")

return {
    ["Aura Teacher (3-STAR)"] = {
        [1] = {
            text = "What do you want?",
            options = {
                [1] = {
                    text = "Teach me",
                    next = 2
                },
                [2] = {
                    text = "Nvm",
                    next = -1
                }
            }
        },
        [2] = {
            text = "So you too want to learn aura huh?\nI can only create the first star for you.",
            options = {
                [1] = {
                    text = "Please do",
                    next = 3
                },
                [2] = {
                    text = "Nvm",
                    next = -1
                }
            }
        },
        [3] = {
            text = "Alright lets start!\n...\nIts done! Congratulations on becoming a 1-star aura user!",
            next = -1,
            signal = signal_lib.new()
        },
        [4] = {
            text = "I have already taught you what I could.",
            next = -1
        },

        EndSignal = signal_lib.new(),
        StartNode = function(entt) : number
            local stars = world:get(entt, components.Stars)
            if stars ~= 0 then return 4 else return 1 end
        end
    }
}