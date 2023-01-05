local positioning = require("positioning")

local lib = {}
local commands = {}
local sendIntermediary = function(data) end

--All commands must return a table as a response, or a function to run to get the response
--If a function is returned, it will be tun on the main thread, which means it will only be run once Searchy has finished doing its current task
--Commands can send partial information using the intermediaryFunction, which must also be a table
--Commands may take the original command as their single parameter, or may ignore it

function lib.processCommand(command)
    local targetCommand = commands[command.command]

    if targetCommand then
        return targetCommand(command)
    end
end

function lib.setIntermediarySender(newIntermediarySender)
    sendIntermediary = newIntermediarySender
end

function commands.getPosition()
    return {
        x = positioning.currentAbsX,
        y = positioning.currentAbsY,
        z = positioning.currentAbsZ,
        heading = positioning.heading
    }
end

function commands.pause()
    local function subroutine()
        local inter = commands.getPosition()
        inter.message = "Searchy is now paused. This command will complete when the user presses a key on the turtle..."
        sendIntermediary(inter)

        os.pullEvent("key")
        return { message = "User has unpaused searchy" }
    end

    sendIntermediary({ message = "Please wait, searchy is pausing..." })
    return subroutine
end

return lib