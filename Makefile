LUA_VER     = 5.2
LUA         = lua$(LUA_VER)
LUA_DIR     = /usr/local
LUA_INCDIR  = $(LUA_DIR)/include/lua$(LUA_VER)

LUA_LIBDIR  = $(LUA_DIR)/lib/lua/$(LUA_VER)

CFLAGS      = -Wall -Wextra -Werror=implicit-function-declaration
CFLAGS     += -O2 -g -I$(LUA_INCDIR)
LDFLAGS     = -lgcrypt -lgpg-error

OS          = $(shell uname)
ifeq ($(OS), Darwin)
LIBFLAG     = -bundle -undefined dynamic_lookup -all_load
else
LIBFLAG     = -shared
endif

luagcrypt.so: luagcrypt.c
	@if test ! -e $(LUA_INCDIR)/lua.h; then \
		echo Could not find lua.h at LUA_INCDIR=$(LUA_INCDIR); \
		exit 1; fi
	$(CC) $(CFLAGS) $(LIBFLAG) -o $@ $< -fPIC $(LDFLAGS)

check: luagcrypt.so
	$(LUA) luagcrypt_test.lua

.PHONY: clean install

clean:
	$(RM) luagcrypt.so luagcrypt.gcda luagcrypt.gcno luagcrypt.o luagcrypt.c.gcov

install: luagcrypt.so
	install -Dm755 luagcrypt.so $(DESTDIR)$(LUA_LIBDIR)/luagcrypt.so

checkcoverage:
	$(MAKE) -s clean
	$(MAKE) luagcrypt.so CFLAGS="$(CFLAGS) --coverage"
	$(LUA) luagcrypt_test.lua
	-gcov -n luagcrypt.c
