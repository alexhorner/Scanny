local sha = require("anavrinssha")

local lib = {}

function lib.checkSignature(psk, message)
    if
        type(message.signature) ~= "string" or
        type(message.id) ~= "string" or
        type(message.command) ~= "string"
    then
        return false
    end

    return message.signature == tostring(lib.calculateSignature(psk, message))
end

function lib.calculateSignature(psk, message)
    return tostring(sha.digest(psk.."searchyCWZH5xY3Kia2mQZw"..message.id..message.command))
end

return lib