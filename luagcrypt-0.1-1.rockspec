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
        library = "gcrypt"
    }
}

build = {
    type = "builtin",
    modules = {
        luagcrypt = {
            sources = {"luagcrypt.c"},
            libraries = {"gcrypt", "gpg-error"},
            incdirs = {"$(LIBGCRYPT_INCDIR)"},
            libdirs = {"$(LIBGCRYPT_LIBDIR)"},
        }
    }
}
