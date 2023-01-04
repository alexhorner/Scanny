--Load config
local target = "minecraft:gold_ore"
local hello = "intendedclient"

--Load libraries
local positioning = require("positioning")
local searchy = require("searchytools")

--Initialise modem
local modem = peripheral.find("modem")

if modem == nil then error("Couldn't find a modem") end

modem.open(38956)

--Lock initial GPS position

local gpsAbsX, gpsAbsY, gpsAbsZ = gps.locate()

if gpsAbsX == nil then error("Could not get a GPS lock") end

positioning.setCurrentAbsPosition(gpsAbsX, gpsAbsY, gpsAbsZ)

--Obtain facing direction from user
print("First I need to get my bearings! I am at X: "..positioning.currentAbsX.." Y: "..positioning.currentAbsY.." and Z: "..positioning.currentAbsZ.." but am I facing [N]orth, [S]outh, [E]ast or [W]est?")

while true do
    local key = { os.pullEvent("key") }
    
    if key[2] == keys.n then
        print("Okay! I'm facing North!")
        print()
        positioning.setCurrentFacing(2)
        break;
    elseif key[2] == keys.s then
        print("Okay! I'm facing South!")
        print()
        positioning.setCurrentFacing(0)
        break;
    elseif key[2] == keys.e then
        print("Okay! I'm facing East!")
        print()
        positioning.setCurrentFacing(3)
        break;
    elseif key[2] == keys.w then
        print("Okay! I'm facing West!")
        print()
        positioning.setCurrentFacing(1)
        break;
    end
end

print("Facing: "..positioning.facing)

--Set up Block Scanner and Pickaxe
print("Place Pickaxe or Scanner in slot 16, and then press enter...")

while true do
    local key = { os.pullEvent("key") }
    
    if key[2] == keys.enter then break end
end

local scanner = peripheral.wrap("right")

if scanner == nil then
    --Pickaxe is equipped, swap
    turtle.select(16)
    turtle.equipRight()
    scanner = peripheral.wrap("right")
end

local scannerAccuracy = 8

--Run Searchy!
print("Starting search for "..target.."...")

while true do
    print("Scanning...")

    local results = scanner.scan()

    print("Scan complete!")

    local foundRelX, foundRelY, foundRelZ, foundCost = searchy.selectClosestTarget(results, target)

    if foundRelX ~= nil then
        --Transmit intentions
        print("Found "..target.." at X: "..foundRelX.." Y: "..foundRelY.." Z: "..foundRelZ.." Cost: "..foundCost)

        modem.transmit(38957, 38956, { hello = hello, x = foundRelX, y = foundRelY, z = foundRelZ, cost = foundCost, absPos = { positioning.currentAbsX, positioning.currentAbsY, positioning.currentAbsZ } })
        
        --Go to block's position
        searchy.GoAfterRelBlock(foundRelX, foundRelY, foundRelZ)
    else
        --No block found, move on a bit and retry
        print("Nothing found, moving on!")
        searchy.MoveOn(scannerAccuracy)
    end
end