.phony: all clean

PRIV_DIR = $(MIX_APP_PATH)/priv
BUILD_DIR = $(MIX_APP_PATH)/obj
EXP_SO = $(PRIV_DIR)/libexp.so

SRC_DIR = c_src

EXP_C_SRC = $(SRC_DIR)/libexp.c
EXP_C_OBJ = $(EXP_C_SRC:$(SRC_DIR)/%.c=$(BUILD_DIR)/%.o)
EXP_C_DEPS = $(EXP_C_SRC:$(SRC_DIR)/%.c=$(BUILD_DIR)/%.d)

ifeq ($(CROSSCOMPILE),)
ifeq ($(shell uname -s),Linux)
LDFLAGS += -fPIC -shared
CFLAGS += -fPIC
else
LDFLAGS += -undefined dynamic_lookup -dynamiclib
endif
else
LDFLAGS += -fPIC -shared
CFLAGS += -fPIC
endif

ifeq ($(ERL_EI_INCLUDE_DIR),)
ERLANG_PATH = $(shell elixir --eval ':code.root_dir |> to_string() |> IO.puts')
ifeq ($(ERLANG_PATH),)
$(error Could not find the Elixir installation. Check to see that 'elixir')
endif
ERL_EI_INCLUDE_DIR = $(ERLANG_PATH)/usr/include
ERL_EI_LIB_DIR = $(ERLANG_PATH)/usr/lib
endif

ERL_CFLAGS ?= -I$(ERL_EI_INCLUDE_DIR)
ERL_LDFLAGS ?= -L$(ERL_EI_LIBDIR)

CFLAGS += -std=c11 -O3 -Wall -Wextra -Wno-unused-function -Wno-unused-parameter -Wno-missing-field-initializers

all: $(PRIV_DIR) $(BUILD_DIR) $(EXP_SO) $(EXP_C_DEPS)

$(PRIV_DIR) $(BUILD_DIR):
	mkdir -p $@

$(EXP_SO): $(EXP_C_OBJ)
	@echo "LD $(notdir $@)"
	$(CC) -o $@ $^ $(ERL_LDFLAGS) $(LDFLAGS)

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.c $(BUILD_DIR)/%.d
	@echo "CC $(notdir $@)"
	$(CC) -c $(ERL_CFLAGS) $(CFLAGS) -o $@ $<

$(BUILD_DIR)/%.d: $(SRC_DIR)/%.c
	@echo "DEP $(notdir $@)"
	$(CC) $(ERL_CFLAGS) $(CFLAGS) $< -MM -MP -MF $@

include $(shell ls $(EXP_C_DEPS) 2>/dev/null)

clean:
	$(RM) -rf $(PRIV_DIR) $(BUILD_DIR)
