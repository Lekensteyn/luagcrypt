--
-- Test suite for luagcrypt.
--
-- Copyright (C) 2016 Peter Wu <peter@lekensteyn.nl>
-- Licensed under the MIT license. See the LICENSE file for details.
--

-- Convert a string of hexadecimal numbers to a bytes string
function fromhex(hex)
    if string.match(hex, "[^0-9a-fA-F]") then
        error("Invalid chars in hex")
    end
    if string.len(hex) % 2 == 1 then
        error("Hex string must be a multiple of two")
    end
    local s = string.gsub(hex, "..", function(v)
        return string.char(tonumber(v, 16))
    end)
    return s
end

-- Ensure that advertised constants are never removed.
function test_constants()
    assert(gcrypt.CIPHER_AES128 == 7)
    assert(gcrypt.CIPHER_AES192 == 8)
    assert(gcrypt.CIPHER_AES256 == 9)
    assert(gcrypt.CIPHER_MODE_CBC == 3)
    assert(gcrypt.MD_SHA256 == 8)
    assert(gcrypt.MD_FLAG_HMAC == 2)
end

function test_aes_cbc_128()
    -- RFC 3602 -- 4. Test Vectors (Case #1)
    local cipher = gcrypt.Cipher(gcrypt.CIPHER_AES128, gcrypt.CIPHER_MODE_CBC)
    cipher:setkey(fromhex("06a9214036b8a15b512e03d534120006"))
    cipher:setiv(fromhex("3dafba429d9eb430b422da802c9fac41"))
    local ciphertext = cipher:encrypt("Single block msg")
    assert(ciphertext == fromhex("e353779c1079aeb82708942dbe77181a"))

    cipher:reset()
    cipher:setiv(fromhex("3dafba429d9eb430b422da802c9fac41"))
    local plaintext = cipher:decrypt(fromhex("e353779c1079aeb82708942dbe77181a"))
    assert(plaintext == "Single block msg")
end

function test_hmac_sha256()
    -- RFC 4231 -- 4.2. Test Case 1
    local md = gcrypt.Hash(gcrypt.MD_SHA256, gcrypt.MD_FLAG_HMAC)
    md:setkey(fromhex("0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b"))
    md:write("Hi There")
    local digest = md:read()
    assert(digest == fromhex("b0344c61d8db38535ca8afceaf0bf12b" ..
                             "881dc200c9833da726e9376c2e32cff7"))
end

function test_sha256()
    -- http://csrc.nist.gov/groups/ST/toolkit/examples.html
    local md = gcrypt.Hash(gcrypt.MD_SHA256)
    md:write("ab")
    md:write("c")
    local digest = md:read(gcrypt.MD_SHA256)
    assert(digest == fromhex("ba7816bf8f01cfea414140de5dae2223" ..
                             "b00361a396177a9cb410ff61f20015ad"))
end

local all_tests = {
    {"test_constants",      test_constants},
    {"test_aes_cbc_128",    test_aes_cbc_128},
    {"test_hmac_sha256",    test_hmac_sha256},
    {"test_sha256",         test_sha256},
    -- TODO bad weather tests
}

function main()
    for k, v in pairs(all_tests) do
        local name, test = v[1], v[2]
        print("Running " .. name .. "...")
        test()
        -- Trigger GC routines
        collectgarbage()
    end
    print("All tests pass!")
end

gcrypt = require("luagcrypt")
gcrypt.init()
main()
