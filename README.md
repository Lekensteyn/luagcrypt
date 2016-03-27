[![Build Status](https://travis-ci.org/Lekensteyn/luagcrypt.svg?branch=master)](https://travis-ci.org/Lekensteyn/luagcrypt)
[![Build status](https://ci.appveyor.com/api/projects/status/9rlt1msbtnriy04q?svg=true)](https://ci.appveyor.com/project/Lekensteyn/luagcrypt)
[![Coverage Status](https://coveralls.io/repos/github/Lekensteyn/luagcrypt/badge.svg?branch=master)](https://coveralls.io/github/Lekensteyn/luagcrypt?branch=master)

luagcrypt
=========
Luagcrypt is a Lua binding to the Libgcrypt cryptographic library.
Symmetric encryption/decryption (AES, etc.) and hashing (MD5, SHA-1, SHA-2,
etc.) are supported.

It is compatible with Lua 5.1, 5.2 and 5.3 and runs on Linux, OS X and Windows.


Installation
------------
The minimum requirement is Libgcrypt 1.4.2 (libgcrypt-11), but at least
Libgcrypt 1.6.0 (libgcrypt-20) is recommended.
After ensuring that the Lua and Libgcrypt development headers and libraries are
available, you can invoke `make` to build `luagcrypt.so` with Lua 5.2. See the
[Makefile](Makefile) file for available variables.

An alternative cross-platform method uses [LuaRocks](https://luarocks.org/).
Once you have checked out this repository, you can invoke:

    luarocks make

Note for Windows users: the rockspec file uses libgcrypt-20 which is used since
Wireshark 1.12. Older Wireshark versions use Libgcrypt 1.4.6 (libgcrypt-11).

Documentation
-------------
The interface closely mimics the [Libgcrypt API][0]. The following text assume
the module name to be `gcrypt = require("luagcrypt")` for convenience.

Available functions under the module scope:
 - [Symmetric cryptography][1] - `cipher = gcrypt.Cipher(algo, mode[, flags])`
 - [Hashing][2] - `md = gcrypt.Hash(algo[, flags])`
 - [`version = gcrypt.check_version([req_version])`][3] - retrieve the Libgcrypt
   version string. If `req_version` is given, then `nil` may be returned if the
   required version is not satisfied.

For the documentation of available functions, see the [Libgcrypt manual][0]. The
above constructors correspond to the `gcry_*_open` routines. Resource
deallocation (`gcry_*_close`) are handled implicitly by garbage collection.
Length parameters are omitted when these can be inferred from the string length.
For example, Libgcrypt's `gcry_cipher_setkey(cipher, key, key_len)` matches
`cipher:setkey(key)` in Lua.

An error is thrown if any error occurs, that is, when the Libgcrypt functions
return non-zero. (The error message text may change in the future.)

Constants like `GCRY_CIPHER_AES256` are exposed as `gcrypt.CIPHER_AES256`
(without the `GCRY_` prefix).

Example
-------
The test suite contains representative examples, see
[luagcrypt_test.lua](luagcrypt_test.lua).

Another full example to calculate a SHA-256 message digest for standard input:

```lua
local gcrypt = require("luagcrypt")
-- Initialize the gcrypt library (required for standalone applications that
-- do not use Libgcrypt themselves).
gcrypt.init()

-- Convert bytes to their hexadecimal representation
function tohex(s)
    local hex = string.gsub(s, ".", function(c)
        return string.format("%02x", string.byte(c))
    end)
    return hex
end

local md = gcrypt.Hash(gcrypt.MD_SHA256)

-- Keep reading from standard input until EOF and update the hash state
repeat
    local data = io.read(4096)
    if data then
        md:write(data)
    end
until not data

-- Extract the hash as hexadecimal value
print(tohex(md:read()))
```

Tests
-----
The basic test suite requires just Libgcrypt and Lua and can be invoked with
`make check` (which invokes `luagcrypt_test.lua`).

Run the code coverage checker with:

    make checkcoverage LUA_DIR=/usr

License
-------
Copyright (c) 2016 Peter Wu <peter@lekensteyn.nl>

This project ("luagcrypt") is licensed under the MIT license. See the
[LICENSE](LICENSE) file for more details.

 [0]: https://gnupg.org/documentation/manuals/gcrypt/
 [1]: https://gnupg.org/documentation/manuals/gcrypt/Symmetric-cryptography.html
 [2]: https://gnupg.org/documentation/manuals/gcrypt/Hashing.html
 [3]: https://gnupg.org/documentation/manuals/gcrypt/Initializing-the-library.html
