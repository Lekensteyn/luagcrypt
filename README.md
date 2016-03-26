[![Build Status](https://travis-ci.org/Lekensteyn/luagcrypt.svg?branch=master)](https://travis-ci.org/Lekensteyn/luagcrypt)
[![Build status](https://ci.appveyor.com/api/projects/status/9rlt1msbtnriy04q?svg=true)](https://ci.appveyor.com/project/Lekensteyn/luagcrypt)
[![Coverage Status](https://coveralls.io/repos/github/Lekensteyn/luagcrypt/badge.svg?branch=master)](https://coveralls.io/github/Lekensteyn/luagcrypt?branch=master)

luagcrypt
=========
luagcrypt is a Lua interface to the libgcrypt library, written in C.

It is compatible with Lua 5.1, 5.2 and 5.3 and runs on Linux, OS X and Windows.


Installation
------------
The minimum requirement is libgcrypt 1.4.2 (libgcrypt-11), but at least
libgcrypt 1.6.0 (libgcrypt-20) is recommended.
After ensuring that the Lua and libgcrypt development headers and libraries are
available, you can invoke `make` to build `luagcrypt.so` with Lua 5.2. See the
[Makefile](Makefile) file for available variables.

An alternative cross-platform method uses [LuaRocks](https://luarocks.org/).
Once you have checked out this repository, you can invoke:

    luarocks make

Note for Windows users: the rockspec file uses libgcrypt-20 which is used since
Wireshark 1.12. Older Wireshark versions use libgcrypt 1.4.6 (libgcrypt-11).

API
---
The interface closely mimics the libgcrypt API. The following text assume the
module name to be `gcrypt = require("luagcrypt")` for convenience.

Functions are grouped by their purpose:
 - [Symmetric cryptography][1] - `gcrypt.Cipher`
 - [Hashing][2] - `gcrypt.Hash`

In general, the `*_open` routines correspond to invoking the above constructors.
`*_close` functions are called implicitly when an instance can be garbage
collected. Length parameters are omitted when these can be inferred from the
string length.

Constants like `GCRY_CIPHER_AES256` are exposed as `gcrypt.CIPHER_AES256`
(without the `GCRY_` prefix).

Example
-------
The test suite contains representative examples, see
[luagcrypt_test.lua](luagcrypt_test.lua).

Another full example to calculate a SHA-256 message digest for standard input:

    local gcrypt = require("luagcrypt")
    -- Initialize the gcrypt library (required for standalone applications that
    -- do not use libgcrypt themselves).
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

Tests
-----
The basic test suite requires just libgcrypt and Lua and can be invoked with
`make check` (which invokes `luagcrypt_test.lua`).

Run the code coverage checker with:

    make checkcoverage LUA_DIR=/usr

TODO
----
 - Documentation for available functions (other than looking in luagcrypt.c).
 - Expose more API functions and constants as required.
 - Is the current approach of throwing exceptions acceptable? Or should users
   just check the return value? (Will probably not happen.)

License
-------
This project ("luagcrypt") is licensed under the MIT license. See the LICENSE
file for more details.

 [1]: https://gnupg.org/documentation/manuals/gcrypt/Symmetric-cryptography.html
 [2]: https://gnupg.org/documentation/manuals/gcrypt/Hashing.html
