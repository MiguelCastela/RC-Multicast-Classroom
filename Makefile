# Virtual Classroom - build file
# Produces three executables under bin/: class_server, class_client, class_admin

CC      := gcc
CFLAGS  := -Wall -Wextra
LDFLAGS := -pthread

SERVER_DIR := src/server
CLIENT_DIR := src/client
ADMIN_DIR  := src/admin
CONFIG_DIR := src/config
BIN_DIR    := bin

SERVER_SRC := $(SERVER_DIR)/class_server.c \
              $(SERVER_DIR)/commands_server.c \
              $(SERVER_DIR)/class_struct.c \
              $(SERVER_DIR)/file_manager.c
SERVER_OBJ := $(SERVER_SRC:.c=.o)
SERVER_HDR := $(wildcard $(SERVER_DIR)/*.h)

CONFIG_FILE := $(CONFIG_DIR)/class_config.config

.PHONY: all server client admin configs clean

all: server client admin configs

server: $(BIN_DIR)/class_server
client: $(BIN_DIR)/class_client
admin:  $(BIN_DIR)/class_admin

$(BIN_DIR)/class_server: $(SERVER_OBJ) | $(BIN_DIR)
	$(CC) $(CFLAGS) $^ $(LDFLAGS) -o $@

$(BIN_DIR)/class_client: $(CLIENT_DIR)/class_client.o | $(BIN_DIR)
	$(CC) $(CFLAGS) $^ $(LDFLAGS) -o $@

$(BIN_DIR)/class_admin: $(ADMIN_DIR)/class_admin.o | $(BIN_DIR)
	$(CC) $(CFLAGS) $^ $(LDFLAGS) -o $@

# Server objects depend on the shared headers
$(SERVER_OBJ): $(SERVER_HDR)

# Generic compile rule
%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

$(BIN_DIR):
	mkdir -p $(BIN_DIR)

# Reset the user database to its default contents
configs:
	printf "micas;castela;aluno\njoel;1234;professor\nadam;eve;administrator\n" > $(CONFIG_FILE)

clean:
	rm -f $(SERVER_DIR)/*.o $(CLIENT_DIR)/*.o $(ADMIN_DIR)/*.o
	rm -rf $(BIN_DIR)
