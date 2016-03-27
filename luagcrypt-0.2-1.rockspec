package = "luagcrypt"
version = "0.2-1"

source = {
  url = "git://github.com/Lekensteyn/luagcrypt.git",
  tag = "v0.2",
}

description = {
  summary = "A Lua interface to the Libgcrypt library",
  detailed = [[
    Luagcrypt is a Lua binding to the Libgcrypt cryptographic library.
    Symmetric encryption/decryption (AES, etc.) and hashing (MD5, SHA-1, SHA-2,
    etc.) are supported.
  ]],
  homepage = "https://github.com/Lekensteyn/luagcrypt",
  license = "MIT"
}

dependencies = {
  "lua >= 5.1"
}

external_dependencies = {
  LIBGCRYPT = {
    header = "gcrypt.h",
  },
  platforms = {
    unix = {
      LIBGCRYPT = {
        library = "gcrypt"
      }
    },
    windows = {
      LIBGCRYPT = {
        --library = "libgcrypt-11",    -- Libgcrypt 1.5
        library = "libgcrypt-20",   -- Libgcrypt 1.6
      }
    }
  }
}

build = {
  type = "builtin",
  modules = {
    luagcrypt = {
      sources = {"luagcrypt.c"},
      incdirs = {"$(LIBGCRYPT_INCDIR)"},
      libdirs = {"$(LIBGCRYPT_LIBDIR)"},
    }
  },
  platforms = {
    unix = {
      modules = {
        luagcrypt = {
          libraries = {"gcrypt"},
        }
      }
    },
    windows = {
      modules = {
        luagcrypt = {
          libraries = {
            --"libgcrypt-11",     -- Libgcrypt 1.5
            "libgcrypt-20",     -- Libgcrypt 1.6
          },
        }
      }
    }
  }
}
