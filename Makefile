LUA 	= lua
ifeq ($(notdir $(LUA)),lua)
LUA_INCLUDE_DIR = /usr/include
else
LUA_INCLUDE_DIR = /usr/include/$(LUA)
endif

CFLAGS  = -Wall -Wextra -O2 -g
CFLAGS += -Werror=implicit-function-declaration
CFLAGS += -I$(LUA_INCLUDE_DIR)
LDFLAGS = -lgcrypt -lgpg-error

luagcrypt.so: luagcrypt.c
	@if test ! -e $(LUA_INCLUDE_DIR)/lua.h; then \
		echo Could not find lua.h at LUA_INCLUDE_DIR=$(LUA_INCLUDE_DIR); \
		exit 1; fi
	$(CC) $(CFLAGS) -shared -o $@ $< -fPIC $(LDFLAGS)

check: luagcrypt.so
	$(LUA) luagcrypt_test.lua

.PHONY: clean

clean:
	$(RM) luagcrypt.so
