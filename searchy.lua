local target = "minecraft:gold_ore"
local hello = "PokeyWuff"

local positioning = require("positioning")

local modem = peripheral.find("modem")

if modem == nil then error("Couldn't find a modem") end

local gpsAbsX, gpsAbsY, gpsAbsZ = gps.locate()

if gpsAbsX == nil then error("Could not get a GPS lock") end

positioning.setCurrentAbsPosition(gpsAbsX, gpsAbsY, gpsAbsZ)

modem.open(38956)

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

local foundRelX = nil
local foundRelY = nil
local foundRelZ = nil
local foundCost = nil

local function GoAfterPositiveZ()
    positioning.turnSouth()

    for goZ = 0, foundRelZ-1 do
        while turtle.detect() do
            turtle.dig()
            sleep(0.25)
        end

        positioning.forward()
        
        while turtle.detectUp() do
            turtle.digUp()
            sleep(0.25)
        end
    end
end

local function GoAfterNegativeZ()
    positioning.turnNorth()

    local positivefoundRelZ = foundRelZ - foundRelZ - foundRelZ

    for goZ = 0, positivefoundRelZ-1 do
        while turtle.detect() do
            turtle.dig()
            sleep(0.25)
        end

        positioning.forward()
        
        while turtle.detectUp() do
            turtle.digUp()
            sleep(0.25)
        end
    end
end

local function GoAfterPositiveX()
    positioning.turnEast()

    for goX = 0, foundRelX-1 do
        while turtle.detect() do
            turtle.dig()
            sleep(0.25)
        end

        positioning.forward()
        
        while turtle.detectUp() do
            turtle.digUp()
            sleep(0.25)
        end
    end
end

local function GoAfterNegativeX()
    positioning.turnWest()

    local positivefoundRelX = foundRelX - foundRelX - foundRelX

    for goX = 0, positivefoundRelX-1 do
        while turtle.detect() do
            turtle.dig()
            sleep(0.25)
        end

        positioning.forward()
        
        while turtle.detectUp() do
            turtle.digUp()
            sleep(0.25)
        end
    end

    --positioning.turnSouth()
end

local function GoAfterPositiveY()
    for goY = 0, foundRelY-1 do
        while turtle.detectUp() do
            turtle.digUp()
            sleep(0.25)
        end

        positioning.up()
        
        while turtle.detectUp() do
            turtle.digUp()
            sleep(0.25)
        end
    end
end

local function GoAfterNegativeY()
    local positivefoundRelY = foundRelY - foundRelY - foundRelY

    for goY = 0, positivefoundRelY-1 do
        while turtle.detectDown() do
            turtle.digDown()
            sleep(0.25)
        end

        positioning.down()
    end
end

local function GoAfterBlock()
    --Switch to Pickaxe
    turtle.select(16)
    turtle.equipRight()

    --We must always return to south

    if foundRelY >= 1 then
        GoAfterPositiveY()
    elseif foundRelY < 0 then
        GoAfterNegativeY()
    end

    if foundRelZ >= 1 then
        GoAfterPositiveZ()
    elseif foundRelZ < 0 then
        GoAfterNegativeZ()
    end

    if foundRelX >= 1 then
        GoAfterPositiveX()
    elseif foundRelX < 0 then
        GoAfterNegativeX()
    end

    --Switch to Scanner
    turtle.select(16)
    turtle.equipRight()
end

local function MoveOn()
    --Switch to Pickaxe
    turtle.select(16)
    turtle.equipRight()
    
    for i = 1, scannerAccuracy do
        turtle.dig()
        positioning.forward()
        turtle.digUp()
    end

    --Switch to Scanner
    turtle.select(16)
    turtle.equipRight()
end

print("Starting search for "..target.."...")

while true do
    print("Scanning...")

    local results = scanner.scan()

    print("Scan complete!")

    for index, block in pairs(results) do
        if block.name == target then
            if foundRelX ~= nil then
                --We already found a target, but we will now check if this target is closer
                local newTargetCost = positioning.getRelMovementCost(block.x, block.y, block.z)

                if newTargetCost < foundCost then
                    --This target is closer, so we will select it
                    foundRelX = block.x
                    foundRelY = block.y
                    foundRelZ = block.z
                    foundCost = newTargetCost
                end
            else
                foundRelX = block.x
                foundRelY = block.y
                foundRelZ = block.z
                foundCost = positioning.getRelMovementCost(foundRelX, foundRelY, foundRelZ)
            end
        end
    end

    if foundRelX ~= nil then
        --Check GPS positioning is valid still
        local gpsAbsX, gpsAbsY, gpsAbsZ = gps.locate()

        if gpsAbsX ~= positioning.currentAbsX or gpsAbsY ~= positioning.currentAbsY or gpsAbsZ ~= positioning.currentAbsZ then error("GPS MISMATCH! Actual (X: "..gpsAbsX.." Y: "..gpsAbsY.." Z: "..gpsAbsZ..") Expected (X: "..positioning.currentAbsX.." Y: "..positioning.currentAbsY.." Z: "..positioning.currentAbsZ..")") end

        --Transmit intentions
        print("Found "..target.." at X: "..foundRelX.." Y: "..foundRelY.." Z: "..foundRelZ.." Cost: "..foundCost)

        modem.transmit(38957, 38956, { hello = hello, x = foundRelX, y = foundRelY, z = foundRelZ, cost = foundCost, absPos = { gps.locate() } })
        
        --Go to block's position
        GoAfterBlock()
        
        --Reset
        foundRelX = nil
        foundRelY = nil
        foundRelZ = nil
        foundCost = nil
    else
        --No block found, move on a bit and retry
        print("Nothing found, moving on!")
        MoveOn()
    end
end
