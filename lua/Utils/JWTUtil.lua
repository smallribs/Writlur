JWTUtil = {}

key = "hello world"

function JWTUtil.generate(username)

    local cjson = require "cjson"

    local timestamp = os.time() + 5000

    local header = cjson.encode({alg = "aes128", typ = "JWT"})
    local payload = cjson.encode({iss = "Writlur", exp = timestamp, name = username})
    local signature = ''

    local resty_sha1 = require "resty.sha1"
    local b64 = require("ngx.base64")

    local B64Header = b64.encode_base64url(header)
    local B64Payload = b64.encode_base64url(payload)

    local EncodedString = B64Header .. '.' .. B64Payload

    local aes = require "resty.aes"
    local str = require "resty.string"
    local aes_128_cbc_md5 = aes:new(key)
    local encrypted = aes_128_cbc_md5:encrypt(EncodedString)
    local signature = str.to_hex(encrypted)

    local token = B64Header .. '.' .. B64Payload .. '.' .. b64.encode_base64url(signature)

    return token
end

function JWTUtil.verify(token)
    local FirstPosition = token:find('%.') - 1
    local SecondPosition = token:sub(FirstPosition + 2, #token):find("%.")
    local B64Header = token:sub(0, FirstPosition)
    local B64Payload = token:sub(FirstPosition + 2, FirstPosition + SecondPosition)
    local B64Signature = token:sub(#B64Header + #B64Payload + 3, #token)

    local b64 = require("ngx.base64")
    local json_header = b64.decode_base64url(B64Header)
    local json_payload = b64.decode_base64url(B64Payload)
    local signature = b64.decode_base64url(B64Signature)

    local cjson = require "cjson"

    payload = cjson.decode(json_payload)

    if payload["exp"] < os.time() then
        return false
    end

    local aes = require "resty.aes"
    local str = require "resty.string"
    local aes_128_cbc_md5 = aes:new(key)
    local EncodedString = B64Header .. '.' .. B64Payload
    local encrypted = aes_128_cbc_md5:encrypt(EncodedString)
    local VerifySignature = str.to_hex(encrypted)

    if signature == VerifySignature then
        return true
    else
        return false
    end

end

return JWTUtil