--Load config
local target = "minecraft:gold_ore"
local hello = "intendedclient"
local port = 38956
local psk = "vnFwJSkhkR9o967o4ejyWgumoE92fDqWMMQVWKYXMteoprBBNFanFpfoWD3PEgnQcrEa2N6aAYRioyzw8fjFLcqaLamRuYHaN94mQK79kgKj9GPZ23cVGFdp5EpE3gHt" --TODO this should be changed!

--Load libraries
local positioning = require("positioning")
local searchy = require("searchytools")

--Initialise modem
local modem = peripheral.find("modem")
if modem == nil then error("Couldn't find a modem") end
modem.open(port)

--Set up local positioning using GPS and movement based autocalculations
print("Automatically obtaining GPS lock and compass heading...")
positioning.autoSetup()

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
local subroutine = nil

local function searchyRoutine()
    print("Starting search for "..target.."...")

    while true do
        if subroutine ~= nil then
            subroutine()
            subroutine = nil
        end

        print("Scanning...")

        local results = scanner.scan()

        print("Scan complete!")

        local foundRelX, foundRelY, foundRelZ, foundCost = searchy.selectClosestTarget(results, target)

        if foundRelX ~= nil then
            --Transmit intentions
            print("Found "..target.." at X: "..foundRelX.." Y: "..foundRelY.." Z: "..foundRelZ.." Cost: "..foundCost)

            --modem.transmit(38957, 38956, { hello = hello, x = foundRelX, y = foundRelY, z = foundRelZ, cost = foundCost, absPos = { positioning.currentAbsX, positioning.currentAbsY, positioning.currentAbsZ } })
            
            --Go to block's position
            searchy.goAfterRelBlock(foundRelX, foundRelY, foundRelZ)
        else
            --No block found, move on a bit and retry
            print("Nothing found, moving on!")
            searchy.moveOn(scannerAccuracy)
        end
    end
end

local function listenRoutine()
    searchy.remoteListen(modem, port, psk)
end

parallel.waitForAll(listenRoutine, searchyRoutine)