local signal_lib = require("./utils/lemon_signal")

return {
    ["Test"] = {
        [1] = {
            text = "bla bla bla",
            options = {
                [1] = {
                    text = "huh?",
                    next = 2
                },
                [2] = {
                    text = "what?",
                    next = 2
                }
            }
        },
        [2] = {
            text = "bla bla bla 2",
            next = -1,
            signal = signal_lib.new()
        }
    }
}