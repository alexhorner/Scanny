--Load config
local port = 54256
local targetPort = 38956
local psk = "vnFwJSkhkR9o967o4ejyWgumoE92fDqWMMQVWKYXMteoprBBNFanFpfoWD3PEgnQcrEa2N6aAYRioyzw8fjFLcqaLamRuYHaN94mQK79kgKj9GPZ23cVGFdp5EpE3gHt" --TODO this should be changed!

--Load libraries
local protective = require("protectivemessaging")

--Initialise modem
local modem = peripheral.find("modem")
if modem == nil then error("Couldn't find a modem") end
modem.open(port)

local function handleResponses()
    while true do
        local event, side, incomingChannel, replyChannel, message, distance = os.pullEvent("modem_message")

        if incomingChannel == port and type(message) == "table" then
            local unprotected = protective.unprotect(psk, message)

            if unprotected then
                print(textutils.serialise(message))

                if message.command == "response" then
                    os.queueEvent("searchy_response")
                end
            end
        end
    end
end

local function handleUserInput()
    while true do
        term.write("> ")
        local input = read()

        local command = nil
    
        if input == "pos" then
            command = {
                command = "getPosition"
            }
        elseif input == "pause" then
            command = {
                command = "pause"
            }
        elseif input == "summon" then
            local posX, posY, posZ = gps.locate()

            if not posX then
                print("Unable to locate current position")
            else
                command = {
                    command = "summon",
                    posX = posX,
                    posY = posY,
                    posZ = posZ
                }
            end
        end

        if command then
            protective.protect(psk, command)
    
            modem.transmit(targetPort, port, command)

            os.pullEvent("searchy_response")
        end
    end
end

--Run remote
parallel.waitForAll(handleResponses, handleUserInput)