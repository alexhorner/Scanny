local lib = {}

lib.heading = 0 --0 is +Z South
lib.currentAbsX = 0
lib.currentAbsY = 0
lib.currentAbsZ = 0

lib.headingDirections = {
    north = 2, -- Negative Z
    east = 3, -- Positive X
    south = 0, -- Positive Z
    west = 1 -- Negative X
}

function lib.setCurrentAbsPosition(x, y, z)
    if z == nil or y == nil or z == nil then error("X, Y or Z was nil") end

    lib.currentAbsX = x
    lib.currentAbsY = y
    lib.currentAbsZ = z
end

function lib.setCurrentheading(currentheading)
    lib.heading = currentheading
end

function lib.autoSetup()
    --Ensure the face of the turtle is clear for movement for compass heading detection
    while turtle.detect() do
        turtle.dig()
        sleep(0.25)
    end

    --Get two locks to autocalculate our compass heading
    local currentPositionX, currentPositionY, currentPositionZ = gps.locate()
    if currentPositionX == nil then error("Couldn't get a GPS lock") end
    turtle.forward()

    local newPositionX, newPositionY, newPositionZ = gps.locate()
    turtle.back()
    if newPositionX == nil then error("Couldn't get a GPS lock") end

    --Set our coordinates
    lib.setCurrentAbsPosition(currentPositionX, currentPositionY, currentPositionZ)

    --Calculate heading
    if currentPositionX ~= newPositionX then
        --Heading is on the X axis
        if currentPositionX < newPositionX then
            --We went up the X axis, so +X which is East
            lib.setCurrentheading(lib.headingDirections.east)
        else
            --We went down the X axis, so -X which is West
            lib.setCurrentheading(lib.headingDirections.west)
        end
    elseif currentPositionZ ~= newPositionZ then
        --Heading is on the Z axis
        if currentPositionZ < newPositionZ then
            --We went up the Z axis, so +Z which is South
            lib.setCurrentheading(lib.headingDirections.south)
        else
            --We went down the Z axis, so -Z which is North
            lib.setCurrentheading(lib.headingDirections.north)
        end
    else
        --Minecraft is very broken
        error("Heading calculations are invalid. Couldn't autodetect heading")
    end
end

function lib.getRelMovementCost(x, y, z)
    if x < 0 then
        x = x - x - y
    end

    if y < 0 then
        y = y - y - y
    end

    if z < 0 then
        z = z - z - z
    end

    return x + y + z
end

function lib.turnLeft()
    turtle.turnLeft()

    if lib.heading == lib.headingDirections.south then
        lib.heading = lib.headingDirections.east
    else
        lib.heading = lib.heading - 1
    end
end

function lib.turnRight()
    turtle.turnRight()

    if lib.heading == lib.headingDirections.east then
        lib.heading = lib.headingDirections.south
    else
        lib.heading = lib.heading + 1
    end
end

function lib.turnSouth()
    while lib.heading ~= lib.headingDirections.south do
        if lib.heading == lib.headingDirections.east then
            lib.turnRight()
        else
            lib.turnLeft()
        end
    end
end

function lib.turnWest()
    while lib.heading ~= lib.headingDirections.west do
        if lib.heading == lib.headingDirections.south then
            lib.turnRight()
        else
            lib.turnLeft()
        end
    end
end

function lib.turnNorth()
    while lib.heading ~= lib.headingDirections.north do
        if lib.heading == lib.headingDirections.west then
            lib.turnRight()
        else
            lib.turnLeft()
        end
    end
end

function lib.turnEast()
    while lib.heading ~= lib.headingDirections.east do
        if lib.heading == lib.headingDirections.north then
            lib.turnRight()
        else
            lib.turnLeft()
        end
    end
end

function lib.forward()
    turtle.forward()

    if lib.heading == lib.headingDirections.north then
        lib.currentAbsZ = lib.currentAbsZ - 1
    elseif lib.heading == lib.headingDirections.south then
        lib.currentAbsZ = lib.currentAbsZ + 1
    elseif lib.heading == lib.headingDirections.east then
        lib.currentAbsX = lib.currentAbsX + 1
    elseif lib.heading == lib.headingDirections.west then
        lib.currentAbsX = lib.currentAbsX - 1
    else
        error("Lost track of lib.heading direction. Direction "..lib.heading.." is invalid")
    end
end

function lib.back()
    turtle.back()

    if lib.heading == lib.headingDirections.north then
        lib.currentAbsZ = lib.currentAbsZ + 1
    elseif lib.heading == lib.headingDirections.south then
        lib.currentAbsZ = lib.currentAbsZ - 1
    elseif lib.heading == lib.headingDirections.east then
        lib.currentAbsX = lib.currentAbsX - 1
    elseif lib.heading == lib.headingDirections.west then
        lib.currentAbsX = lib.currentAbsX + 1
    else
        error("Lost track of lib.heading direction. Direction "..lib.heading.." is invalid")
    end
end

function lib.up()
    turtle.up()

    lib.currentAbsY = lib.currentAbsY + 1
end

function lib.down()
    turtle.down()

    lib.currentAbsY = lib.currentAbsY - 1
end

return lib
