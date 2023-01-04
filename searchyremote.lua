--Load config
local port = 54256
local targetPort = 38956
local psk = "vnFwJSkhkR9o967o4ejyWgumoE92fDqWMMQVWKYXMteoprBBNFanFpfoWD3PEgnQcrEa2N6aAYRioyzw8fjFLcqaLamRuYHaN94mQK79kgKj9GPZ23cVGFdp5EpE3gHt" --TODO this should be changed!

--Load libraries
local signing = require("searchysigning")

--Initialise modem
local modem = peripheral.find("modem")
if modem == nil then error("Couldn't find a modem") end
modem.open(port)

local function handleResponses()
    while true do
        local event, side, incomingChannel, replyChannel, message, distance = os.pullEvent("modem_message")

        if incomingChannel == port and type(message) == "table" and message.command and message.id and message.signature and signing.checkSignature(message) then
            print(textutils.serialise(message))
            os.queueEvent("searchy_response")
        elseif incomingChannel == port then
            print("REJECT")
            print()
            print(textutils.serialise(message))
        end
    end
end

local function handleUserInput()
    while true do
        term.write("> ")
        local input = read()

        local command = nil
        local expectResponse = false
    
        if input == "pos" then
            command = {
                id = math.random(0, 1000000),
                command = "getPosition"
            }

            expectResponse = true
        elseif input == "pause" then
            command = {
                id = math.random(0, 1000000),
                command = "pause"
            }
        end

        if command then
            command.signature = signing.calculateSignature(psk, command)
    
            modem.transmit(targetPort, port, command)

            if expectResponse then
                os.pullEvent("searchy_response")
            end

            command = nil
            expectResponse = false
        end
    end
end

parallel.waitForAll(handleResponses, handleUserInput)