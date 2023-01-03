local lib = {}

lib.facing = 0 --0 is +Z South
lib.currentAbsX = 0
lib.currentAbsY = 0
lib.currentAbsZ = 0

lib.facingDirections = {
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

function lib.setCurrentFacing(currentFacing)
    lib.facing = currentFacing
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

    if lib.facing == lib.facingDirections.south then
        lib.facing = lib.facingDirections.east
    else
        lib.facing = lib.facing - 1
    end
end

function lib.turnRight()
    turtle.turnRight()

    if lib.facing == lib.facingDirections.east then
        lib.facing = lib.facingDirections.south
    else
        lib.facing = lib.facing + 1
    end
end

function lib.turnSouth()
    while lib.facing ~= lib.facingDirections.south do
        if lib.facing == lib.facingDirections.east then
            lib.turnRight()
        else
            lib.turnLeft()
        end
    end
end

function lib.turnWest()
    while lib.facing ~= lib.facingDirections.west do
        if lib.facing == lib.facingDirections.south then
            lib.turnRight()
        else
            lib.turnLeft()
        end
    end
end

function lib.turnNorth()
    while lib.facing ~= lib.facingDirections.north do
        if lib.facing == lib.facingDirections.west then
            lib.turnRight()
        else
            lib.turnLeft()
        end
    end
end

function lib.turnEast()
    while lib.facing ~= lib.facingDirections.east do
        if lib.facing == lib.facingDirections.north then
            lib.turnRight()
        else
            lib.turnLeft()
        end
    end
end

function lib.forward()
    turtle.forward()

    if lib.facing == lib.facingDirections.north then
        lib.currentAbsZ = lib.currentAbsZ - 1
    elseif lib.facing == lib.facingDirections.south then
        lib.currentAbsZ = lib.currentAbsZ + 1
    elseif lib.facing == lib.facingDirections.east then
        lib.currentAbsX = lib.currentAbsX + 1
    elseif lib.facing == lib.facingDirections.west then
        lib.currentAbsX = lib.currentAbsX - 1
    else
        error("Lost track of lib.facing direction. Direction "..lib.facing.." is invalid")
    end
end

function lib.back()
    turtle.back()

    if lib.facing == lib.facingDirections.north then
        lib.currentAbsZ = lib.currentAbsZ + 1
    elseif lib.facing == lib.facingDirections.south then
        lib.currentAbsZ = lib.currentAbsZ - 1
    elseif lib.facing == lib.facingDirections.east then
        lib.currentAbsX = lib.currentAbsX - 1
    elseif lib.facing == lib.facingDirections.west then
        lib.currentAbsX = lib.currentAbsX + 1
    else
        error("Lost track of lib.facing direction. Direction "..lib.facing.." is invalid")
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
