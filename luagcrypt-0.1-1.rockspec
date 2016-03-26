package = "luagcrypt"
version = "0.1-1"

source = {
    url = "git://github.com/Lekensteyn/luagcrypt.git"
}

description = {
    summary = "A Lua interface to the libgcrypt library",
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
                --library = "libgcrypt-11",    -- libgcrypt 1.5
                library = "libgcrypt-20",   -- libgcrypt 1.6
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
                        --"libgcrypt-11",     -- libgcrypt 1.5
                        "libgcrypt-20",     -- libgcrypt 1.6
                    },
                }
            }
        }
    }
}
