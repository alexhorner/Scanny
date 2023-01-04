local positioning = require("positioning")

local lib = {}
local commands = {}

function lib.processCommand(command)
    local targetCommand = commands[command.command]

    if targetCommand then
        return targetCommand(command)
    end
end

function commands.getPosition(command)
    return {
        x = positioning.currentAbsX,
        y = positioning.currentAbsY,
        z = positioning.currentAbsZ,
        heading = positioning.heading
    }
end

function commands.pause(command)
    os.pullEvent("key")
    return nil
end

return lib