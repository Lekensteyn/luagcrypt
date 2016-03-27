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

function test_check_version()
    -- Request version
    assert(gcrypt.check_version())
    -- Minimum supported version
    assert(gcrypt.check_version("1.4.2"))
    -- Should return nil if the version is not supported
    assert(gcrypt.check_version("99.9.9") == nil)
end

-- Ensure that advertised constants are never removed.
function test_constants()
    assert(gcrypt.CIPHER_IDEA == 1)
    assert(gcrypt.CIPHER_3DES == 2)
    assert(gcrypt.CIPHER_CAST5 == 3)
    assert(gcrypt.CIPHER_BLOWFISH == 4)
    assert(gcrypt.CIPHER_AES128 == 7)
    assert(gcrypt.CIPHER_AES192 == 8)
    assert(gcrypt.CIPHER_AES256 == 9)
    assert(gcrypt.CIPHER_TWOFISH == 10)
    assert(gcrypt.CIPHER_ARCFOUR == 301)
    assert(gcrypt.CIPHER_DES == 302)
    assert(gcrypt.CIPHER_TWOFISH128 == 303)
    assert(gcrypt.CIPHER_SERPENT128 == 304)
    assert(gcrypt.CIPHER_SERPENT192 == 305)
    assert(gcrypt.CIPHER_SERPENT256 == 306)
    assert(gcrypt.CIPHER_RFC2268_40 == 307)
    assert(gcrypt.CIPHER_RFC2268_128 == 308)
    assert(gcrypt.CIPHER_SEED == 309)
    assert(gcrypt.CIPHER_CAMELLIA128 == 310)
    assert(gcrypt.CIPHER_CAMELLIA192 == 311)
    assert(gcrypt.CIPHER_CAMELLIA256 == 312)
    if check_version("1.6.0") then
        assert(gcrypt.CIPHER_SALSA20 == 313)
        assert(gcrypt.CIPHER_SALSA20R12 == 314)
        assert(gcrypt.CIPHER_GOST28147 == 315)
    end
    if check_version("1.7.0") then
        assert(gcrypt.CIPHER_CHACHA20 == 316)
    end

    assert(gcrypt.CIPHER_MODE_ECB == 1)
    assert(gcrypt.CIPHER_MODE_CFB == 2)
    assert(gcrypt.CIPHER_MODE_CBC == 3)
    assert(gcrypt.CIPHER_MODE_STREAM == 4)
    assert(gcrypt.CIPHER_MODE_OFB == 5)
    assert(gcrypt.CIPHER_MODE_CTR == 6)
    if check_version("1.5.0") then
        assert(gcrypt.CIPHER_MODE_AESWRAP == 7)
    end
    if check_version("1.6.0") then
        assert(gcrypt.CIPHER_MODE_CCM == 8)
        assert(gcrypt.CIPHER_MODE_GCM == 9)
    end
    if check_version("1.7.0") then
        assert(gcrypt.CIPHER_MODE_POLY1305 == 10)
        assert(gcrypt.CIPHER_MODE_OCB == 11)
    end

    assert(gcrypt.MD_SHA1 == 2)
    assert(gcrypt.MD_RMD160 == 3)
    assert(gcrypt.MD_MD5 == 1)
    assert(gcrypt.MD_MD4 == 301)
    assert(gcrypt.MD_TIGER == 6)
    if check_version("1.5.0") then
        assert(gcrypt.MD_TIGER1 == 306)
        assert(gcrypt.MD_TIGER2 == 307)
    end
    assert(gcrypt.MD_SHA224 == 11)
    assert(gcrypt.MD_SHA256 == 8)
    assert(gcrypt.MD_SHA384 == 9)
    assert(gcrypt.MD_SHA512 == 10)
    assert(gcrypt.MD_CRC32 == 302)
    assert(gcrypt.MD_CRC32_RFC1510 == 303)
    assert(gcrypt.MD_CRC24_RFC2440 == 304)
    assert(gcrypt.MD_WHIRLPOOL == 305)
    if check_version("1.6.0") then
        assert(gcrypt.MD_GOSTR3411_94 == 308)
        assert(gcrypt.MD_STRIBOG256 == 309)
        assert(gcrypt.MD_STRIBOG512 == 310)
    end
    if check_version("1.7.0") then
        assert(gcrypt.MD_GOSTR3411_CP == 311)
        assert(gcrypt.MD_SHA3_224 == 312)
        assert(gcrypt.MD_SHA3_256 == 313)
        assert(gcrypt.MD_SHA3_384 == 314)
        assert(gcrypt.MD_SHA3_512 == 315)
        assert(gcrypt.MD_SHAKE128 == 316)
        assert(gcrypt.MD_SHAKE256 == 317)
    end

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

