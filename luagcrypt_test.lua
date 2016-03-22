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
    assert(gcrypt.CIPHER_MODE_CTR == 6)
    assert(gcrypt.CIPHER_MODE_GCM == 9)
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

function test_aes_ctr_192()
    -- RFC 3686 -- 6. Test Vectors (Test Vector #6)
    local counter_iv_one = fromhex("0007bdfd5cbd60278dcc091200000001")
    local plaintexts = {
        fromhex("000102030405060708090a0b0c0d0e0f"),
        fromhex("101112131415161718191a1b1c1d1e1f"),
        fromhex("20212223")
    }
    local ciphertexts = {
        fromhex("96893fc55e5c722f540b7dd1ddf7e758"),
        fromhex("d288bc95c69165884536c811662f2188"),
        fromhex("abee0935")
    }
    local cipher = gcrypt.Cipher(gcrypt.CIPHER_AES192, gcrypt.CIPHER_MODE_CTR)
    cipher:setkey(fromhex("02bf391ee8ecb159b959617b0965279bf59b60a786d3e0fe"))
    cipher:setctr(counter_iv_one)
    assert(cipher:encrypt(plaintexts[1]) == ciphertexts[1])
    assert(cipher:encrypt(plaintexts[2]) == ciphertexts[2])
    assert(cipher:encrypt(plaintexts[3]) == ciphertexts[3])
    cipher:setctr(counter_iv_one)
    assert(cipher:decrypt(ciphertexts[1]) == plaintexts[1])
    assert(cipher:decrypt(ciphertexts[2]) == plaintexts[2])
    assert(cipher:decrypt(ciphertexts[3]) == plaintexts[3])
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

-- Check for SHA256 calculation with optional flags parameter and reset.
function test_sha256()
    -- http://csrc.nist.gov/groups/ST/toolkit/examples.html
    local md = gcrypt.Hash(gcrypt.MD_SHA256)
    md:write("will be reset")
    md:reset()
    md:write("ab")
    md:write("c")
    local digest = md:read(gcrypt.MD_SHA256)
    assert(digest == fromhex("ba7816bf8f01cfea414140de5dae2223" ..
                             "b00361a396177a9cb410ff61f20015ad"))
end

function assert_throws(func, message)
    local ok, err = pcall(func)
    if ok then
        error("Expected \"" .. message .. "\", got no error")
    end
    if not string.find(err, message, 1, true) then
        error("Expected \"" .. message .. "\", got \"" .. err .. "\"")
    end
end

function test_cipher_bad()
    assert_throws(function() gcrypt.Cipher(0, 0) end,
    "gcry_cipher_open() failed with Invalid cipher algorithm")

    local cipher = gcrypt.Cipher(gcrypt.CIPHER_AES128, gcrypt.CIPHER_MODE_CBC)
    assert_throws(function() cipher:setkey("") end,
    "gcry_cipher_setkey() failed with Invalid key length")
    -- Must normally be a multiple of block size
    assert_throws(function() cipher:encrypt("x") end,
    "gcry_cipher_encrypt() failed with Invalid length")
    assert_throws(function() cipher:decrypt("y") end,
    "gcry_cipher_decrypt() failed with Invalid length")
end

function test_aes_ctr_bad()
    local cipher = gcrypt.Cipher(gcrypt.CIPHER_AES128, gcrypt.CIPHER_MODE_CTR)
    -- Counter must be a multiple of block size
    assert_throws(function() cipher:setctr("x") end,
    "gcry_cipher_setctr() failed with Invalid argument")
end

function test_aes_gcm_bad()
    local cipher = gcrypt.Cipher(gcrypt.CIPHER_AES128, gcrypt.CIPHER_MODE_GCM)
    assert_throws(function() cipher:setiv("") end,
    "gcry_cipher_setiv() failed with Invalid length")
end

function test_hash_bad()
    -- Not all flags are valid, this should trigger an error. Alternatively, one
    -- can set an invalid algorithm (such as -1), but that generates debug spew.
    assert_throws(function() gcrypt.Hash(0, -1) end,
    "gcry_md_open() failed with Invalid argument")

    local md = gcrypt.Hash(gcrypt.MD_SHA256)
    -- Not called with MD_FLAG_HMAC, so should fail
    assert_throws(function() md:setkey("X") end,
    "gcry_md_setkey() failed with Conflicting use")
    assert_throws(function() md:read(-1) end,
    "Unable to obtain digest for a disabled algorithm")
end

function test_init_once()
    -- TODO is this really desired behavior?
    assert_throws(function() gcrypt.init() end,
    "libgcrypt was already initialized")
end

local all_tests = {
    {"test_constants",      test_constants},
    {"test_aes_cbc_128",    test_aes_cbc_128},
    {"test_aes_ctr_192",    test_aes_ctr_192},
    {"test_hmac_sha256",    test_hmac_sha256},
    {"test_sha256",         test_sha256},
    {"test_cipher_bad",     test_cipher_bad},
    {"test_aes_gcm_bad",    test_aes_ctr_bad},
    {"test_aes_gcm_bad",    test_aes_gcm_bad},
    {"test_hash_bad",       test_hash_bad},
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
