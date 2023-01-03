local modem = peripheral.find("modem")

modem.open(38957)

while true do
    local event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")
    
    if type(message) == "table" and message.hello == "PokeyWuff" then
        print("X: "..message.x.." Y: "..message.y.." Z: "..message.z.." Cost: "..message.cost)
        print()
        print("GPS: X: "..message.absPos[1].." Y: "..message.absPos[2].." Z: "..message.absPos[3])
        print()
    end
end