function test_aes_gcm_128()
    if not check_version("1.6.0") then return end
    -- http://csrc.nist.gov/groups/ST/toolkit/BCM/documents/proposedmodes/gcm/gcm-revised-spec.pdf
    -- Test case 4
    local plaintext_spec = fromhex("d9313225f88406e5a55909c5aff5269a" ..
                                   "86a7a9531534f7da2e4c303d8a318a72" ..
                                   "1c3c0c95956809532fcf0e2449a6b525" ..
                                   "b16aedf5aa0de657ba637b39")
    local ciphertext_spec = fromhex("42831ec2217774244b7221b784d0d49c" ..
                                    "e3aa212f2c02a4e035c17e2329aca12e" ..
                                    "21d514b25466931c7d8f6a5aac84aa05" ..
                                    "1ba30b396a0aac973d58e091")
    local adata = fromhex("feedfacedeadbeeffeedfacedeadbeefabaddad2")
    local atag = fromhex("5bc94fbc3221a5db94fae95ae7121a47")
    local iv = fromhex("cafebabefacedbaddecaf888")
    local cipher = gcrypt.Cipher(gcrypt.CIPHER_AES128, gcrypt.CIPHER_MODE_GCM)
    cipher:setkey(fromhex("feffe9928665731c6d6a8f9467308308"))
    cipher:setiv(iv)
    cipher:authenticate(adata)
    assert(cipher:encrypt(plaintext_spec) == ciphertext_spec)
    assert(cipher:gettag() == atag)
    cipher:checktag(atag)

    cipher:reset()
    cipher:setiv(iv)
    assert(cipher:decrypt(ciphertext_spec) == plaintext_spec)
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
    -- Should not segfault.
    cipher:__gc()
    cipher:__gc()
    assert_throws(function() cipher:reset() end,
    "Called into a dead object")
end

function test_cipher_gettag()
    if not check_version("1.6.0") then return end
    -- ECB has no tag, it should not succeed
    local cipher = gcrypt.Cipher(gcrypt.CIPHER_AES128, gcrypt.CIPHER_MODE_ECB)
    assert_throws(function() cipher:gettag() end,
    "Unsupported cipher mode")
end

function test_aes_ctr_bad()
    local cipher = gcrypt.Cipher(gcrypt.CIPHER_AES128, gcrypt.CIPHER_MODE_CTR)
    -- Counter must be a multiple of block size
    assert_throws(function() cipher:setctr("x") end,
    "gcry_cipher_setctr() failed with Invalid argument")
end

function test_aes_gcm_bad()
    if not check_version("1.6.0") then return end
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
    -- 1.6.5: "Conflicting use".
    -- 1.7.0: "Invalid digest algorithm"
    assert_throws(function() md:setkey("X") end,
    "gcry_md_setkey() failed with ")
    assert_throws(function() md:read(-1) end,
    "Unable to obtain digest for a disabled algorithm")
    -- Should not segfault.
    md:__gc()
    md:__gc()
    assert_throws(function() md:reset() end,
    "Called into a dead object")
end

function test_init_once()
    -- TODO is this really desired behavior?
    assert_throws(function() gcrypt.init() end,
    "Libgcrypt was already initialized")
end

local all_tests = {
    {"test_check_version",  test_check_version},
    {"test_constants",      test_constants},
    {"test_aes_cbc_128",    test_aes_cbc_128},
    {"test_aes_ctr_192",    test_aes_ctr_192},
    {"test_aes_gcm_128",    test_aes_gcm_128},
    {"test_hmac_sha256",    test_hmac_sha256},
    {"test_sha256",         test_sha256},
    {"test_cipher_bad",     test_cipher_bad},
    {"test_cipher_gettag",  test_cipher_gettag},
    {"test_aes_ctr_bad",    test_aes_ctr_bad},
    {"test_aes_gcm_bad",    test_aes_gcm_bad},
    {"test_hash_bad",       test_hash_bad},
    {"test_init_once",      test_init_once},
}

function check_version(req_version)
    if gcrypt.check_version(req_version) then
        return true
    end
    print("Skipping test because Libgcrypt " .. req_version .. " is required")
end

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
