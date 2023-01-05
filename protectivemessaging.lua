local sha = require("anavrinssha")

local lib = {}

local lastHeardEpoch = os.epoch()

function lib.protect(psk, message)
    if type(message) ~= "table" then error("Message must be a table") end

    message.id = os.epoch() --Set the epoch
    
    message.signature = tostring(sha.digest(psk.."searchyCWZH5xY3Kia2mQZw"..textutils.serialise(table.sort(message)))) --Sign the message

    return message
end

function lib.unprotect(psk, message)
    if type(message) ~= "table" then error("Message must be a table") end
    if type(message.signature) ~= "string" then return nil end

    local signature = message.signature --Back the signature up
    message.signature = nil --Remove the signature as it isn't part of itself
    
    local calculatedSignature = tostring(sha.digest(psk.."searchyCWZH5xY3Kia2mQZw"..textutils.serialise(table.sort(message)))) --Calculate the signature of the rest of the message

    if calculatedSignature ~= signature then print("Failed signature check") print("Expected "..calculatedSignature) print("Actual "..signature) return nil end --Check the signature is valid
    if message.id > os.epoch() then print("Failed inflate check") return nil end --Check anti-inflate
    if message.id <= lastHeardEpoch then print("Failed replay check") return nil end --Check anti-replay

    lastHeardEpoch = message.id --Remember the last epoch received
    message.id = nil --Remove the epoch from the message for processing

    return message
end

return lib